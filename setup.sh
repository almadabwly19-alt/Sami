#!/bin/bash
set -e
mkdir -p "$(dirname "app/build.gradle.kts")"
cat > "app/build.gradle.kts" <<'__EOF__'
plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("org.jetbrains.kotlin.plugin.compose")
    id("com.google.devtools.ksp")
}

android {
    namespace = "com.bahith.pdf"
    compileSdk = 34

    defaultConfig {
        applicationId = "com.bahith.pdf"
        minSdk = 26
        targetSdk = 34
        versionCode = 1
        versionName = "1.0"
        ndk { abiFilters += listOf("arm64-v8a", "armeabi-v7a") }
    }

    buildFeatures { compose = true }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    kotlinOptions { jvmTarget = "17" }

    packaging {
        resources { excludes += "/META-INF/{AL2.0,LGPL2.1}" }
        jniLibs { useLegacyPackaging = true }
    }
}

dependencies {
    implementation(platform("androidx.compose:compose-bom:2024.09.00"))
    implementation("androidx.compose.ui:ui")
    implementation("androidx.compose.material3:material3")
    implementation("androidx.activity:activity-compose:1.9.2")
    implementation("androidx.lifecycle:lifecycle-viewmodel-compose:2.8.6")
    implementation("androidx.lifecycle:lifecycle-runtime-compose:2.8.6")

    implementation("androidx.room:room-runtime:2.6.1")
    implementation("androidx.room:room-ktx:2.6.1")
    ksp("androidx.room:room-compiler:2.6.1")

    implementation("com.tom-roush:pdfbox-android:2.0.27.0")
    implementation("cz.adaptech.tesseract4android:tesseract4android:4.7.0")
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.8.1")
}
__EOF__
mkdir -p "$(dirname "app/src/main/AndroidManifest.xml")"
cat > "app/src/main/AndroidManifest.xml" <<'__EOF__'
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <application
        android:allowBackup="true"
        android:label="باحث PDF"
        android:icon="@mipmap/ic_launcher"
        android:roundIcon="@mipmap/ic_launcher"
        android:supportsRtl="true"
        android:largeHeap="true"
        android:theme="@android:style/Theme.Material.Light.NoActionBar">
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:windowSoftInputMode="adjustResize">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>
    </application>
</manifest>
__EOF__
mkdir -p "$(dirname "app/src/main/java/com/bahith/pdf/Arabic.kt")"
cat > "app/src/main/java/com/bahith/pdf/Arabic.kt" <<'__EOF__'
package com.bahith.pdf

import kotlin.math.max
import kotlin.math.min

enum class SearchMode(val label: String) {
    ALL("كل الكلمات"),
    ANY("أي كلمة"),
    PREFIX("بادئات"),
    PHRASE("عبارة")
}

object Arabic {

    class Norm(val text: String, val map: IntArray)

    private fun fold(c: Char): Char = when (c) {
        'أ', 'إ', 'آ', 'ٱ' -> 'ا'
        'ى', 'ئ' -> 'ي'
        'ؤ' -> 'و'
        'ة' -> 'ه'
        else -> c
    }

    /** يزيل التشكيل والتطويل، يوحّد الهمزات والألف المقصورة والتاء المربوطة، ويحوّل علامات الترقيم إلى مسافات. */
    fun normalizeMapped(s: String): Norm {
        val sb = StringBuilder(s.length)
        val map = IntArray(s.length + 1)
        var lastSpace = true
        for (i in s.indices) {
            var c = s[i]
            val type = Character.getType(c)
            if (type == Character.NON_SPACING_MARK.toInt() ||
                type == Character.FORMAT.toInt() ||
                c == 'ـ'
            ) continue
            c = fold(c)
            if (c in '٠'..'٩') c = '0' + (c - '٠')
            else if (c in '۰'..'۹') c = '0' + (c - '۰')
            if (Character.isLetterOrDigit(c)) {
                sb.append(c.lowercaseChar())
                map[sb.length - 1] = i
                lastSpace = false
            } else if (!lastSpace) {
                sb.append(' ')
                map[sb.length - 1] = i
                lastSpace = true
            }
        }
        if (sb.isNotEmpty() && sb[sb.length - 1] == ' ') sb.setLength(sb.length - 1)
        return Norm(sb.toString(), map.copyOf(sb.length))
    }

    fun normalize(s: String): String = normalizeMapped(s).text

    fun terms(q: String): List<String> =
        normalize(q).split(' ').filter { it.isNotEmpty() }

    fun letterCount(s: String): Int = s.count { it.isLetter() }

    fun ftsQuery(terms: List<String>, mode: SearchMode): String = when (mode) {
        SearchMode.ALL -> terms.joinToString(" ")
        SearchMode.ANY -> terms.joinToString(" OR ")
        SearchMode.PREFIX -> terms.joinToString(" ") { "$it*" }
        SearchMode.PHRASE -> "\"" + terms.joinToString(" ") + "\""
    }

    /** مواضع الكلمات المطلوبة داخل النص الأصلي (بعد مطابقة التطبيع). */
    fun findRanges(text: String, terms: List<String>): List<IntRange> {
        if (terms.isEmpty() || text.isEmpty()) return emptyList()
        val n = normalizeMapped(text)
        val out = ArrayList<IntRange>()
        for (t in terms) {
            if (t.isEmpty()) continue
            var i = n.text.indexOf(t)
            var guard = 0
            while (i >= 0 && guard++ < 400) {
                val s = n.map[i]
                val e = n.map[i + t.length - 1]
                out.add(s..e)
                i = n.text.indexOf(t, i + t.length)
            }
        }
        return out.sortedBy { it.first }
    }

