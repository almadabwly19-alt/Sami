
name: Build Turath Developer APK

on:
  workflow_dispatch:
  push:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - name: Get source
        uses: actions/checkout@v4

      - name: Setup Java
        uses: actions/setup-java@v4
        with:
          distribution: temurin
          java-version: '17'

      - name: Setup Gradle
        uses: gradle/actions/setup-gradle@v4
        with:
          gradle-version: '8.9'

      - name: Create Android project
        run: |
          mkdir -p app/src/main/java/com/turath/app

          cat > settings.gradle.kts <<'EOF'
          pluginManagement {
              repositories {
                  google()
                  mavenCentral()
                  gradlePluginPortal()
              }
          }
          dependencyResolutionManagement {
              repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
              repositories {
                  google()
                  mavenCentral()
              }
          }
          rootProject.name = "TurathDeveloper"
          include(":app")
          EOF

          cat > build.gradle.kts <<'EOF'
          plugins {
              id("com.android.application") version "8.7.3" apply false
              id("org.jetbrains.kotlin.android") version "2.0.21" apply false
              id("org.jetbrains.kotlin.plugin.compose") version "2.0.21" apply false
          }
          EOF

          cat > app/build.gradle.kts <<'EOF'
          plugins {
              id("com.android.application")
              id("org.jetbrains.kotlin.android")
              id("org.jetbrains.kotlin.plugin.compose")
          }

          android {
              namespace = "com.turath.app"
              compileSdk = 35

              defaultConfig {
                  applicationId = "com.turath.app"
                  minSdk = 26
                  targetSdk = 35
                  versionCode = 1
                  versionName = "1.0"
              }

              buildFeatures {
                  compose = true
              }
          }

          dependencies {
              implementation("androidx.core:core-ktx:1.15.0")
              implementation("androidx.activity:activity-compose:1.9.3")
              implementation(platform("androidx.compose:compose-bom:2024.12.01"))
              implementation("androidx.compose.ui:ui")
              implementation("androidx.compose.ui:ui-tooling-preview")
              implementation("androidx.compose.material3:material3")
              implementation("androidx.compose.material:material-icons-extended")
              implementation("androidx.documentfile:documentfile:1.0.1")
              implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.9.0")
              implementation("com.tom-roush:pdfbox-android:2.0.27.0")
          }
          EOF

          cat > app/src/main/AndroidManifest.xml <<'EOF'
          <manifest xmlns:android="http://schemas.android.com/apk/res/android">
              <application
                  android:label="تراث المطوّر"
                  android:theme="@android:style/Theme.Material.Light.NoActionBar"
                  android:supportsRtl="true"
                  android:allowBackup="true">
                  <activity
                      android:name=".MainActivity"
                      android:exported="true">
                      <intent-filter>
                          <action android:name="android.intent.action.MAIN"/>
                          <category android:name="android.intent.category.LAUNCHER"/>
                      </intent-filter>
                  </activity>
              </application>
          </manifest>
          EOF

          cat > app/src/main/java/com/turath/app/MainActivity.kt <<'EOF'
          package com.turath.app

          import android.os.Bundle
          import android.net.Uri
          import android.content.Context
          import android.provider.OpenableColumns
          import androidx.activity.ComponentActivity
          import androidx.activity.compose.setContent
          import androidx.activity.compose.rememberLauncherForActivityResult
          import androidx.activity.result.contract.ActivityResultContracts
          import androidx.compose.foundation.clickable
          import androidx.compose.foundation.layout.*
          import androidx.compose.foundation.lazy.LazyColumn
          import androidx.compose.foundation.lazy.items
          import androidx.compose.material.icons.Icons
          import androidx.compose.material.icons.filled.*
          import androidx.compose.material3.*
          import androidx.compose.runtime.*
          import androidx.compose.ui.Alignment
          import androidx.compose.ui.Modifier
          import androidx.compose.ui.unit.dp
          import androidx.compose.ui.text.font.FontWeight
          import kotlinx.coroutines.Dispatchers
          import kotlinx.coroutines.launch
          import kotlinx.coroutines.withContext
          import java.io.File
          import java.util.UUID
          import java.util.zip.ZipInputStream
          import com.tom_roush.pdfbox.android.PDFBoxResourceLoader
          import com.tom_roush.pdfbox.pdmodel.PDDocument
          import com.tom_roush.pdfbox.text.PDFTextStripper

          data class Book(
              val id: String,
              val name: String,
              val file: File
          )

          class MainActivity : ComponentActivity() {
              override fun onCreate(savedInstanceState: Bundle?) {
                  super.onCreate(savedInstanceState)
                  PDFBoxResourceLoader.init(applicationContext)
                  setContent { TurathScreen() }
              }
          }

          fun loadBooks(context: Context): List<Book> {
              val dir = File(context.filesDir, "library")
              dir.mkdirs()
              return dir.listFiles()
                  ?.filter { it.extension == "txt" }
                  ?.map {
                      val name = File(it.parentFile, it.nameWithoutExtension + ".name")
                      Book(
                          it.nameWithoutExtension,
                          if (name.exists()) name.readText() else it.name,
                          it
                      )
                  } ?: emptyList()
          }

          suspend fun importBook(context: Context, uri: Uri) =
              withContext(Dispatchers.IO) {
                  val dir = File(context.filesDir, "library")
                  dir.mkdirs()

                  var name = "كتاب جديد"
                  context.contentResolver.query(
                      uri, null, null, null, null
                  )?.use {
                      val i = it.getColumnIndex(OpenableColumns.DISPLAY_NAME)
                      if (i >= 0 && it.moveToFirst()) {
                          name = it.getString(i) ?: name
                      }
                  }

                  val text = when {
                      name.endsWith(".txt", true) -> {
                          context.contentResolver.openInputStream(uri)!!
                              .bufferedReader(Charsets.UTF_8).use { it.readText() }
                      }

                      name.endsWith(".pdf", true) -> {
                          val doc = context.contentResolver
                              .openInputStream(uri)!!.use { PDDocument.load(it) }
                          try {
                              PDFTextStripper().getText(doc)
                          } finally {
                              doc.close()
                          }
                      }

                      name.endsWith(".epub", true) -> {
                          val result = StringBuilder()
                          context.contentResolver.openInputStream(uri)!!.use { input ->
                              ZipInputStream(input).use { zip ->
                                  var entry = zip.nextEntry
                                  while (entry != null) {
                                      if (entry.name.endsWith(".html", true) ||
                                          entry.name.endsWith(".xhtml", true)) {
                                          val html = zip.readBytes().toString(Charsets.UTF_8)
                                          result.append(
                                              html.replace(
                                                  Regex("<[^>]*>"), " "
                                              ).replace(Regex("\\s+"), " ")
                                          ).append("\n")
                                      }
                                      zip.closeEntry()
                                      entry = zip.nextEntry
                                  }
                              }
                          }
                          result.toString()
                      }

                      else -> error("الصيغ المدعومة PDF وTXT وEPUB")
                  }

                  require(text.isNotBlank()) {
                      "الملف لا يحتوي على نص قابل للاستخراج. قد يحتاج إلى OCR."
                  }

                  val id = UUID.randomUUID().toString()
                  File(dir, "$id.txt").writeText(text)
                  File(dir, "$id.name").writeText(name)
              }

          @OptIn(ExperimentalMaterial3Api::class)
          @Composable
          fun TurathScreen() {
              val context = androidx.compose.ui.platform.LocalContext.current
              val scope = rememberCoroutineScope()
              val books = remember {
                  mutableStateListOf<Book>().apply {
                      addAll(loadBooks(context))
                  }
              }

              var search by remember { mutableStateOf("") }
              var selected by remember { mutableStateOf<Book?>(null) }
              var dark by remember { mutableStateOf(false) }
              var message by remember { mutableStateOf("") }

              val picker = rememberLauncherForActivityResult(
                  ActivityResultContracts.OpenDocument()
              ) { uri ->
                  if (uri != null) {
                      scope.launch {
                          try {
                              importBook(context, uri)
                              books.clear()
                              books.addAll(loadBooks(context))
                              message = "تم استيراد الكتاب بنجاح"
                          } catch (e: Exception) {
                              message = e.message ?: "تعذر استيراد الكتاب"
                          }
                      }
                  }
              }

              MaterialTheme(
                  colorScheme = if (dark) darkColorScheme() else lightColorScheme()
              ) {
                  Scaffold(
                      topBar = {
                          TopAppBar(
                              title = {
                                  Text(
                                      "تراث المطوّر",
                                      fontWeight = FontWeight.Bold
                                  )
                              },
                              actions = {
                                  IconButton(onClick = { dark = !dark }) {
                                      Icon(Icons.Default.DarkMode, "الوضع الليلي")
                                  }
                                  IconButton(onClick = {
                                      picker.launch(
                                          arrayOf(
                                              "application/pdf",
                                              "text/plain",
                                              "application/epub+zip"
                                          )
                                      )
                                  }) {
                                      Icon(Icons.Default.Add, "إضافة كتاب")
                                  }
                              }
                          )
                      },
                      floatingActionButton = {
                          FloatingActionButton(onClick = {
                              picker.launch(
                                  arrayOf(
                                      "application/pdf",
                                      "text/plain",
                                      "application/epub+zip"
                                  )
                              )
                          }) {
                              Icon(Icons.Default.FileOpen, "استيراد")
                          }
                      }
                  ) { padding ->
                      Column(
                          Modifier.fillMaxSize()
                              .padding(padding)
                              .padding(16.dp)
                      ) {
                          if (selected != null) {
                              Row(verticalAlignment = Alignment.CenterVertically) {
                                  IconButton(onClick = {
                                      selected = null
                                      search = ""
                                  }) {
                                      Icon(Icons.Default.ArrowBack, "رجوع")
                                  }
                                  Text(
                                      selected!!.name,
                                      fontWeight = FontWeight.Bold
                                  )
                              }
                          } else {
                              Text(
                                  "المكتبة الإسلامية",
                                  style = MaterialTheme.typography.headlineSmall,
                                  fontWeight = FontWeight.Bold
                              )
                              Text("عدد الكتب: ${books.size}")
                          }

                          Spacer(Modifier.height(12.dp))

                          OutlinedTextField(
                              value = search,
                              onValueChange = { search = it },
                              modifier = Modifier.fillMaxWidth(),
                              label = { Text("ابحث في الكتب") },
                              leadingIcon = {
                                  Icon(Icons.Default.Search, null)
                              },
                              trailingIcon = {
                                  IconButton(onClick = { search = "" }) {
                                      Icon(Icons.Default.Clear, "مسح")
                                  }
                              }
                          )

                          if (message.isNotEmpty()) {
                              Text(message)
                          }

                          val source = selected?.let { listOf(it) } ?: books.toList()

                          if (search.isNotBlank()) {
                              val results = source.flatMap { book ->
                                  val content = book.file.readText()
                                  Regex(
                                      Regex.escape(search),
                                      RegexOption.IGNORE_CASE
                                  ).findAll(content).take(100).map { match ->
                                      val start = (match.range.first - 90).coerceAtLeast(0)
                                      val end = (match.range.last + 140).coerceAtMost(content.length)
                                      book to content.substring(start, end)
                                          .replace(Regex("\\s+"), " ")
                                  }.toList()
                              }

                              Text("عدد النتائج: ${results.size}")

                              LazyColumn {
                                  items(results) { (book, excerpt) ->
                                      Card(
                                          Modifier.fillMaxWidth()
                                              .padding(vertical = 4.dp)
                                              .clickable { selected = book }
                                      ) {
                                          Column(Modifier.padding(12.dp)) {
                                              Text(book.name, fontWeight = FontWeight.Bold)
                                              Text(excerpt)
                                          }
                                      }
                                  }
                              }
                          } else if (selected != null) {
                              Text(
                                  selected!!.file.readText(),
                                  modifier = Modifier.fillMaxSize()
                                      .padding(top = 12.dp)
                              )
                          } else {
                              LazyColumn {
                                  items(books) { book ->
                                      Card(
                                          Modifier.fillMaxWidth()
                                              .padding(vertical = 4.dp)
                                      ) {
                                          Row(
                                              Modifier.padding(12.dp),
                                              verticalAlignment = Alignment.CenterVertically
                                          ) {
                                              Icon(Icons.Default.MenuBook, null)
                                              Column(
                                                  Modifier.weight(1f)
                                                      .clickable { selected = book }
                                                      .padding(horizontal = 12.dp)
                                              ) {
                                                  Text(
                                                      book.name,
                                                      fontWeight = FontWeight.Bold
                                                  )
                                                  Text("كتاب محفوظ على الجهاز")
                                              }
                                              IconButton(onClick = {
                                                  book.file.delete()
                                                  File(
                                                      book.file.parentFile,
                                                      book.id + ".name"
                                                  ).delete()
                                                  books.remove(book)
                                              }) {
                                                  Icon(Icons.Default.Delete, "حذف")
                                              }
                                          }
                                      }
                                  }
                              }
                          }
                      }
                  }
              }
          }
          EOF

      - name: Build APK
        run: gradle assembleDebug

      - name: Save APK
        uses: actions/upload-artifact@v4
        with:
          name: Turath-Developer-APK
          path: app/build/outputs/apk/debug/app-debug.apk