    /** مقتطف قصير حول أول موضع للنتيجة مع مواضع التظليل. */
    fun snippet(rawText: String, terms: List<String>, radius: Int = 80): Pair<String, List<IntRange>> {
        val flat = rawText.replace(Regex("\\s+"), " ")
        val n = normalizeMapped(flat)
        var pos = -1
        for (t in terms) {
            val i = n.text.indexOf(t)
            if (i >= 0 && (pos < 0 || i < pos)) pos = i
        }
        val orig = if (pos >= 0 && pos < n.map.size) n.map[pos] else 0
        val start = max(0, orig - radius)
        val end = min(flat.length, orig + radius * 2)
        val body = flat.substring(start, end)
        val snip = (if (start > 0) "… " else "") + body + (if (end < flat.length) " …" else "")
        return snip to findRanges(snip, terms)
    }
}
__EOF__
mkdir -p "$(dirname "app/src/main/java/com/bahith/pdf/Data.kt")"
cat > "app/src/main/java/com/bahith/pdf/Data.kt" <<'__EOF__'
package com.bahith.pdf

import android.content.Context
import androidx.room.Dao
import androidx.room.Database
import androidx.room.Entity
import androidx.room.Fts4
import androidx.room.Index
import androidx.room.Insert
import androidx.room.PrimaryKey
import androidx.room.Query
import androidx.room.RawQuery
import androidx.room.Room
import androidx.room.RoomDatabase
import androidx.room.Transaction
import androidx.sqlite.db.SupportSQLiteQuery
import kotlinx.coroutines.flow.Flow

const val ST_QUEUED = 0
const val ST_INDEXING = 1
const val ST_DONE = 2
const val ST_ERROR = 3

@Entity(tableName = "books")
data class BookEntity(
    @PrimaryKey(autoGenerate = true) val id: Long = 0,
    val title: String,
    val pageCount: Int = 0,
    val indexedPages: Int = 0,
    val status: Int = ST_QUEUED,
    val addedAt: Long = System.currentTimeMillis()
)

@Entity(tableName = "pages", indices = [Index("bookId")])
data class PageEntity(
    @PrimaryKey(autoGenerate = true) val id: Long = 0,
    val bookId: Long,
    val pageNo: Int,
    val text: String,
    val norm: String
)

// فهرس البحث السريع (FTS4) مرتبط بجدول الصفحات ويتحدّث تلقائياً
@Fts4(contentEntity = PageEntity::class)
@Entity(tableName = "pages_fts")
data class PageFts(val norm: String)

data class SearchRow(
    val bookId: Long,
    val pageNo: Int,
    val text: String,
    val title: String
)

@Dao
abstract class BookDao {
    @Query("SELECT * FROM books ORDER BY addedAt DESC")
    abstract fun observeBooks(): Flow<List<BookEntity>>

    @Query("SELECT * FROM books WHERE id = :id")
    abstract suspend fun getBook(id: Long): BookEntity?

    @Query("SELECT * FROM books WHERE status = 0 OR status = 1")
    abstract suspend fun unfinished(): List<BookEntity>

    @Insert
    abstract suspend fun insertBook(b: BookEntity): Long

    @Insert
    abstract suspend fun insertPages(p: List<PageEntity>)

    @Query("UPDATE books SET title = :title WHERE id = :id")
    abstract suspend fun rename(id: Long, title: String)

    @Query("UPDATE books SET pageCount = :count WHERE id = :id")
    abstract suspend fun setPageCount(id: Long, count: Int)

    @Query("UPDATE books SET status = :status WHERE id = :id")
    abstract suspend fun setStatus(id: Long, status: Int)

    @Query("UPDATE books SET indexedPages = :n, status = :status WHERE id = :id")
    abstract suspend fun setProgress(id: Long, n: Int, status: Int)

    @Query("DELETE FROM pages WHERE bookId = :id")
    abstract suspend fun deletePages(id: Long)

    @Query("DELETE FROM books WHERE id = :id")
    abstract suspend fun deleteBook(id: Long)

    @Query("SELECT text FROM pages WHERE bookId = :bookId AND pageNo = :pageNo LIMIT 1")
    abstract suspend fun pageText(bookId: Long, pageNo: Int): String?

    @Transaction
    open suspend fun deleteBookFully(id: Long) {
        deletePages(id)
        deleteBook(id)
    }

    @RawQuery
    abstract suspend fun search(query: SupportSQLiteQuery): List<SearchRow>
}

@Database(
    entities = [BookEntity::class, PageEntity::class, PageFts::class],
    version = 1,
    exportSchema = false
)
abstract class AppDb : RoomDatabase() {
    abstract fun dao(): BookDao

    companion object {
        @Volatile
        private var inst: AppDb? = null

        fun get(ctx: Context): AppDb = inst ?: synchronized(this) {
            inst ?: Room.databaseBuilder(ctx.applicationContext, AppDb::class.java, "bahith.db")
                .build().also { inst = it }
        }
    }
}
__EOF__
mkdir -p "$(dirname "app/src/main/java/com/bahith/pdf/MainActivity.kt")"
cat > "app/src/main/java/com/bahith/pdf/MainActivity.kt" <<'__EOF__'
package com.bahith.pdf

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent { App() }
    }
}
__EOF__
mkdir -p "$(dirname "app/src/main/java/com/bahith/pdf/Pdf.kt")"
cat > "app/src/main/java/com/bahith/pdf/Pdf.kt" <<'__EOF__'
package com.bahith.pdf

import android.content.Context
import android.graphics.Bitmap
import android.graphics.Color
import android.graphics.pdf.PdfRenderer
import android.os.ParcelFileDescriptor
import com.googlecode.tesseract.android.TessBaseAPI
import com.tom_roush.pdfbox.android.PDFBoxResourceLoader
import com.tom_roush.pdfbox.io.MemoryUsageSetting
import com.tom_roush.pdfbox.pdmodel.PDDocument
import com.tom_roush.pdfbox.text.PDFTextStripper
import kotlinx.coroutines.CancellationException
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.currentCoroutineContext
import kotlinx.coroutines.ensureActive
import kotlinx.coroutines.sync.Mutex
import kotlinx.coroutines.sync.withLock
import kotlinx.coroutines.withContext
import java.io.Closeable
import java.io.File
import java.text.Normalizer

/** عرض صفحات PDF كصور (يُستخدم في القارئ وفي الـ OCR). */
class PdfSource(file: File) : Closeable {
    private val pfd: ParcelFileDescriptor =
        ParcelFileDescriptor.open(file, ParcelFileDescriptor.MODE_READ_ONLY)
    private val renderer: PdfRenderer = try {
        PdfRenderer(pfd)
    } catch (e: Exception) {
        pfd.close()
        throw e
    }
    private val mutex = Mutex()

    val pageCount: Int get() = renderer.pageCount

    suspend fun render(index: Int, width: Int): Bitmap? = withContext(Dispatchers.IO) {
        mutex.withLock {
            try {
                val page = renderer.openPage(index)
                try {
                    val h = (width.toFloat() * page.height / page.width).toInt().coerceAtLeast(1)
                    val bmp = Bitmap.createBitmap(width, h, Bitmap.Config.ARGB_8888)
                    bmp.eraseColor(Color.WHITE)
                    page.render(bmp, null, null, PdfRenderer.Page.RENDER_MODE_FOR_DISPLAY)
                    bmp
                } finally {
                    page.close()
                }
            } catch (e: Exception) {
                null
            }
        }
    }

    override fun close() {
        try { renderer.close() } catch (_: Exception) {}
        try { pfd.close() } catch (_: Exception) {}
    }
}

class Indexer(private val ctx: Context, private val dao: BookDao) {

    private var tess: TessBaseAPI? = null

    init {
        PDFBoxResourceLoader.init(ctx.applicationContext)
    }

    private fun tessApi(): TessBaseAPI? {
        tess?.let { return it }
        return try {
            val root = File(ctx.filesDir, "tess")
            val td = File(root, "tessdata")
            td.mkdirs()
            val f = File(td, "ara.traineddata")
            if (!f.exists() || f.length() == 0L) {
                ctx.assets.open("tessdata/ara.traineddata").use { i ->
                    f.outputStream().use { o -> i.copyTo(o) }
                }
            }
            val api = TessBaseAPI()
            if (!api.init(root.absolutePath, "ara")) {
                api.recycle()
                null
            } else {
                tess = api
                api
            }
        } catch (e: Exception) {
            null
        }
    }

    private suspend fun ocr(src: PdfSource, index: Int): String {
        val api = tessApi() ?: return ""
        val bmp = src.render(index, 2000) ?: return ""
        return try {
            api.setImage(bmp)
            api.getUTF8Text() ?: ""
        } catch (e: Exception) {
            ""
        } finally {
            bmp.recycle()
        }
    }

    /** يفهرس الكتاب مرة واحدة. يمكن استئنافه من آخر صفحة. */
    suspend fun index(bookId: Long, forceOcr: Boolean) {
        val book = dao.getBook(bookId) ?: return
        if (book.status == ST_DONE && !forceOcr) return
        val file = File(ctx.filesDir, "books/$bookId.pdf")
        if (!file.exists()) {
            dao.setStatus(bookId, ST_ERROR)
            return
        }
        val done = if (forceOcr) 0 else book.indexedPages
        if (forceOcr) dao.deletePages(bookId)
        dao.setProgress(bookId, done, ST_INDEXING)

        var src: PdfSource? = null
        var doc: PDDocument? = null
        try {
            src = PdfSource(file)
            val total = src.pageCount
            if (!forceOcr) {
                doc = try {
                    PDDocument.load(file, MemoryUsageSetting.setupMixed(64L * 1024 * 1024))
                } catch (e: Exception) {
                    null
                }
            }
            val stripper = PDFTextStripper()
            stripper.setSortByPosition(true)
            val buf = ArrayList<PageEntity>()
            for (p in (done + 1)..total) {
                currentCoroutineContext().ensureActive()
                var text = ""
                if (doc != null) {
                    text = try {
                        stripper.setStartPage(p)
                        stripper.setEndPage(p)
                        Normalizer.normalize(stripper.getText(doc), Normalizer.Form.NFKC)
                    } catch (e: Exception) {
                        ""
                    }
                }
                if (Arabic.letterCount(text) < 15) {
                    val o = ocr(src, p - 1)
                    if (o.isNotBlank()) text = o
                }
                buf.add(
                    PageEntity(
                        bookId = bookId,
                        pageNo = p,
                        text = text.trim(),
                        norm = Arabic.normalize(text)
                    )
                )
                if (buf.size >= 10 || p == total) {
                    dao.insertPages(ArrayList(buf))
                    buf.clear()
                    dao.setProgress(bookId, p, if (p == total) ST_DONE else ST_INDEXING)
                }
            }
            if (done >= total) dao.setProgress(bookId, total, ST_DONE)
        } catch (e: CancellationException) {
            throw e
        } catch (e: Throwable) {
            dao.setStatus(bookId, ST_ERROR)
        } finally {
            try { doc?.close() } catch (_: Exception) {}
            src?.close()
            try { tess?.recycle() } catch (_: Exception) {}
            tess = null
        }
    }
}
__EOF__
mkdir -p "$(dirname "app/src/main/java/com/bahith/pdf/Ui.kt")"
cat > "app/src/main/java/com/bahith/pdf/Ui.kt" <<'__EOF__'
@file:OptIn(ExperimentalMaterial3Api::class)

package com.bahith.pdf

import android.graphics.Bitmap
import androidx.activity.compose.BackHandler
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.Image
import androidx.compose.foundation.clickable
import androidx.compose.foundation.gestures.detectTapGestures
import androidx.compose.foundation.gestures.detectTransformGestures
import androidx.compose.foundation.horizontalScroll
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.pager.HorizontalPager
import androidx.compose.foundation.pager.rememberPagerState
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardActions
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.Close
import androidx.compose.material.icons.filled.Home
import androidx.compose.material.icons.filled.MoreVert
import androidx.compose.material.icons.filled.Search
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.CenterAlignedTopAppBar
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.DropdownMenu
import androidx.compose.material3.DropdownMenuItem
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.ExtendedFloatingActionButton
import androidx.compose.material3.FilterChip
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.LinearProgressIndicator
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.NavigationBar
import androidx.compose.material3.NavigationBarItem
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.material3.TopAppBar
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.runtime.DisposableEffect
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableFloatStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.produceState
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clipToBounds
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.asImageBitmap
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.layout.onSizeChanged
import androidx.compose.ui.platform.LocalConfiguration
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.text.AnnotatedString
import androidx.compose.ui.text.SpanStyle
import androidx.compose.ui.text.buildAnnotatedString
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.ImeAction
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.IntSize
import androidx.compose.ui.unit.LayoutDirection
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.platform.LocalLayoutDirection
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.lifecycle.viewmodel.compose.viewModel
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import java.io.File

private val Brown = Color(0xFF5A3E2B)
private val Paper = Color(0xFFFBF6EC)
private val Sand = Color(0xFFF3EADB)
private val SandDark = Color(0xFFE9D9C2)
private val Mark = Color(0xFFFFD54F)

@Composable
fun AppTheme(content: @Composable () -> Unit) {
    MaterialTheme(
        colorScheme = lightColorScheme(
            primary = Brown,
            onPrimary = Color.White,
            primaryContainer = SandDark,
            onPrimaryContainer = Brown,
            secondaryContainer = SandDark,
            onSecondaryContainer = Brown,
            background = Paper,
            surface = Paper,
            surfaceVariant = Sand
        ),
        content = content
    )
}

@Composable
fun App(vm: AppViewModel = viewModel()) {
    AppTheme {
        CompositionLocalProvider(LocalLayoutDirection provides LayoutDirection.Rtl) {
            val picker = rememberLauncherForActivityResult(
                ActivityResultContracts.OpenMultipleDocuments()
            ) { uris -> vm.importUris(uris) }
            val target = vm.reader
            BackHandler(enabled = target != null) { vm.reader = null }

            Surface(Modifier.fillMaxSize(), color = MaterialTheme.colorScheme.background) {
                if (target != null) {
                    ReaderScreen(vm, target)
                } else {
                    Scaffold(
                        bottomBar = {
                            NavigationBar {
                                NavigationBarItem(
                                    selected = vm.tab == 0,
                                    onClick = { vm.tab = 0 },
                                    icon = { Icon(Icons.Default.Home, null) },
                                    label = { Text("المكتبة") }
                                )
                                NavigationBarItem(
                                    selected = vm.tab == 1,
                                    onClick = { vm.tab = 1 },
                                    icon = { Icon(Icons.Default.Search, null) },
                                    label = { Text("البحث") }
                                )
                            }
                        }
                    ) { pad ->
                        Box(Modifier.padding(pad)) {
                            if (vm.tab == 0) {
                                LibraryScreen(vm) { picker.launch(arrayOf("application/pdf")) }
                            } else {
                                SearchScreen(vm)
                            }
                        }
                    }
                }
            }

            vm.message?.let { m ->
                AlertDialog(
                    onDismissRequest = { vm.message = null },
                    confirmButton = { TextButton(onClick = { vm.message = null }) { Text("حسناً") } },
                    text = { Text(m) }
                )
            }
        }
    }
}

// ======================= المكتبة =======================

@Composable
fun LibraryScreen(vm: AppViewModel, onAdd: () -> Unit) {
    val books by vm.books.collectAsStateWithLifecycle()
    var renaming by remember { mutableStateOf<BookEntity?>(null) }
    var deleting by remember { mutableStateOf<BookEntity?>(null) }

    Scaffold(
        topBar = { CenterAlignedTopAppBar(title = { Text("باحث PDF") }) },
        floatingActionButton = {
            ExtendedFloatingActionButton(
                onClick = onAdd,
                icon = { Icon(Icons.Default.Add, null) },
                text = { Text("إضافة كتاب") }
            )
        }
    ) { pad ->
        if (books.isEmpty()) {
            Box(
                Modifier.padding(pad).fillMaxSize().padding(32.dp),
                contentAlignment = Alignment.Center
            ) {
                Text(
                    "مكتبتك فارغة.\nاضغط «إضافة كتاب» لاختيار ملفات PDF من هاتفك.",
                    textAlign = TextAlign.Center,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }
        } else {
            LazyColumn(
                Modifier.padding(pad).fillMaxSize(),
                contentPadding = PaddingValues(16.dp, 8.dp, 16.dp, 96.dp),
                verticalArrangement = Arrangement.spacedBy(10.dp)
            ) {
                items(books, key = { it.id }) { b ->
                    BookCard(b, vm, onRename = { renaming = b }, onDelete = { deleting = b })
                }
            }
        }
    }

    renaming?.let { b ->
        RenameDialog(
            current = b.title,
            onDismiss = { renaming = null },
            onOk = { vm.rename(b.id, it); renaming = null }
        )
    }
    deleting?.let { b ->
        AlertDialog(
            onDismissRequest = { deleting = null },
            title = { Text("حذف الكتاب") },
            text = { Text("سيُحذف «${b.title}» وفهرسته من التطبيق نهائياً.") },
            confirmButton = {
                TextButton(onClick = { vm.delete(b.id); deleting = null }) { Text("حذف") }
            },
            dismissButton = { TextButton(onClick = { deleting = null }) { Text("إلغاء") } }
        )
    }
}

@Composable
fun BookCard(b: BookEntity, vm: AppViewModel, onRename: () -> Unit, onDelete: () -> Unit) {
    var menu by remember { mutableStateOf(false) }
    Card(
        onClick = { if (b.pageCount > 0) vm.reader = ReaderTarget(b.id, 1, emptyList()) },
        colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surfaceVariant)
    ) {
        Row(
            Modifier.padding(start = 16.dp, top = 12.dp, bottom = 12.dp, end = 4.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Column(Modifier.weight(1f)) {
                Text(
                    b.title,
                    style = MaterialTheme.typography.titleMedium,
                    maxLines = 2,
                    overflow = TextOverflow.Ellipsis
                )
                Spacer(Modifier.height(4.dp))
                when (b.status) {
                    ST_DONE -> Text(
                        "${b.pageCount} صفحة • جاهز للبحث",
                        style = MaterialTheme.typography.labelMedium
                    )
                    ST_ERROR -> Row(verticalAlignment = Alignment.CenterVertically) {
                        Text(
                            "تعذّرت الفهرسة",
                            color = MaterialTheme.colorScheme.error,
                            style = MaterialTheme.typography.labelMedium
                        )
                        TextButton(onClick = { vm.startIndex(b.id) }) { Text("إعادة المحاولة") }
                    }
                    else -> {
                        val frac = if (b.pageCount > 0) b.indexedPages.toFloat() / b.pageCount else 0f
                        LinearProgressIndicator(progress = { frac }, modifier = Modifier.fillMaxWidth())
                        Spacer(Modifier.height(4.dp))
                        Text(
                            "جارٍ الفهرسة ${b.indexedPages} / ${b.pageCount}",
                            style = MaterialTheme.typography.labelMedium
                        )
                    }
                }
            }
            Box {
                IconButton(onClick = { menu = true }) { Icon(Icons.Default.MoreVert, "خيارات") }
                DropdownMenu(expanded = menu, onDismissRequest = { menu = false }) {
                    DropdownMenuItem(
                        text = { Text("إعادة تسمية") },
                        onClick = { menu = false; onRename() }
                    )
                    DropdownMenuItem(
                        text = { Text("إعادة الفهرسة بالـ OCR") },
                        onClick = { menu = false; vm.startIndex(b.id, true) }
                    )
                    DropdownMenuItem(
                        text = { Text("حذف") },
                        onClick = { menu = false; onDelete() }
                    )
                }
            }
        }
    }
}

@Composable
fun RenameDialog(current: String, onDismiss: () -> Unit, onOk: (String) -> Unit) {
    var t by remember { mutableStateOf(current) }
    AlertDialog(
        onDismissRequest = onDismiss,
        title = { Text("إعادة تسمية") },
        text = { OutlinedTextField(value = t, onValueChange = { t = it }, singleLine = true) },
        confirmButton = {
            TextButton(onClick = { if (t.isNotBlank()) onOk(t.trim()) }) { Text("حفظ") }
        },
        dismissButton = { TextButton(onClick = onDismiss) { Text("إلغاء") } }
    )
}

// ======================= البحث =======================

@Composable
fun SearchScreen(vm: AppViewModel) {
    val books by vm.books.collectAsStateWithLifecycle()
    var showScope by remember { mutableStateOf(false) }

    LaunchedEffect(vm.query, vm.mode, vm.scopeBookId) {
        delay(350)
        vm.search()
    }

    val scopeName = if (vm.scopeBookId == 0L) "كل الكتب"
    else books.firstOrNull { it.id == vm.scopeBookId }?.title ?: "كل الكتب"

    Scaffold(topBar = { CenterAlignedTopAppBar(title = { Text("البحث في المكتبة") }) }) { pad ->
        Column(Modifier.padding(pad).fillMaxSize()) {
            OutlinedTextField(
                value = vm.query,
                onValueChange = { vm.query = it },
                modifier = Modifier.fillMaxWidth().padding(horizontal = 16.dp),
                placeholder = { Text("اكتب كلمة أو جملة أو فقرة…") },
                leadingIcon = { Icon(Icons.Default.Search, null) },
                trailingIcon = {
                    if (vm.query.isNotEmpty()) {
                        IconButton(onClick = { vm.query = "" }) { Icon(Icons.Default.Close, "مسح") }
                    }
                },
                shape = RoundedCornerShape(24.dp),
                maxLines = 4,
                keyboardOptions = KeyboardOptions(imeAction = ImeAction.Search),
                keyboardActions = KeyboardActions(onSearch = { vm.search() })
            )
            Row(
                Modifier.horizontalScroll(rememberScrollState())
                    .padding(horizontal = 16.dp, vertical = 8.dp),
                horizontalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                SearchMode.values().forEach { m ->
                    FilterChip(
                        selected = vm.mode == m,
                        onClick = { vm.mode = m },
                        label = { Text(m.label) }
                    )
                }
            }
            Row(
                Modifier.fillMaxWidth().padding(horizontal = 16.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text("النطاق:", style = MaterialTheme.typography.labelLarge)
                TextButton(onClick = { showScope = true }) {
                    Text(scopeName, maxLines = 1, overflow = TextOverflow.Ellipsis)
                }
            }

            val res = vm.results
            when {
                vm.searching && res.isEmpty() -> Box(Modifier.fillMaxSize(), Alignment.Center) {
                    CircularProgressIndicator()
                }
                res.isEmpty() && vm.searchedOnce -> Box(Modifier.fillMaxSize(), Alignment.Center) {
                    Text("لا توجد نتائج", color = MaterialTheme.colorScheme.onSurfaceVariant)
                }
                res.isEmpty() -> Box(
                    Modifier.fillMaxSize().padding(32.dp),
                    Alignment.Center
                ) {
                    Text(
                        "ابحث بكلمة أو عبارة. للنص الطويل اختر «عبارة».\nالبحث يتجاهل التشكيل ويوحّد الهمزات.",
                        textAlign = TextAlign.Center,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                }
                else -> {
                    val shown = if (res.size >= RESULT_LIMIT) "$RESULT_LIMIT+" else "${res.size}"
                    Text(
                        "عدد الصفحات المطابقة: $shown",
                        Modifier.padding(horizontal = 16.dp, vertical = 4.dp),
                        style = MaterialTheme.typography.labelMedium
                    )
                    val grouped = res.groupBy { it.bookId }
                    LazyColumn(
                        Modifier.fillMaxSize(),
                        contentPadding = PaddingValues(16.dp, 4.dp, 16.dp, 24.dp),
                        verticalArrangement = Arrangement.spacedBy(8.dp)
                    ) {
                        grouped.forEach { (_, hits) ->
                            item {
                                Text(
                                    "${hits.first().title}  (${hits.size})",
                                    fontWeight = FontWeight.Bold,
                                    color = MaterialTheme.colorScheme.primary,
                                    modifier = Modifier.padding(top = 8.dp)
                                )
                            }
                            items(hits) { h -> HitCard(h) { vm.openHit(h) } }
                        }
                    }
                }
            }
        }
    }

    if (showScope) {
        AlertDialog(
            onDismissRequest = { showScope = false },
            title = { Text("نطاق البحث") },
            text = {
                Column(Modifier.verticalScroll(rememberScrollState())) {
                    ScopeRow("كل الكتب") { vm.scopeBookId = 0L; showScope = false }
                    books.filter { it.indexedPages > 0 }.forEach { b ->
                        ScopeRow(b.title) { vm.scopeBookId = b.id; showScope = false }
                    }
                }
            },
            confirmButton = { TextButton(onClick = { showScope = false }) { Text("إغلاق") } }
        )
    }
}

@Composable
fun ScopeRow(label: String, onClick: () -> Unit) {
    Text(
        label,
        modifier = Modifier.fillMaxWidth().clickable(onClick = onClick).padding(vertical = 12.dp),
        maxLines = 2,
        overflow = TextOverflow.Ellipsis
    )
}

fun highlighted(text: String, ranges: List<IntRange>): AnnotatedString = buildAnnotatedString {
    append(text)
    for (r in ranges) {
        val s = r.first.coerceIn(0, text.length)
        val e = (r.last + 1).coerceIn(s, text.length)
        if (e > s) addStyle(SpanStyle(background = Mark, color = Color.Black), s, e)
    }
}

@Composable
fun HitCard(h: Hit, onClick: () -> Unit) {
    Card(
        onClick = onClick,
        modifier = Modifier.fillMaxWidth(),
        colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surfaceVariant)
    ) {
        Column(Modifier.padding(12.dp)) {
            Text(
                "صفحة ${h.pageNo}",
                style = MaterialTheme.typography.labelLarge,
                color = MaterialTheme.colorScheme.primary
            )
            Spacer(Modifier.height(4.dp))
            Text(
                highlighted(h.snippet, h.ranges),
                style = MaterialTheme.typography.bodyMedium,
                lineHeight = 24.sp
            )
        }
    }
}

// ======================= القارئ =======================

@Composable
fun ReaderScreen(vm: AppViewModel, target: ReaderTarget) {
    val ctx = LocalContext.current
    val books by vm.books.collectAsStateWithLifecycle()
    val book = books.firstOrNull { it.id == target.bookId }
    if (book == null || book.pageCount <= 0) {
        LaunchedEffect(Unit) { vm.reader = null }
        return
    }
    val total = book.pageCount
    val source = remember(book.id) { PdfSource(File(ctx.filesDir, "books/${book.id}.pdf")) }
    DisposableEffect(book.id) { onDispose { source.close() } }

    val pagerState = rememberPagerState(
        initialPage = (target.page - 1).coerceIn(0, total - 1)
    ) { total }
    val scope = rememberCoroutineScope()
    var textMode by remember { mutableStateOf(target.terms.isNotEmpty()) }
    var zoomed by remember { mutableStateOf(false) }
    var showGo by remember { mutableStateOf(false) }

    LaunchedEffect(pagerState.currentPage) { zoomed = false }

    val widthPx = (LocalConfiguration.current.screenWidthDp *
        LocalDensity.current.density * 1.5f).toInt().coerceIn(800, 2000)

    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Column {
                        Text(
                            book.title,
                            maxLines = 1,
                            overflow = TextOverflow.Ellipsis,
                            style = MaterialTheme.typography.titleMedium
                        )
                        Text(
                            "صفحة ${pagerState.currentPage + 1} من $total",
                            style = MaterialTheme.typography.labelSmall
                        )
                    }
                },
                navigationIcon = {
                    IconButton(onClick = { vm.reader = null }) {
                        Icon(Icons.AutoMirrored.Filled.ArrowBack, "رجوع")
                    }
                },
                actions = {
                    TextButton(onClick = { textMode = !textMode }) {
                        Text(if (textMode) "عرض الصفحة" else "عرض النص")
                    }
                    TextButton(onClick = { showGo = true }) { Text("انتقال") }
                }
            )
        }
    ) { pad ->
        HorizontalPager(
            state = pagerState,
            userScrollEnabled = !zoomed,
            modifier = Modifier.padding(pad).fillMaxSize()
        ) { idx ->
            if (textMode) {
                TextPage(vm, book.id, idx + 1, target.terms)
            } else {
                ZoomBox(onZoomChange = { zoomed = it }) {
                    PdfPageImage(source, idx, widthPx)
                }
            }
        }
    }

    if (showGo) {
        var num by remember { mutableStateOf("") }
        AlertDialog(
            onDismissRequest = { showGo = false },
            title = { Text("الانتقال إلى صفحة") },
            text = {
                OutlinedTextField(
                    value = num,
                    onValueChange = { num = it.filter { c -> c.isDigit() } },
                    singleLine = true,
                    placeholder = { Text("1 - $total") },
                    keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number)
                )
            },
            confirmButton = {
                TextButton(onClick = {
                    val n = num.toIntOrNull()
                    if (n != null) {
                        scope.launch { pagerState.scrollToPage((n - 1).coerceIn(0, total - 1)) }
                    }
                    showGo = false
                }) { Text("انتقال") }
            },
            dismissButton = { TextButton(onClick = { showGo = false }) { Text("إلغاء") } }
        )
    }
}

@Composable
fun PdfPageImage(source: PdfSource, index: Int, widthPx: Int) {
    var bmp by remember(index) { mutableStateOf<Bitmap?>(null) }
    LaunchedEffect(index) { bmp = source.render(index, widthPx) }
    val b = bmp
    if (b == null) {
        Box(Modifier.fillMaxSize(), Alignment.Center) { CircularProgressIndicator() }
    } else {
        Image(
            bitmap = b.asImageBitmap(),
            contentDescription = null,
            modifier = Modifier.fillMaxSize(),
            contentScale = ContentScale.Fit
        )
    }
}

@Composable
fun TextPage(vm: AppViewModel, bookId: Long, pageNo: Int, terms: List<String>) {
    val text by produceState<String?>(null, bookId, pageNo) {
        value = vm.pageText(bookId, pageNo)
    }
    val t = text
    Column(Modifier.fillMaxSize().verticalScroll(rememberScrollState()).padding(16.dp)) {
        when {
            t == null -> CircularProgressIndicator()
            t.isBlank() -> Text(
                "لا يوجد نص لهذه الصفحة (لم تُفهرس بعد أو أنها فارغة). جرّب «عرض الصفحة».",
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
            else -> {
                val ranges = remember(t, terms) { Arabic.findRanges(t, terms) }
                Text(
                    highlighted(t, ranges),
                    fontSize = 20.sp,
                    lineHeight = 34.sp,
                    fontFamily = FontFamily.Serif
                )
            }
        }
    }
}

private fun clampOffset(o: Offset, s: Float, sz: IntSize): Offset {
    val mx = sz.width * (s - 1f) / 2f
    val my = sz.height * (s - 1f) / 2f
    return Offset(o.x.coerceIn(-mx, mx), o.y.coerceIn(-my, my))
}

@Composable
fun ZoomBox(onZoomChange: (Boolean) -> Unit, content: @Composable () -> Unit) {
    var scale by remember { mutableFloatStateOf(1f) }
    var offset by remember { mutableStateOf(Offset.Zero) }
    var size by remember { mutableStateOf(IntSize.Zero) }

    val gestureMod = if (scale > 1f) {
        Modifier.pointerInput(Unit) {
            detectTransformGestures { _, pan, zoom, _ ->
                val ns = (scale * zoom).coerceIn(1f, 5f)
                scale = ns
                offset = if (ns <= 1f) Offset.Zero else clampOffset(offset + pan, ns, size)
                onZoomChange(ns > 1f)
            }
        }
    } else {
        Modifier
    }

    Box(
        Modifier
            .fillMaxSize()
            .clipToBounds()
            .onSizeChanged { size = it }
            .pointerInput(Unit) {
                detectTapGestures(onDoubleTap = {
                    if (scale > 1f) {
                        scale = 1f
                        offset = Offset.Zero
                    } else {
                        scale = 2.5f
                    }
                    onZoomChange(scale > 1f)
                })
            }
            .then(gestureMod)
            .graphicsLayer(
                scaleX = scale,
                scaleY = scale,
                translationX = offset.x,
                translationY = offset.y
            )
    ) {
        content()
    }
}
__EOF__
mkdir -p "$(dirname "app/src/main/java/com/bahith/pdf/Vm.kt")"
cat > "app/src/main/java/com/bahith/pdf/Vm.kt" <<'__EOF__'
package com.bahith.pdf

import android.app.Application
import android.net.Uri
import android.provider.OpenableColumns
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableLongStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import androidx.sqlite.db.SimpleSQLiteQuery
import kotlinx.coroutines.CancellationException
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.cancelAndJoin
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.launch
import kotlinx.coroutines.sync.Mutex
import kotlinx.coroutines.sync.withLock
import kotlinx.coroutines.withContext
import java.io.File

data class Hit(
    val bookId: Long,
    val title: String,
    val pageNo: Int,
    val snippet: String,
    val ranges: List<IntRange>
)

data class ReaderTarget(val bookId: Long, val page: Int, val terms: List<String>)

const val RESULT_LIMIT = 400

class AppViewModel(app: Application) : AndroidViewModel(app) {

    private val dao = AppDb.get(app).dao()
    private val indexer = Indexer(app, dao)
    private val indexLock = Mutex()
    private val jobs = mutableMapOf<Long, Job>()
    private var searchJob: Job? = null

    val books = dao.observeBooks()
        .stateIn(viewModelScope, SharingStarted.Eagerly, emptyList())

    var tab by mutableIntStateOf(0)
    var reader by mutableStateOf<ReaderTarget?>(null)
    var message by mutableStateOf<String?>(null)

    var query by mutableStateOf("")
    var mode by mutableStateOf(SearchMode.ALL)
    var scopeBookId by mutableLongStateOf(0L)
    var results by mutableStateOf<List<Hit>>(emptyList())
    var searching by mutableStateOf(false)
    var searchedOnce by mutableStateOf(false)
    private var lastTerms: List<String> = emptyList()

    init {
        // استئناف الفهرسة غير المكتملة عند فتح التطبيق
        viewModelScope.launch {
            dao.unfinished().forEach { startIndex(it.id) }
        }
    }

    private fun booksDir(): File =
        File(getApplication<Application>().filesDir, "books").apply { mkdirs() }

    // ---------- إضافة الكتب ----------
    fun importUris(uris: List<Uri>) {
        viewModelScope.launch {
            for (uri in uris) {
                val id = withContext(Dispatchers.IO) { copyIn(uri) }
                if (id != null) startIndex(id)
            }
        }
    }

    private suspend fun copyIn(uri: Uri): Long? {
        val ctx = getApplication<Application>()
        val found: String? = try {
            ctx.contentResolver.query(uri, arrayOf(OpenableColumns.DISPLAY_NAME), null, null, null)
                ?.use { c -> if (c.moveToFirst()) c.getString(0) else null }
        } catch (e: Exception) {
            null
        }
        val name = found ?: "كتاب"
        val title = name.removeSuffix(".pdf").removeSuffix(".PDF")
        val id = dao.insertBook(BookEntity(title = title))
        val f = File(booksDir(), "$id.pdf")
        return try {
            ctx.contentResolver.openInputStream(uri)!!.use { i ->
                f.outputStream().use { o -> i.copyTo(o) }
            }
            val count = PdfSource(f).use { it.pageCount }
            dao.setPageCount(id, count)
            id
        } catch (e: Exception) {
            f.delete()
            dao.deleteBookFully(id)
            message = "تعذّر فتح الملف: $title"
            null
        }
    }

    fun startIndex(id: Long, forceOcr: Boolean = false) {
        jobs[id]?.cancel()
        jobs[id] = viewModelScope.launch(Dispatchers.Default) {
            indexLock.withLock { indexer.index(id, forceOcr) }
        }
    }

    // ---------- إدارة الكتب ----------
    fun rename(id: Long, title: String) {
        viewModelScope.launch { dao.rename(id, title) }
    }

    fun delete(id: Long) {
        viewModelScope.launch {
            jobs.remove(id)?.cancelAndJoin()
            withContext(Dispatchers.IO) {
                dao.deleteBookFully(id)
                File(booksDir(), "$id.pdf").delete()
            }
            if (scopeBookId == id) scopeBookId = 0L
        }
    }

    // ---------- البحث ----------
    fun search() {
        searchJob?.cancel()
        val terms = Arabic.terms(query)
        if (terms.isEmpty() || terms.sumOf { it.length } < 2) {
            results = emptyList()
            searchedOnce = false
            searching = false
            return
        }
        val m = mode
        val scope = scopeBookId
        searchJob = viewModelScope.launch {
            searching = true
            val out = withContext(Dispatchers.Default) { runSearch(terms, m, scope) }
            lastTerms = out.second
            results = out.first
            searchedOnce = true
            searching = false
        }
    }

    private suspend fun runSearch(
        terms: List<String>,
        m: SearchMode,
        scope: Long
    ): Pair<List<Hit>, List<String>> {
        val match = Arabic.ftsQuery(terms, m)
        val hl = if (m == SearchMode.PHRASE) listOf(terms.joinToString(" ")) else terms
        val sql = StringBuilder(
            "SELECT p.bookId AS bookId, p.pageNo AS pageNo, p.text AS text, b.title AS title " +
                "FROM pages_fts JOIN pages p ON p.id = pages_fts.rowid " +
                "JOIN books b ON b.id = p.bookId WHERE pages_fts MATCH ?"
        )
        val args = ArrayList<Any>()
        args.add(match)
        if (scope != 0L) {
            sql.append(" AND p.bookId = ?")
            args.add(scope)
        }
        sql.append(" ORDER BY b.title, p.pageNo LIMIT ").append(RESULT_LIMIT)
        val rows = try {
            dao.search(SimpleSQLiteQuery(sql.toString(), args.toTypedArray()))
        } catch (e: CancellationException) {
            throw e
        } catch (e: Exception) {
            emptyList()
        }
        val hits = rows.map {
            val (snip, ranges) = Arabic.snippet(it.text, hl)
            Hit(it.bookId, it.title, it.pageNo, snip, ranges)
        }
        return hits to hl
    }

    fun openHit(h: Hit) {
        reader = ReaderTarget(h.bookId, h.pageNo, lastTerms)
    }

    suspend fun pageText(bookId: Long, pageNo: Int): String =
        dao.pageText(bookId, pageNo) ?: ""
}
__EOF__
mkdir -p "$(dirname "app/src/main/res/drawable/ic_fg.xml")"
cat > "app/src/main/res/drawable/ic_fg.xml" <<'__EOF__'
<?xml version="1.0" encoding="utf-8"?>
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="108dp"
    android:height="108dp"
    android:viewportWidth="108"
    android:viewportHeight="108">
    <path
        android:fillColor="#FBF6EC"
        android:pathData="M32,32h36a4,4 0 0 1 4,4v36a4,4 0 0 1 -4,4h-36a4,4 0 0 1 -4,-4v-36a4,4 0 0 1 4,-4z" />
    <path
        android:fillColor="#00000000"
        android:strokeColor="#5A3E2B"
        android:strokeWidth="5"
        android:pathData="M48,50m-9,0a9,9 0 1,0 18,0a9,9 0 1,0 -18,0" />
    <path
        android:fillColor="#00000000"
        android:strokeColor="#5A3E2B"
        android:strokeWidth="5"
        android:strokeLineCap="round"
        android:pathData="M55,57L64,66" />
</vector>
__EOF__
mkdir -p "$(dirname "app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml")"
cat > "app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml" <<'__EOF__'
<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@color/ic_bg" />
    <foreground android:drawable="@drawable/ic_fg" />
</adaptive-icon>
__EOF__
mkdir -p "$(dirname "app/src/main/res/values/colors.xml")"
cat > "app/src/main/res/values/colors.xml" <<'__EOF__'
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <color name="ic_bg">#5A3E2B</color>
</resources>
__EOF__
mkdir -p "$(dirname "build.gradle.kts")"
cat > "build.gradle.kts" <<'__EOF__'
plugins {
    id("com.android.application") version "8.5.2" apply false
    id("org.jetbrains.kotlin.android") version "2.0.21" apply false
    id("org.jetbrains.kotlin.plugin.compose") version "2.0.21" apply false
    id("com.google.devtools.ksp") version "2.0.21-1.0.28" apply false
}
__EOF__
mkdir -p "$(dirname "gradle.properties")"
cat > "gradle.properties" <<'__EOF__'
org.gradle.jvmargs=-Xmx3g -Dfile.encoding=UTF-8
android.useAndroidX=true
kotlin.code.style=official
android.nonTransitiveRClass=true
__EOF__
mkdir -p "$(dirname "settings.gradle.kts")"
cat > "settings.gradle.kts" <<'__EOF__'
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
rootProject.name = "BahithPDF"
include(":app")
__EOF__
