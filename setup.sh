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
        versionCode = 5
        versionName = "1.4"
        ndk { abiFilters += listOf("arm64-v8a", "armeabi-v7a") }
    }

    signingConfigs {
        create("fixed") {
            storeFile = file("fixed.keystore")
            storePassword = "bahith123"
            keyAlias = "bahith"
            keyPassword = "bahith123"
        }
    }
    buildTypes {
        getByName("debug") { signingConfig = signingConfigs.getByName("fixed") }
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

    implementation("androidx.documentfile:documentfile:1.0.1")
    implementation("androidx.room:room-runtime:2.6.1")
    implementation("androidx.room:room-ktx:2.6.1")
    ksp("androidx.room:room-compiler:2.6.1")

    implementation("com.tom-roush:pdfbox-android:2.0.27.0")
    implementation("cz.adaptech.tesseract4android:tesseract4android:4.7.0")
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.8.1")
}
__EOF__
mkdir -p "$(dirname "app/fixed.keystore")"
base64 -d > "app/fixed.keystore" <<'__B64__'
MIIKBAIBAzCCCa4GCSqGSIb3DQEHAaCCCZ8EggmbMIIJlzCCBa4GCSqGSIb3DQEHAaCCBZ8EggWb
MIIFlzCCBZMGCyqGSIb3DQEMCgECoIIFQDCCBTwwZgYJKoZIhvcNAQUNMFkwOAYJKoZIhvcNAQUM
MCsEFO4jvMbdFL5m/Pt2zjMYKvat/BOYAgInEAIBIDAMBggqhkiG9w0CCQUAMB0GCWCGSAFlAwQB
KgQQV5+ecOa4XjiLsW4X9AyF+gSCBNA8JC1P36CuXGWvBGn4qVMybOxyY6FmYLtyT3kLUdjR9TxW
/6WmD64/CzlnkbtmW3CYFLdkU7MqKfSin83dyAdJdwQZmng1xIuw2As4arPO/nfq6apwqIDMLFq9
fH9cCQcql2xqUR+1Enpwykh2rV0yrBa0ZdcMhjz7KuG8KLtoX+60yxs76sshG9SXzgNT9d+iMegw
9sHKAa2w3DgkFw9t2nyceIBTkacL39KWIJjm1mACJDhhvdphAL+YXnhfVP8YUJwlo87eBz+lYeOk
EcEVf10coFEN1xWnT1Iq4fT/VfAibL2CryJaUBjNQ6IXDNZ4kxO/NYMeYUZIZuLeC7EGViO3X7E4
jxY7BYqaEyx6yvSayXkCPDn8umS7K9rhjCzGtxe1xizN3czPHFrkCo6HH+ZuZMUSg/I4vKVxIK4+
m7TJhqXmkZXbfI9lcusuQJB88HgWQMd3sn5srNaEvAIWq0JolvstISM/klQtvadaRzthX+Gu8eXD
iJtyDUuCdj2zRgLOStU6fXLBziHd4SeiKcEaMBTYXGeJ4baZhrGRHy7IYvC8RhE8Nyt12pFfahae
gqFVOxzn0VqszHZSYNyGmsROAtL3TWD846d1cEymSSdnUVO8/HVos5kq1E+pGKUWP9fDjwBLlFcg
B3+Y35lUuBLdkKUIhDi/UkmEsGjYer7F3An9yXksngGXCiAkGHY1VAcbNvCaQA3zcS7T8VHrg1fW
f60jCT4talMN2NtOyg4AaThLiKy1fe7GED8PbCPjsmU4ZUF9aoejcH+4y1A9Xi0b4N+UNdPjQfae
T0C2cWlPu+lWDnBt+QMn9aG4WMX3eGEopYGOhaGbQXeA93A1ZjXyGEJANCf3cdkW7WGvqb7gf1nF
JMlzAEcizJ7EC/ha4+6s9z7cLA75sm+yL+37yA3QdQWw2dixELw/rhZcE06vukTTADMUu8AXFkdZ
zMNjgnN4WmV7DulvPRWhgz5razhVd/43JPZ/OtbYapnR3nSjIvQMby/EV84FY3rM/f3oRXFVfxTi
s/ulTxrxlxavej1kYdC5MvDDQ7sYkMMp9dQ8vwYLvhDBrB8X4gk8twe4nQryZzDcuziM+Gk2sIyV
FqpRocASCzPw9URT9knvxDjR4VFa+i0jxkclvkKZiFFzQgAMBvGpDQMr0edGYUQmUOUhEGrxtcEc
tkn44MOl4VVo2o4+IomfJlFUJiU6TF+bpJpcEf5L6IbT/B/HSlRikeREvhvlzIGwF2RSWwnRasGe
CJA82lRn3zpCjx2S+OTwzwZsZqdoCHiLjzCt74ErlElcYYWoSNQEItDnkl+uwMfqF54S56npDXfM
PeJO7lyYzhaPPDukBtaoPcmk16D9LgaVoLIAsdjhnf3eCf2RutPrYWcw5WOhWyhpHSfPdfxTSJnt
7l0bKLCK/8GWav0h9fhS0mTcFpBMZCTg1ZZrgNgwUVOyG6lBiv9UEfA/RNDOAri4mDwo7c7VkimZ
ChhEIbAL7g0F6ZiARrQ6tqMzF9STHthumqA35N2wio6A7ky43gNu4okS4FKq/QsoOY+wz+meurzF
ZWT49z55LflFb7J0WfrS7SciBF1WL5MkBMcXD9d7CNxdWIfqCTPQb8o7POhh4ULsO/ZdD8AHteK7
MTFAMBsGCSqGSIb3DQEJFDEOHgwAYgBhAGgAaQB0AGgwIQYJKoZIhvcNAQkVMRQEElRpbWUgMTc5
NDE3NTg3NDEwOTCCA+EGCSqGSIb3DQEHBqCCA9IwggPOAgEAMIIDxwYJKoZIhvcNAQcBMGYGCSqG
SIb3DQEFDTBZMDgGCSqGSIb3DQEFDDArBBQxyBC4WwnR8rtmo5Lamk+0Hu6W9AICJxACASAwDAYI
KoZIhvcNAgkFADAdBglghkgBZQMEASoEEPcyBhQeTSxs3MDBMzQKRISAggNQTZU8J9svxroMhoR9
3Qy6kSNANwfrhqmMwvD0gEPizxrJVJHQDlrVEISF3zP/dGzhqgsPFmZVI9WDf6HBlW14ggXZj6NO
Mt67oH3euHV3UIQdGkBSxi9Aq0/5b+T44jkvJwhm3AizSW5fLYikI05rKUZO/cd/4wmwV3E1uJpU
3ms0eQyhhQwACkktPMundphiXnZhfQ8d0BBMPCoEsr946RWNxmBwx734nYh4oldvhjUc1bBbbmVz
GCpwjkR+iMrTidDxyFq3y8OAh+CH3P0tCLUUghDFsZOzcRd0ihyYIf9dRIue3EFXKA2WMDeYg7ge
gbnQvu1CZ/TFZ0t8Z/ZVYlXSpx12nvOSm1zVZXent2HiF2NR7SsCIXM4rOB8PLj34n9D/GuMsU3C
pPuCmtk6goewu1RCH1VovZrn3b7rciU5rqO40gxFWE4vZOhig9ATAfDR/lxNrxQJLA4JOGPeU8bq
KsxY5Xc+gVKOv5BpA0yXSbbgIMEqN4TbTYZYOEhpLAiS6UYmFBUE2d20Jp6c8wuFz+xno0tSqTlJ
PXVd+1ev+ItGRpwBeuTNRVl2n1yk2Ni7TaHcRh7c8Wm6eglVH8lldVy4e6RpcF+4dMrbCHEeiuyg
XIqZ/C94HLfy4TtxMF0r1H1IfDbiP1XZ/Lo0AMNxnvGVb9y/YdAtsHED87dxbUB7uQWBUzaRj0Vh
RWQ/5RVxvrYi+vzR4gxsElOI1KDn2RQBqsUVn8M8Ca2qUyDuFck6/cFTpXBS0LXp13bInJYCB3Mh
zSPaTMC1TB/+G05s9yBxC9ARJJPvkLRcCFOoq2xS8iJKRNINNe4WW0yByByHhtIVcTggyuMLISK8
C/X99m4TYLQe46nb+a8QO036Uf+7xybiFsTiSFf+tmcwF+I/6VCJLfsftHUzOMMlhGJ14i5OwTPV
Gp+P/5hI4eMy2XIYFmHTupkdhsgWI9xmC6sl+jJiot74A3I5FYRChxwG+8QYybYOT8xqnICb1MbN
PINZmPOHE0rpLbi2in15at6yxT3mvLu1GnV0zeSOoq9cg83+ndjkauBMBXjA7/vNGll2JhSrVyIJ
YcRVhGIJlGxgccon9iOdRTt91tdfQ2a4fybSLyO5LM1DGB3E/PAwTTAxMA0GCWCGSAFlAwQCAQUA
BCAZJQQnZAejcx+/apw04xc2ElvFfERRUrH12CzJ8zj/eAQUpj23RRNuPmbpWLWcSdIkXGzvwe8C
AicQ
__B64__
mkdir -p "$(dirname "app/src/main/AndroidManifest.xml")"
cat > "app/src/main/AndroidManifest.xml" <<'__EOF__'
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE_DATA_SYNC" />
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS" />

    <application
        android:allowBackup="true"
        android:label="باحث PDF"
        android:icon="@mipmap/ic_launcher"
        android:roundIcon="@mipmap/ic_launcher"
        android:supportsRtl="true"
        android:largeHeap="true"
        android:theme="@android:style/Theme.Material.Light.NoActionBar">
        <service
            android:name=".IndexService"
            android:exported="false"
            android:foregroundServiceType="dataSync" />
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:windowSoftInputMode="adjustResize">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
            <intent-filter>
                <action android:name="android.intent.action.VIEW" />
                <category android:name="android.intent.category.DEFAULT" />
                <category android:name="android.intent.category.BROWSABLE" />
                <data android:mimeType="application/pdf" />
            </intent-filter>
            <intent-filter>
                <action android:name="android.intent.action.SEND" />
                <category android:name="android.intent.category.DEFAULT" />
                <data android:mimeType="application/pdf" />
            </intent-filter>
            <intent-filter>
                <action android:name="android.intent.action.SEND_MULTIPLE" />
                <category android:name="android.intent.category.DEFAULT" />
                <data android:mimeType="application/pdf" />
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

/** خيارات توحيد الحروف في البحث (تُغيَّر من الإعدادات). */
object ArabicOpts {
    @Volatile var taMarbuta = true
    @Volatile var alefMaksura = true
    @Volatile var hamza = true
}

object Arabic {

    class Norm(val text: String, val map: IntArray)

    private fun fold(c: Char, d: Boolean): Char = when (c) {
        'أ', 'إ', 'آ', 'ٱ' -> if (d || ArabicOpts.hamza) 'ا' else c
        'ئ' -> if (d || ArabicOpts.hamza) 'ي' else c
        'ؤ' -> if (d || ArabicOpts.hamza) 'و' else c
        'ى' -> if (d || ArabicOpts.alefMaksura) 'ي' else c
        'ة' -> if (d || ArabicOpts.taMarbuta) 'ه' else c
        'ۃ', 'ۀ', 'ھ' -> 'ه'
        'ی' -> 'ي'
        'ک' -> 'ك'
        else -> c
    }

    /** يزيل التشكيل والتطويل، يوحّد الهمزات والألف المقصورة والتاء المربوطة، ويحوّل علامات الترقيم إلى مسافات. */
    fun normalizeMapped(s: String, defaults: Boolean = false): Norm {
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
            c = fold(c, defaults)
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

    /** يزيل التشكيل والتطويل فقط (للعرض). */
    fun stripTashkeel(s: String): String {
        val sb = StringBuilder(s.length)
        for (c in s) {
            if (Character.getType(c) == Character.NON_SPACING_MARK.toInt() || c == 'ـ') continue
            sb.append(c)
        }
        return sb.toString()
    }

    fun letterCount(s: String): Int = s.count { it.isLetter() }

    private val COMMON = setOf(
        "في", "من", "علي", "عن", "الي", "الله", "قال", "ان", "ما", "لا", "هذا", "التي", "الذي",
        "بن", "ابي", "النبي", "رسول", "كان", "ثم", "او", "قد", "كل", "اذا", "لم", "انه", "عليه",
        "وسلم", "حدثنا", "هو", "به", "ذلك", "فقال", "وقال", "ابن", "اللهم", "هي", "وهو", "مع"
    )

    /** يكتشف النص التالف المستخرج من ملف PDF (حروف ناقصة أو كلمات معكوسة). */
    fun looksCorrupted(raw: String): Boolean {
        val norm = normalizeMapped(raw, true).text
        if (norm.contains("ملسو هيلع")) return true
        val toks = norm.split(' ').filter { t -> t.any { it in '\u0621'..'\u064A' } }
        if (toks.size < 25) return false
        val singles = toks.count { it.length == 1 }.toDouble() / toks.size
        val common = toks.count { it in COMMON }.toDouble() / toks.size
        return singles > 0.12 || common < 0.025
    }

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
import androidx.room.migration.Migration
import androidx.sqlite.db.SupportSQLiteDatabase
import androidx.sqlite.db.SupportSQLiteQuery
import kotlinx.coroutines.flow.Flow

const val ST_QUEUED = 0
const val ST_INDEXING = 1
const val ST_DONE = 2
const val ST_ERROR = 3
const val ST_REFINING = 4

@Entity(tableName = "books")
data class BookEntity(
    @PrimaryKey(autoGenerate = true) val id: Long = 0,
    val title: String,
    val pageCount: Int = 0,
    val indexedPages: Int = 0,
    val status: Int = ST_QUEUED,
    val addedAt: Long = System.currentTimeMillis(),
    val author: String = "",
    val favorite: Boolean = false,
    val lastPage: Int = 1
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

data class IdText(val id: Long, val text: String)

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

    @Query("SELECT * FROM books WHERE status = 0 OR status = 1 OR status = 4")
    abstract suspend fun unfinished(): List<BookEntity>

    @Insert
    abstract suspend fun insertBook(b: BookEntity): Long

    @Insert
    abstract suspend fun insertPages(p: List<PageEntity>)

    @Query("UPDATE books SET title = :title, author = :author WHERE id = :id")
    abstract suspend fun updateInfo(id: Long, title: String, author: String)

    @Query("UPDATE books SET favorite = :fav WHERE id = :id")
    abstract suspend fun setFavorite(id: Long, fav: Boolean)

    @Query("UPDATE books SET lastPage = :page WHERE id = :id")
    abstract suspend fun setLastPage(id: Long, page: Int)

    @Query("SELECT * FROM books")
    abstract suspend fun allBooks(): List<BookEntity>

    @Query("DELETE FROM pages")
    abstract suspend fun deleteAllPages()

    @Query("DELETE FROM books")
    abstract suspend fun deleteAllBooks()

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

    @Query("UPDATE pages SET text = :text, norm = :norm WHERE bookId = :bookId AND pageNo = :pageNo")
    abstract suspend fun updatePage(bookId: Long, pageNo: Int, text: String, norm: String)

    @Query("SELECT id, text FROM pages WHERE id > :after ORDER BY id LIMIT :n")
    abstract suspend fun textBatch(after: Long, n: Int): List<IdText>

    @Query("UPDATE pages SET norm = :norm WHERE id = :id")
    abstract suspend fun setNorm(id: Long, norm: String)

    @Transaction
    open suspend fun updateMany(items: List<PageEntity>) {
        for (e in items) updatePage(e.bookId, e.pageNo, e.text, e.norm)
    }

    @Transaction
    open suspend fun renormBatch(items: List<IdText>) {
        for (e in items) setNorm(e.id, Arabic.normalize(e.text))
    }

    @Transaction
    open suspend fun deleteBookFully(id: Long) {
        deletePages(id)
        deleteBook(id)
    }

    @RawQuery
    abstract suspend fun search(query: SupportSQLiteQuery): List<SearchRow>
}

val MIGRATION_1_2 = object : Migration(1, 2) {
    override fun migrate(db: SupportSQLiteDatabase) {
        db.execSQL("ALTER TABLE books ADD COLUMN author TEXT NOT NULL DEFAULT ''")
        db.execSQL("ALTER TABLE books ADD COLUMN favorite INTEGER NOT NULL DEFAULT 0")
        db.execSQL("ALTER TABLE books ADD COLUMN lastPage INTEGER NOT NULL DEFAULT 1")
    }
}

@Database(
    entities = [BookEntity::class, PageEntity::class, PageFts::class],
    version = 2,
    exportSchema = false
)
abstract class AppDb : RoomDatabase() {
    abstract fun dao(): BookDao

    companion object {
        @Volatile
        private var inst: AppDb? = null

        fun get(ctx: Context): AppDb = inst ?: synchronized(this) {
            inst ?: Room.databaseBuilder(ctx.applicationContext, AppDb::class.java, "bahith.db")
                .addMigrations(MIGRATION_1_2)
                .build().also { inst = it }
        }
    }
}
__EOF__
mkdir -p "$(dirname "app/src/main/java/com/bahith/pdf/MainActivity.kt")"
cat > "app/src/main/java/com/bahith/pdf/MainActivity.kt" <<'__EOF__'
package com.bahith.pdf

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.viewModels

class MainActivity : ComponentActivity() {
    private val vm: AppViewModel by viewModels()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        if (savedInstanceState == null) handleIntent(intent)
        setContent { App(vm) }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        handleIntent(intent)
    }

    @Suppress("DEPRECATION")
    private fun handleIntent(i: Intent?) {
        if (i == null) return
        val uris = ArrayList<Uri>()
        when (i.action) {
            Intent.ACTION_VIEW -> i.data?.let { uris.add(it) }
            Intent.ACTION_SEND -> i.getParcelableExtra<Uri>(Intent.EXTRA_STREAM)?.let { uris.add(it) }
            Intent.ACTION_SEND_MULTIPLE ->
                i.getParcelableArrayListExtra<Uri>(Intent.EXTRA_STREAM)?.let { uris.addAll(it) }
        }
        if (uris.isNotEmpty()) {
            vm.tab = 0
            vm.importUris(uris)
        }
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
import kotlinx.coroutines.async
import kotlinx.coroutines.awaitAll
import kotlinx.coroutines.channels.Channel
import kotlinx.coroutines.coroutineScope
import kotlinx.coroutines.currentCoroutineContext
import kotlinx.coroutines.ensureActive
import kotlinx.coroutines.sync.Mutex
import kotlinx.coroutines.sync.Semaphore
import kotlinx.coroutines.sync.withLock
import kotlinx.coroutines.sync.withPermit
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

/**
 * extractMode: 0 = تلقائي (يكتشف النص التالف ويستخدم OCR)، 1 = OCR لكل الصفحات، 2 = نص PDF فقط.
 * workers: عدد معالجات OCR المتوازية. ocrWidth: عرض الصورة بالبكسل للـ OCR.
 * bestModel: استعمال نموذج OCR الأدق (أبطأ). ignoreMarks: تجاهل التشكيل أثناء القراءة لدقة الحروف.
 */
data class IndexOptions(
    val extractMode: Int,
    val workers: Int,
    val ocrWidth: Int,
    val bestModel: Boolean,
    val ignoreMarks: Boolean
)

private const val MARKS = "\u064B\u064C\u064D\u064E\u064F\u0650\u0651\u0652\u0670"

/** مجموعة محركات Tesseract للعمل المتوازي. */
class OcrPool(ctx: Context, size: Int, best: Boolean, ignoreMarks: Boolean) {
    private val channel = Channel<TessBaseAPI>(Channel.UNLIMITED)
    private val all = ArrayList<TessBaseAPI>()
    val available: Boolean

    private fun hasAsset(ctx: Context, name: String): Boolean =
        try {
            ctx.assets.open(name).close()
            true
        } catch (e: Exception) {
            false
        }

    init {
        var ok = false
        try {
            val useBest = best && hasAsset(ctx, "tessdata/ara_best.traineddata")
            val folder = if (useBest) "tess_best" else "tess"
            val assetName = if (useBest) "tessdata/ara_best.traineddata" else "tessdata/ara.traineddata"
            val root = File(ctx.filesDir, folder)
            val td = File(root, "tessdata")
            td.mkdirs()
            val f = File(td, "ara.traineddata")
            if (!f.exists() || f.length() == 0L) {
                ctx.assets.open(assetName).use { i ->
                    f.outputStream().use { o -> i.copyTo(o) }
                }
            }
            repeat(size) {
                val api = TessBaseAPI()
                if (api.init(root.absolutePath, "ara")) {
                    if (ignoreMarks) api.setVariable("tessedit_char_blacklist", MARKS)
                    all.add(api)
                    channel.trySend(api)
                } else {
                    api.recycle()
                }
            }
            ok = all.isNotEmpty()
        } catch (e: Exception) {
            ok = all.isNotEmpty()
        }
        available = ok
    }

    suspend fun recognize(bmp: Bitmap): String {
        val api = channel.receive()
        return try {
            api.setImage(bmp)
            api.getUTF8Text() ?: ""
        } catch (e: Exception) {
            ""
        } finally {
            channel.trySend(api)
        }
    }

    fun close() {
        for (a in all) {
            try { a.recycle() } catch (_: Exception) {}
        }
        all.clear()
    }
}

class Indexer(private val ctx: Context, private val dao: BookDao) {

    init {
        PDFBoxResourceLoader.init(ctx.applicationContext)
    }

    private suspend fun ocrPage(s: PdfSource, index: Int, width: Int, pool: OcrPool): String {
        val bmp = s.render(index, width) ?: return ""
        return try {
            pool.recognize(bmp)
        } finally {
            bmp.recycle()
        }
    }

    private fun readPending(f: File): MutableList<Int> =
        try {
            if (f.exists()) f.readText().split(",").mapNotNull { it.trim().toIntOrNull() }.toMutableList()
            else mutableListOf()
        } catch (e: Exception) {
            mutableListOf()
        }

    private fun writePending(f: File, list: List<Int>) {
        try { f.writeText(list.joinToString(",")) } catch (_: Exception) {}
    }

    /** قراءة صفحة واحدة بأدق إعدادات (للإصلاح اليدوي). */
    suspend fun ocrOne(bookId: Long, pageNo: Int, ignoreMarks: Boolean): String {
        val file = File(ctx.filesDir, "books/$bookId.pdf")
        if (!file.exists()) return ""
        val s = PdfSource(file)
        val pool = OcrPool(ctx, 1, true, ignoreMarks)
        return try {
            if (!pool.available) "" else ocrPage(s, pageNo - 1, 2400, pool)
        } finally {
            pool.close()
            s.close()
        }
    }

    /**
     * المرحلة 1: فهرسة سريعة من نص الملف (يصبح البحث متاحاً خلال دقائق).
     * المرحلة 2: تحسين الصفحات التالفة بالـ OCR في الخلفية.
     */
    suspend fun index(bookId: Long, forceOcr: Boolean, restart: Boolean, opts: IndexOptions) {
        val book = dao.getBook(bookId) ?: return
        if (book.status == ST_DONE && !forceOcr && !restart) return
        val file = File(ctx.filesDir, "books/$bookId.pdf")
        if (!file.exists()) {
            dao.setStatus(bookId, ST_ERROR)
            return
        }
        val pendingFile = File(ctx.filesDir, "books/$bookId.pending")
        val reset = forceOcr || restart
        val resumePhase2 = !reset && book.status == ST_REFINING
        val workers = opts.workers.coerceIn(1, 6)

        var src: PdfSource? = null
        var doc: PDDocument? = null
        var pool: OcrPool? = null
        var poolTried = false

        fun ensurePool(): OcrPool? {
            if (!poolTried) {
                poolTried = true
                val p = OcrPool(ctx, workers, opts.bestModel, opts.ignoreMarks)
                if (p.available) pool = p else p.close()
            }
            return pool
        }

        try {
            val s = PdfSource(file)
            src = s
            val total = s.pageCount
            val textOnly = !forceOcr && opts.extractMode == 2
            val allOcr = forceOcr || opts.extractMode == 1

            if (!resumePhase2) {
                if (reset) {
                    dao.deletePages(bookId)
                    pendingFile.delete()
                }
                val done = if (reset) 0 else book.indexedPages
                dao.setProgress(bookId, done, ST_INDEXING)
                doc = try {
                    PDDocument.load(file, MemoryUsageSetting.setupMixed(64L * 1024 * 1024))
                } catch (e: Exception) {
                    null
                }
                val stripper = PDFTextStripper()
                stripper.setSortByPosition(true)
                val pending = readPending(pendingFile)
                var p = done + 1
                val chunk = 25
                while (p <= total) {
                    currentCoroutineContext().ensureActive()
                    val end = minOf(total, p + chunk - 1)
                    val list = ArrayList<PageEntity>(end - p + 1)
                    for (i in p..end) {
                        var t = ""
                        val d = doc
                        if (d != null) {
                            t = try {
                                stripper.setStartPage(i)
                                stripper.setEndPage(i)
                                Normalizer.normalize(stripper.getText(d), Normalizer.Form.NFKC)
                            } catch (e: Exception) {
                                ""
                            }
                        }
                        val flagged = allOcr ||
                            (!textOnly && (Arabic.letterCount(t) < 15 || Arabic.looksCorrupted(t)))
                        if (flagged) pending.add(i)
                        val tt = t.trim()
                        list.add(PageEntity(bookId = bookId, pageNo = i, text = tt, norm = Arabic.normalize(tt)))
                    }
                    dao.insertPages(list)
                    writePending(pendingFile, pending)
                    dao.setProgress(bookId, end, ST_INDEXING)
                    p = end + 1
                }
                try { doc?.close() } catch (_: Exception) {}
                doc = null
            }

            val queue = readPending(pendingFile).distinct().sorted().toMutableList()
            if (textOnly || queue.isEmpty()) {
                pendingFile.delete()
                dao.setProgress(bookId, total, ST_DONE)
                return
            }

            dao.setProgress(bookId, total, ST_REFINING)
            Work.refineLeft[bookId] = queue.size
            val sem = Semaphore(workers)
            val batchSize = maxOf(4, workers * 2)
            while (queue.isNotEmpty()) {
                currentCoroutineContext().ensureActive()
                val pl = ensurePool() ?: break
                val batch = queue.take(batchSize)
                val results = coroutineScope {
                    batch.map { page ->
                        async(Dispatchers.Default) {
                            sem.withPermit { page to ocrPage(s, page - 1, opts.ocrWidth, pl) }
                        }
                    }.awaitAll()
                }
                val ents = ArrayList<PageEntity>()
                for ((page, r) in results) {
                    if (r.isNotBlank()) {
                        val t = r.trim()
                        ents.add(PageEntity(bookId = bookId, pageNo = page, text = t, norm = Arabic.normalize(t)))
                    }
                }
                if (ents.isNotEmpty()) dao.updateMany(ents)
                repeat(batch.size) { queue.removeAt(0) }
                writePending(pendingFile, queue)
                Work.refineLeft[bookId] = queue.size
            }
            pendingFile.delete()
            Work.refineLeft.remove(bookId)
            dao.setProgress(bookId, total, ST_DONE)
        } catch (e: CancellationException) {
            throw e
        } catch (e: Throwable) {
            Work.refineLeft.remove(bookId)
            dao.setStatus(bookId, ST_ERROR)
        } finally {
            try { doc?.close() } catch (_: Exception) {}
            src?.close()
            pool?.close()
        }
    }
}
__EOF__
mkdir -p "$(dirname "app/src/main/java/com/bahith/pdf/Service.kt")"
cat > "app/src/main/java/com/bahith/pdf/Service.kt" <<'__EOF__'
package com.bahith.pdf

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.os.Build
import android.os.IBinder
import androidx.core.content.ContextCompat
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.launch
import kotlinx.coroutines.sync.Mutex
import androidx.compose.runtime.mutableStateMapOf
import java.util.concurrent.ConcurrentHashMap

/** مكان واحد لأعمال الفهرسة، يبقى حياً حتى لو أُغلقت الشاشة. */
object Work {
    val scope = CoroutineScope(SupervisorJob() + Dispatchers.Default)
    val lock = Mutex()
    val jobs = ConcurrentHashMap<Long, Job>()

    /** عدد الصفحات المتبقية لتحسين نصها بالـ OCR، لكل كتاب. */
    val refineLeft = mutableStateMapOf<Long, Int>()

    @Volatile
    private var idx: Indexer? = null

    fun indexer(ctx: Context): Indexer = idx ?: synchronized(this) {
        idx ?: Indexer(ctx.applicationContext, AppDb.get(ctx).dao()).also { idx = it }
    }
}

/** خدمة أمامية تُبقي التطبيق يعمل أثناء الفهرسة، وتتوقف وحدها عند الانتهاء. */
class IndexService : Service() {
    private var watcher: Job? = null

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val mgr = getSystemService(NotificationManager::class.java)
        mgr.createNotificationChannel(
            NotificationChannel("index", "الفهرسة", NotificationManager.IMPORTANCE_LOW)
        )
        val n = Notification.Builder(this, "index")
            .setContentTitle("باحث PDF")
            .setContentText("جارٍ فهرسة الكتب…")
            .setSmallIcon(android.R.drawable.stat_notify_sync)
            .setOngoing(true)
            .build()
        try {
            if (Build.VERSION.SDK_INT >= 29) {
                startForeground(1, n, ServiceInfo.FOREGROUND_SERVICE_TYPE_DATA_SYNC)
            } else {
                startForeground(1, n)
            }
        } catch (e: Exception) {
            stopSelf()
            return START_NOT_STICKY
        }
        if (watcher == null) {
            val dao = AppDb.get(this).dao()
            watcher = Work.scope.launch {
                dao.observeBooks().collect { list ->
                    val busy = list.any {
                        it.status == ST_QUEUED || it.status == ST_INDEXING || it.status == ST_REFINING
                    }
                    if (!busy) stopSelf()
                }
            }
        }
        return START_NOT_STICKY
    }

    override fun onDestroy() {
        watcher?.cancel()
        watcher = null
        super.onDestroy()
    }

    companion object {
        fun start(ctx: Context) {
            try {
                ContextCompat.startForegroundService(ctx, Intent(ctx, IndexService::class.java))
            } catch (e: Exception) {
                // إن منع النظام الخدمة نكمل الفهرسة داخل التطبيق فقط
            }
        }
    }
}
__EOF__
mkdir -p "$(dirname "app/src/main/java/com/bahith/pdf/Ui.kt")"
cat > "app/src/main/java/com/bahith/pdf/Ui.kt" <<'__EOF__'
@file:OptIn(ExperimentalMaterial3Api::class)

package com.bahith.pdf

import android.graphics.Bitmap
import android.content.Intent
import android.os.Build
import android.speech.tts.TextToSpeech
import android.widget.Toast
import androidx.activity.compose.BackHandler
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.*
import androidx.compose.foundation.gestures.detectTapGestures
import androidx.compose.foundation.gestures.detectTransformGestures
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.*
import androidx.compose.foundation.pager.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardActions
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.Close
import androidx.compose.material.icons.filled.Favorite
import androidx.compose.material.icons.filled.FavoriteBorder
import androidx.compose.material.icons.filled.Home
import androidx.compose.material.icons.filled.MoreVert
import androidx.compose.material.icons.filled.Search
import androidx.compose.material.icons.filled.Settings
import androidx.compose.material3.*
import androidx.compose.runtime.*
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
import androidx.compose.ui.platform.LocalClipboardManager
import androidx.compose.ui.platform.LocalConfiguration
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.platform.LocalLayoutDirection
import androidx.compose.ui.platform.LocalView
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
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.lifecycle.viewmodel.compose.viewModel
import java.util.Locale
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import java.io.File

val MARK_COLORS = listOf(Color(0xFFFFD54F), Color(0xFFA5D6A7), Color(0xFFF48FB1), Color(0xFF90CAF9))

fun markColor(i: Int): Color = MARK_COLORS[i.coerceIn(0, MARK_COLORS.size - 1)]

@Composable
fun AppTheme(dark: Boolean, content: @Composable () -> Unit) {
    val scheme = if (dark) {
        darkColorScheme(
            primary = Color(0xFFE2C29B),
            onPrimary = Color(0xFF2B1B0E),
            primaryContainer = Color(0xFF3A2D22),
            onPrimaryContainer = Color(0xFFE2C29B),
            secondaryContainer = Color(0xFF3A2D22),
            onSecondaryContainer = Color(0xFFE2C29B),
            background = Color(0xFF1B1612),
            onBackground = Color(0xFFEDE0D0),
            surface = Color(0xFF1B1612),
            onSurface = Color(0xFFEDE0D0),
            surfaceVariant = Color(0xFF2A221B),
            onSurfaceVariant = Color(0xFFCDBFAE)
        )
    } else {
        lightColorScheme(
            primary = Color(0xFF5A3E2B),
            onPrimary = Color.White,
            primaryContainer = Color(0xFFE9D9C2),
            onPrimaryContainer = Color(0xFF5A3E2B),
            secondaryContainer = Color(0xFFE9D9C2),
            onSecondaryContainer = Color(0xFF5A3E2B),
            background = Color(0xFFFBF6EC),
            surface = Color(0xFFFBF6EC),
            surfaceVariant = Color(0xFFF3EADB)
        )
    }
    MaterialTheme(colorScheme = scheme, content = content)
}

@Composable
fun App(vm: AppViewModel = viewModel()) {
    val dark = when (vm.themeMode) {
        1 -> false
        2 -> true
        else -> isSystemInDarkTheme()
    }
    AppTheme(dark) {
        CompositionLocalProvider(LocalLayoutDirection provides LayoutDirection.Rtl) {
            val books by vm.books.collectAsStateWithLifecycle()
            val view = LocalView.current
            val busy = books.any {
                it.status == ST_QUEUED || it.status == ST_INDEXING || it.status == ST_REFINING
            }
            val reading = vm.reader != null
            LaunchedEffect(busy, vm.keepAwake, reading, vm.keepAwakeRead) {
                view.keepScreenOn = (busy && vm.keepAwake) || (reading && vm.keepAwakeRead)
            }

            val notifLauncher = rememberLauncherForActivityResult(
                ActivityResultContracts.RequestPermission()
            ) { }
            LaunchedEffect(Unit) {
                if (Build.VERSION.SDK_INT >= 33) {
                    notifLauncher.launch(android.Manifest.permission.POST_NOTIFICATIONS)
                }
            }

            val picker = rememberLauncherForActivityResult(
                ActivityResultContracts.OpenMultipleDocuments()
            ) { uris -> vm.importUris(uris) }
            val treePicker = rememberLauncherForActivityResult(
                ActivityResultContracts.OpenDocumentTree()
            ) { uri -> if (uri != null) vm.importTree(uri) }
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
                                NavigationBarItem(
                                    selected = vm.tab == 2,
                                    onClick = { vm.tab = 2 },
                                    icon = { Icon(Icons.Default.Settings, null) },
                                    label = { Text("الإعدادات") }
                                )
                            }
                        }
                    ) { pad ->
                        Box(Modifier.padding(pad)) {
                            when (vm.tab) {
                                0 -> LibraryScreen(
                                    vm,
                                    onAdd = { picker.launch(arrayOf("*/*")) },
                                    onAddFolder = { treePicker.launch(null) }
                                )
                                1 -> SearchScreen(vm)
                                else -> SettingsScreen(vm)
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
fun LibraryScreen(vm: AppViewModel, onAdd: () -> Unit, onAddFolder: () -> Unit) {
    val books by vm.books.collectAsStateWithLifecycle()
    var editing by remember { mutableStateOf<BookEntity?>(null) }
    var deleting by remember { mutableStateOf<BookEntity?>(null) }
    val shown = remember(books, vm.libraryFilter, vm.sortOrder, vm.libFavOnly) {
        arrangeBooks(books, vm.libraryFilter, vm.sortOrder).filter { !vm.libFavOnly || it.favorite }
    }

    Scaffold(
        topBar = {
            CenterAlignedTopAppBar(
                title = { Text("باحث PDF") },
                actions = { TextButton(onClick = onAddFolder) { Text("إضافة مجلد") } }
            )
        },
        floatingActionButton = {
            ExtendedFloatingActionButton(
                onClick = onAdd,
                icon = { Icon(Icons.Default.Add, null) },
                text = { Text("إضافة كتاب") }
            )
        }
    ) { pad ->
        Column(Modifier.padding(pad).fillMaxSize()) {
            if (vm.importTotal > 0) {
                Column(Modifier.fillMaxWidth().padding(horizontal = 16.dp, vertical = 4.dp)) {
                    LinearProgressIndicator(
                        progress = { vm.importDone.toFloat() / vm.importTotal },
                        modifier = Modifier.fillMaxWidth()
                    )
                    Text(
                        "جارٍ إضافة الكتب… ${vm.importDone} / ${vm.importTotal}",
                        style = MaterialTheme.typography.labelMedium
                    )
                }
            }
            if (books.isNotEmpty()) {
                OutlinedTextField(
                    value = vm.libraryFilter,
                    onValueChange = { vm.libraryFilter = it },
                    modifier = Modifier.fillMaxWidth().padding(horizontal = 16.dp),
                    placeholder = { Text("ابحث في عناوين الكتب والمؤلفين") },
                    leadingIcon = { Icon(Icons.Default.Search, null) },
                    trailingIcon = {
                        if (vm.libraryFilter.isNotEmpty()) {
                            IconButton(onClick = { vm.libraryFilter = "" }) {
                                Icon(Icons.Default.Close, "مسح")
                            }
                        }
                    },
                    singleLine = true,
                    shape = RoundedCornerShape(24.dp)
                )
                Row(
                    Modifier.horizontalScroll(rememberScrollState())
                        .padding(horizontal = 16.dp, vertical = 4.dp),
                    horizontalArrangement = Arrangement.spacedBy(8.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Text("${books.size} كتاب", style = MaterialTheme.typography.labelLarge)
                    FilterChip(
                        selected = vm.libFavOnly,
                        onClick = { vm.libFavOnly = !vm.libFavOnly },
                        label = { Text("المفضلة فقط") }
                    )
                    listOf("الأحدث", "الاسم", "المفضلة أولاً").forEachIndexed { i, s ->
                        FilterChip(
                            selected = vm.sortOrder == i,
                            onClick = { vm.updateSort(i) },
                            label = { Text(s) }
                        )
                    }
                }
            }
            if (books.isEmpty()) {
                Box(Modifier.fillMaxSize().padding(32.dp), contentAlignment = Alignment.Center) {
                    Text(
                        "مكتبتك فارغة.\nاضغط «إضافة كتاب» لاختيار ملفات PDF من هاتفك.",
                        textAlign = TextAlign.Center,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                }
            } else if (shown.isEmpty()) {
                Box(Modifier.fillMaxSize().padding(32.dp), contentAlignment = Alignment.Center) {
                    Text("لا توجد كتب مطابقة", color = MaterialTheme.colorScheme.onSurfaceVariant)
                }
            } else {
                LazyColumn(
                    Modifier.fillMaxSize(),
                    contentPadding = PaddingValues(16.dp, 8.dp, 16.dp, 96.dp),
                    verticalArrangement = Arrangement.spacedBy(10.dp)
                ) {
                    items(shown, key = { it.id }) { b ->
                        BookCard(b, vm, onEdit = { editing = b }, onDelete = { deleting = b })
                    }
                }
            }
        }
    }

    editing?.let { b ->
        EditBookDialog(
            book = b,
            onDismiss = { editing = null },
            onOk = { t, a -> vm.editBook(b.id, t, a); editing = null }
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
fun BookCard(b: BookEntity, vm: AppViewModel, onEdit: () -> Unit, onDelete: () -> Unit) {
    var menu by remember { mutableStateOf(false) }
    Card(
        onClick = {
            if (b.pageCount > 0) {
                vm.reader = ReaderTarget(b.id, b.lastPage.coerceIn(1, b.pageCount), emptyList())
            }
        },
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
                if (b.author.isNotBlank()) {
                    Text(
                        b.author,
                        style = MaterialTheme.typography.bodySmall,
                        color = MaterialTheme.colorScheme.onSurfaceVariant,
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis
                    )
                }
                Spacer(Modifier.height(4.dp))
                when (b.status) {
                    ST_DONE -> {
                        val resume = if (b.lastPage > 1) " • آخر قراءة: صفحة ${b.lastPage}" else ""
                        Text(
                            "${b.pageCount} صفحة • جاهز للبحث$resume",
                            style = MaterialTheme.typography.labelMedium
                        )
                    }
                    ST_REFINING -> {
                        val left = Work.refineLeft[b.id]
                        val frac = if (left != null && b.pageCount > 0) 1f - left.toFloat() / b.pageCount else 0f
                        Text(
                            "${b.pageCount} صفحة • جاهز للبحث • يُحسَّن النص بالـ OCR" +
                                (if (left != null) " (متبقي $left)" else ""),
                            style = MaterialTheme.typography.labelMedium
                        )
                        Spacer(Modifier.height(4.dp))
                        LinearProgressIndicator(progress = { frac }, modifier = Modifier.fillMaxWidth())
                    }
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
            IconButton(onClick = { vm.toggleFavorite(b) }) {
                Icon(
                    if (b.favorite) Icons.Default.Favorite else Icons.Default.FavoriteBorder,
                    "مفضلة",
                    tint = if (b.favorite) MaterialTheme.colorScheme.primary
                    else MaterialTheme.colorScheme.onSurfaceVariant
                )
            }
            Box {
                IconButton(onClick = { menu = true }) { Icon(Icons.Default.MoreVert, "خيارات") }
                DropdownMenu(expanded = menu, onDismissRequest = { menu = false }) {
                    DropdownMenuItem(
                        text = { Text("تعديل العنوان والمؤلف") },
                        onClick = { menu = false; onEdit() }
                    )
                    DropdownMenuItem(
                        text = { Text("إعادة الفهرسة") },
                        onClick = { menu = false; vm.startIndex(b.id, restart = true) }
                    )
                    DropdownMenuItem(
                        text = { Text("إعادة الفهرسة بالـ OCR") },
                        onClick = { menu = false; vm.startIndex(b.id, forceOcr = true) }
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
fun EditBookDialog(book: BookEntity, onDismiss: () -> Unit, onOk: (String, String) -> Unit) {
    var title by remember { mutableStateOf(book.title) }
    var author by remember { mutableStateOf(book.author) }
    AlertDialog(
        onDismissRequest = onDismiss,
        title = { Text("تعديل بيانات الكتاب") },
        text = {
            Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                OutlinedTextField(
                    value = title,
                    onValueChange = { title = it },
                    label = { Text("العنوان") },
                    singleLine = true
                )
                OutlinedTextField(
                    value = author,
                    onValueChange = { author = it },
                    label = { Text("المؤلف (اختياري)") },
                    singleLine = true
                )
            }
        },
        confirmButton = {
            TextButton(onClick = { if (title.isNotBlank()) onOk(title.trim(), author) }) { Text("حفظ") }
        },
        dismissButton = { TextButton(onClick = onDismiss) { Text("إلغاء") } }
    )
}

// ======================= البحث =======================

@Composable
fun SearchScreen(vm: AppViewModel) {
    val books by vm.books.collectAsStateWithLifecycle()
    var showScope by remember { mutableStateOf(false) }

    LaunchedEffect(vm.query) {
        if (vm.liveSearch || vm.query.isBlank()) {
            delay(250)
            vm.search()
        }
    }
    LaunchedEffect(vm.mode, vm.scopeBookId, vm.resultLimit, vm.snippetLen) {
        if (vm.query.isNotBlank()) vm.search()
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
                        IconButton(onClick = { vm.query = ""; vm.search() }) { Icon(Icons.Default.Close, "مسح") }
                    }
                },
                shape = RoundedCornerShape(24.dp),
                maxLines = 4,
                keyboardOptions = KeyboardOptions(imeAction = ImeAction.Search),
                keyboardActions = KeyboardActions(onSearch = {
                    vm.search()
                    vm.addHistory(vm.query)
                })
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
                res.isEmpty() && vm.history.isNotEmpty() && vm.query.isBlank() -> HistoryPane(vm)
                res.isEmpty() -> Box(Modifier.fillMaxSize().padding(32.dp), Alignment.Center) {
                    Text(
                        "ابحث بكلمة أو عبارة. للنص الطويل اختر «عبارة».\nالبحث يتجاهل التشكيل ويوحّد الهمزات.",
                        textAlign = TextAlign.Center,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                }
                else -> {
                    val grouped = res.groupBy { it.bookId }
                    var collapsed by remember(res) { mutableStateOf(setOf<Long>()) }
                    val cap = if (res.size >= vm.resultLimit) "+" else ""
                    Text(
                        "${res.size}$cap نتيجة في ${grouped.size} كتاب",
                        Modifier.padding(horizontal = 16.dp, vertical = 4.dp),
                        style = MaterialTheme.typography.labelMedium
                    )
                    LazyColumn(
                        Modifier.fillMaxSize(),
                        contentPadding = PaddingValues(16.dp, 4.dp, 16.dp, 24.dp),
                        verticalArrangement = Arrangement.spacedBy(8.dp)
                    ) {
                        grouped.forEach { (bid, hits) ->
                            val open = !collapsed.contains(bid)
                            item {
                                Row(
                                    Modifier.fillMaxWidth()
                                        .clickable { collapsed = if (open) collapsed + bid else collapsed - bid }
                                        .padding(top = 8.dp),
                                    verticalAlignment = Alignment.CenterVertically
                                ) {
                                    Text(
                                        hits.first().title + "  (" + hits.size + ")",
                                        fontWeight = FontWeight.Bold,
                                        color = MaterialTheme.colorScheme.primary,
                                        modifier = Modifier.weight(1f)
                                    )
                                    Text(if (open) "▾" else "◂", color = MaterialTheme.colorScheme.primary)
                                }
                            }
                            if (open) {
                                items(hits) { h -> HitCard(h, markColor(vm.highlightIdx)) { vm.openHit(h) } }
                            }
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
fun HistoryPane(vm: AppViewModel) {
    Column(Modifier.fillMaxSize().padding(horizontal = 16.dp)) {
        Row(
            Modifier.fillMaxWidth(),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.SpaceBetween
        ) {
            Text("عمليات بحث سابقة", fontWeight = FontWeight.Bold)
            TextButton(onClick = { vm.clearHistory() }) { Text("مسح") }
        }
        LazyColumn(Modifier.fillMaxSize()) {
            items(vm.history) { q -> ScopeRow(q) { vm.query = q } }
        }
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

fun highlighted(text: String, ranges: List<IntRange>, color: Color = MARK_COLORS[0]): AnnotatedString = buildAnnotatedString {
    append(text)
    for (r in ranges) {
        val s = r.first.coerceIn(0, text.length)
        val e = (r.last + 1).coerceIn(s, text.length)
        if (e > s) addStyle(SpanStyle(background = color, color = Color.Black), s, e)
    }
}

@Composable
fun HitCard(h: Hit, color: Color, onClick: () -> Unit) {
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
                highlighted(h.snippet, h.ranges, color),
                style = MaterialTheme.typography.bodyMedium,
                lineHeight = 24.sp
            )
        }
    }
}

// ======================= الإعدادات =======================

@Composable
fun SettingsCard(title: String, content: @Composable ColumnScope.() -> Unit) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surfaceVariant)
    ) {
        Column(Modifier.padding(16.dp), verticalArrangement = Arrangement.spacedBy(10.dp)) {
            Text(
                title,
                style = MaterialTheme.typography.titleMedium,
                fontWeight = FontWeight.Bold,
                color = MaterialTheme.colorScheme.primary
            )
            content()
        }
    }
}

@Composable
fun SwitchRow(label: String, checked: Boolean, onChange: (Boolean) -> Unit) {
    Row(Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
        Text(label, Modifier.weight(1f))
        Switch(checked = checked, onCheckedChange = onChange)
    }
}

@Composable
fun ChipRow(options: List<String>, selected: Int, onSelect: (Int) -> Unit) {
    Row(
        Modifier.horizontalScroll(rememberScrollState()),
        horizontalArrangement = Arrangement.spacedBy(8.dp)
    ) {
        options.forEachIndexed { i, s ->
            FilterChip(selected = selected == i, onClick = { onSelect(i) }, label = { Text(s) })
        }
    }
}

@Composable
fun SettingsScreen(vm: AppViewModel) {
    val books by vm.books.collectAsStateWithLifecycle()
    var confirmDelete by remember { mutableStateOf(false) }
    var confirmReindex by remember { mutableStateOf(false) }
    val storage by produceState("…", books.size) { value = formatSize(vm.storageBytes()) }
    val limits = listOf(100, 400, 1000)

    Scaffold(topBar = { CenterAlignedTopAppBar(title = { Text("الإعدادات") }) }) { pad ->
        Column(
            Modifier.padding(pad).fillMaxSize().verticalScroll(rememberScrollState())
                .padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(14.dp)
        ) {
            SettingsCard("المظهر") {
                ChipRow(listOf("حسب النظام", "فاتح", "داكن"), vm.themeMode) { vm.updateTheme(it) }
                Text("لون تظليل نتائج البحث")
                ChipRow(listOf("أصفر", "أخضر", "وردي", "أزرق"), vm.highlightIdx) { vm.updateHighlight(it) }
                Text("حجم خط القراءة (عرض النص): ${vm.readerFont.toInt()}")
                Slider(
                    value = vm.readerFont,
                    onValueChange = { vm.readerFont = it },
                    onValueChangeFinished = { vm.saveFont() },
                    valueRange = 16f..34f
                )
                Text("تباعد الأسطر: ${"%.1f".format(vm.lineSpacing)}")
                Slider(
                    value = vm.lineSpacing,
                    onValueChange = { vm.lineSpacing = it },
                    onValueChangeFinished = { vm.saveReader() },
                    valueRange = 1.2f..2.4f
                )
                Text("نوع الخط")
                ChipRow(listOf("نسخ", "عادي"), vm.fontStyle) { vm.updateFontStyle(it) }
                SwitchRow("إخفاء التشكيل في عرض النص", vm.hideTashkeel) { vm.updateHideTashkeel(it) }
                SwitchRow("ضبط الفقرات (محاذاة الجانبين)", vm.justify) { vm.updateJustify(it) }
                Text(
                    "بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ",
                    fontSize = vm.readerFont.sp,
                    fontFamily = if (vm.fontStyle == 0) FontFamily.Serif else FontFamily.SansSerif,
                    textAlign = if (vm.justify) TextAlign.Justify else TextAlign.Start
                )
            }

            SettingsCard("القراءة") {
                Text("عند فتح نتيجة بحث")
                ChipRow(listOf("نص الصفحة", "صورة الصفحة"), vm.hitView) { vm.updateHitView(it) }
                SwitchRow("إبقاء الشاشة مفعّلة أثناء القراءة", vm.keepAwakeRead) { vm.updateKeepAwakeRead(it) }
            }

            SettingsCard("البحث") {
                Text("وضع البحث الافتراضي")
                ChipRow(
                    SearchMode.values().map { it.label },
                    vm.defaultMode.ordinal
                ) { vm.updateDefaultMode(SearchMode.values()[it]) }
                Text("أقصى عدد للنتائج")
                ChipRow(
                    limits.map { "$it" },
                    limits.indexOf(vm.resultLimit).coerceAtLeast(0)
                ) { vm.updateLimit(limits[it]) }
                Text("طول مقتطف النتيجة")
                ChipRow(listOf("قصير", "متوسط", "طويل"), vm.snippetLen) { vm.updateSnippetLen(it) }
                SwitchRow("البحث أثناء الكتابة", vm.liveSearch) { vm.updateLiveSearch(it) }
                SwitchRow("حفظ سجل البحث", vm.saveHistory) { vm.updateSaveHistory(it) }
                Text("توحيد الحروف في البحث", fontWeight = FontWeight.Bold)
                SwitchRow("التاء المربوطة = الهاء (ة = ه)", vm.normTa) {
                    vm.updateNorm(it, vm.normAlef, vm.normHamza)
                }
                SwitchRow("الألف المقصورة = الياء (ى = ي)", vm.normAlef) {
                    vm.updateNorm(vm.normTa, it, vm.normHamza)
                }
                SwitchRow("توحيد الهمزات (أ إ آ = ا ، ؤ = و ، ئ = ي)", vm.normHamza) {
                    vm.updateNorm(vm.normTa, vm.normAlef, it)
                }
                Text(
                    "بعد تغيير خيارات توحيد الحروف اضغط «تطبيق على الفهرس» ليشمل الكتب المفهرسة.",
                    style = MaterialTheme.typography.bodySmall
                )
                TextButton(onClick = { vm.renormalize() }, enabled = !vm.renorming) {
                    Text(if (vm.renorming) "جارٍ التطبيق…" else "تطبيق على الفهرس")
                }
                TextButton(onClick = { vm.clearHistory() }) { Text("مسح سجل البحث") }
            }

            SettingsCard("الفهرسة") {
                Text("طريقة استخراج النص")
                ChipRow(
                    listOf("تلقائي (موصى به)", "OCR لكل الصفحات", "نص PDF فقط"),
                    vm.extractMode
                ) { vm.updateExtractMode(it) }
                Text(
                    "يصبح البحث متاحاً بسرعة من نص الملف، ثم تُحسَّن الصفحات التالفة بالـ OCR في الخلفية.",
                    style = MaterialTheme.typography.bodySmall
                )
                Text("سرعة الفهرسة (عدد المعالجات)")
                ChipRow(listOf("1", "2", "3", "4", "5", "6"), vm.workers - 1) { vm.updateWorkers(it + 1) }
                Text("جودة الـ OCR")
                ChipRow(
                    listOf("سريعة", "متوازنة", "عالية (نموذج أدق)"),
                    vm.ocrQuality
                ) { vm.updateOcrQuality(it) }
                SwitchRow("تجاهل التشكيل أثناء قراءة OCR (أدق للحروف)", vm.ocrIgnoreMarks) {
                    vm.updateOcrIgnoreMarks(it)
                }
                Text(
                    "عدد أكبر وجودة أعلى = دقة أفضل لكن استهلاك أكثر للذاكرة والبطارية ووقت أطول. " +
                        "تجاهل التشكيل يحسّن قراءة الحروف لكنه يزيل التشكيل من النص المقروء بالـ OCR.",
                    style = MaterialTheme.typography.bodySmall
                )
                SwitchRow("إبقاء الشاشة مفعّلة أثناء الفهرسة", vm.keepAwake) { vm.updateKeepAwake(it) }
                TextButton(onClick = { confirmReindex = true }) { Text("إعادة فهرسة كل الكتب") }
            }

            SettingsCard("التخزين") {
                Text("المساحة المستخدمة: $storage")
                Text("عدد الكتب: ${books.size}")
                TextButton(
                    onClick = { confirmDelete = true },
                    colors = ButtonDefaults.textButtonColors(
                        contentColor = MaterialTheme.colorScheme.error
                    )
                ) { Text("حذف جميع الكتب") }
            }

            SettingsCard("سجل التغييرات") {
                Text("الإصدار $APP_VERSION", fontWeight = FontWeight.Bold)
                Text("• فهرسة بمرحلتين: بحث متاح بسرعة، وتحسين الـ OCR في الخلفية")
                Text("• نموذج OCR أدق وجودة أعلى، وخيار تجاهل التشكيل لدقة الحروف")
                Text("• تعديل نص أي صفحة يدوياً، وإعادة قراءة صفحة واحدة بالـ OCR الدقيق")
                Text("• خيارات توحيد الحروف في البحث، وطول المقتطف، ولون التظليل")
                Text("• البحث أثناء الكتابة أو عند الضغط، وحفظ السجل اختياري")
                Text("• إضافة كتاب واحد مباشرة من الملفات، و«إضافة مجلد» في الأعلى")
                Spacer(Modifier.height(6.dp))
                Text("الإصدار 1.3", fontWeight = FontWeight.Bold)
                Text("• إضافة من مجلد أو من «مشاركة» ملف PDF، وبحث داخل الكتاب، وعلامات")
                Spacer(Modifier.height(6.dp))
                Text("الإصدار 1.2", fontWeight = FontWeight.Bold)
                Text("• اكتشاف النص التالف وقراءته بالـ OCR، وفهرسة متوازية وفي الخلفية")
                Spacer(Modifier.height(6.dp))
                Text("الإصدار 1.1", fontWeight = FontWeight.Bold)
                Text("• الإعدادات، والمفضلة، وتعديل العنوان والمؤلف، وسجل البحث")
                Spacer(Modifier.height(6.dp))
                Text("الإصدار 1.0", fontWeight = FontWeight.Bold)
                Text("• النسخة الأولى: مكتبة، وبحث، وفهرسة، وOCR عربي")
            }

            SettingsCard("حول التطبيق") {
                Text("باحث PDF — الإصدار $APP_VERSION")
                Text(
                    "يعمل بالكامل دون إنترنت. الكتب والفهرس محفوظان داخل التطبيق على هاتفك.",
                    style = MaterialTheme.typography.bodySmall
                )
            }
        }
    }

    if (confirmReindex) {
        AlertDialog(
            onDismissRequest = { confirmReindex = false },
            title = { Text("إعادة فهرسة كل الكتب") },
            text = { Text("ستُعاد فهرسة جميع الكتب من البداية، وقد يستغرق ذلك وقتاً طويلاً.") },
            confirmButton = {
                TextButton(onClick = { vm.reindexAll(); confirmReindex = false }) { Text("متابعة") }
            },
            dismissButton = { TextButton(onClick = { confirmReindex = false }) { Text("إلغاء") } }
        )
    }
    if (confirmDelete) {
        AlertDialog(
            onDismissRequest = { confirmDelete = false },
            title = { Text("حذف جميع الكتب") },
            text = { Text("ستُحذف كل الكتب وفهارسها من التطبيق نهائياً. ملفاتك الأصلية على الهاتف لن تتأثر.") },
            confirmButton = {
                TextButton(onClick = { vm.deleteAll(); confirmDelete = false }) { Text("حذف الكل") }
            },
            dismissButton = { TextButton(onClick = { confirmDelete = false }) { Text("إلغاء") } }
        )
    }
}

// ======================= القارئ =======================

@Composable
fun ReaderScreen(vm: AppViewModel, target: ReaderTarget) {
    val ctx = LocalContext.current
    val clipboard = LocalClipboardManager.current
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
    var textMode by remember { mutableStateOf(target.terms.isNotEmpty() && vm.hitView == 0) }
    var zoomed by remember { mutableStateOf(false) }
    var showGo by remember { mutableStateOf(false) }
    var showMarks by remember { mutableStateOf(false) }
    var menu by remember { mutableStateOf(false) }
    var terms by remember { mutableStateOf(target.terms) }
    var searchOpen by remember { mutableStateOf(false) }
    var q by remember { mutableStateOf("") }
    var hitPages by remember { mutableStateOf<List<Int>>(emptyList()) }
    var hitIdx by remember { mutableIntStateOf(-1) }
    var speaking by remember { mutableStateOf(false) }
    var editing by remember { mutableStateOf<String?>(null) }

    val tts = remember { mutableStateOf<TextToSpeech?>(null) }
    DisposableEffect(Unit) {
        var ref: TextToSpeech? = null
        ref = TextToSpeech(ctx) { st ->
            if (st == TextToSpeech.SUCCESS) ref?.language = Locale("ar")
        }
        tts.value = ref
        onDispose {
            ref?.stop()
            ref?.shutdown()
        }
    }

    LaunchedEffect(pagerState.currentPage) {
        zoomed = false
        vm.saveLastPage(book.id, pagerState.currentPage + 1)
        if (speaking) {
            tts.value?.stop()
            speaking = false
        }
    }

    LaunchedEffect(q) {
        delay(300)
        val t = Arabic.terms(q)
        if (t.isEmpty() || t.sumOf { it.length } < 2) {
            hitPages = emptyList()
            hitIdx = -1
            terms = target.terms
        } else {
            val r = vm.searchInBook(book.id, q)
            hitPages = r.first
            terms = r.second
            textMode = true
            if (r.first.isEmpty()) {
                hitIdx = -1
            } else {
                val cur = pagerState.currentPage + 1
                val i = r.first.indexOfFirst { it >= cur }
                hitIdx = if (i < 0) 0 else i
                pagerState.scrollToPage(r.first[hitIdx] - 1)
            }
        }
    }

    fun goHit(delta: Int) {
        if (hitPages.isEmpty()) return
        hitIdx = (hitIdx + delta + hitPages.size) % hitPages.size
        scope.launch { pagerState.scrollToPage(hitPages[hitIdx] - 1) }
    }

    fun toast(m: String) {
        Toast.makeText(ctx, m, Toast.LENGTH_SHORT).show()
    }

    val curPage = pagerState.currentPage + 1
    val marked = vm.isBookmarked(book.id, curPage)

    Scaffold(
        topBar = {
            Column {
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
                                "صفحة $curPage من $total" + if (marked) "  ★" else "",
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
                        IconButton(onClick = { searchOpen = !searchOpen }) {
                            Icon(Icons.Default.Search, "بحث في الكتاب")
                        }
                        TextButton(onClick = { textMode = !textMode }) {
                            Text(if (textMode) "الصفحة" else "النص")
                        }
                        Box {
                            IconButton(onClick = { menu = true }) {
                                Icon(Icons.Default.MoreVert, "المزيد")
                            }
                            DropdownMenu(expanded = menu, onDismissRequest = { menu = false }) {
                                DropdownMenuItem(
                                    text = { Text("الانتقال إلى صفحة") },
                                    onClick = { menu = false; showGo = true }
                                )
                                DropdownMenuItem(
                                    text = { Text(if (marked) "إزالة العلامة من هذه الصفحة" else "إضافة علامة لهذه الصفحة") },
                                    onClick = { menu = false; vm.toggleBookmark(book.id, curPage) }
                                )
                                DropdownMenuItem(
                                    text = { Text("العلامات المحفوظة") },
                                    onClick = { menu = false; showMarks = true }
                                )
                                DropdownMenuItem(
                                    text = { Text("تكبير الخط") },
                                    onClick = {
                                        vm.readerFont = (vm.readerFont + 2f).coerceAtMost(40f)
                                        vm.saveFont()
                                    }
                                )
                                DropdownMenuItem(
                                    text = { Text("تصغير الخط") },
                                    onClick = {
                                        vm.readerFont = (vm.readerFont - 2f).coerceAtLeast(14f)
                                        vm.saveFont()
                                    }
                                )
                                DropdownMenuItem(
                                    text = { Text("تعديل نص الصفحة") },
                                    onClick = {
                                        menu = false
                                        scope.launch { editing = vm.pageText(book.id, curPage) }
                                    }
                                )
                                DropdownMenuItem(
                                    text = { Text("إعادة قراءة الصفحة بالـ OCR الدقيق") },
                                    onClick = {
                                        menu = false
                                        toast("جارٍ قراءة الصفحة…")
                                        vm.reOcrPage(book.id, curPage) { ok ->
                                            toast(if (ok) "تم تحديث نص الصفحة" else "تعذّرت القراءة")
                                        }
                                    }
                                )
                                DropdownMenuItem(
                                    text = { Text("نسخ نص الصفحة") },
                                    onClick = {
                                        menu = false
                                        scope.launch {
                                            val t = vm.pageText(book.id, curPage)
                                            clipboard.setText(AnnotatedString(t))
                                            toast("تم نسخ نص الصفحة")
                                        }
                                    }
                                )
                                DropdownMenuItem(
                                    text = { Text("مشاركة نص الصفحة") },
                                    onClick = {
                                        menu = false
                                        scope.launch {
                                            val t = vm.pageText(book.id, curPage)
                                            val send = Intent(Intent.ACTION_SEND).apply {
                                                type = "text/plain"
                                                putExtra(Intent.EXTRA_TEXT, t)
                                            }
                                            ctx.startActivity(Intent.createChooser(send, "مشاركة نص الصفحة"))
                                        }
                                    }
                                )
                                DropdownMenuItem(
                                    text = { Text(if (speaking) "إيقاف القراءة الصوتية" else "قراءة الصفحة صوتياً") },
                                    onClick = {
                                        menu = false
                                        scope.launch {
                                            if (speaking) {
                                                tts.value?.stop()
                                                speaking = false
                                            } else {
                                                val t = vm.pageText(book.id, curPage)
                                                if (t.isBlank()) {
                                                    toast("لا يوجد نص لهذه الصفحة")
                                                } else {
                                                    tts.value?.speak(t.take(3900), TextToSpeech.QUEUE_FLUSH, null, "page")
                                                    speaking = true
                                                }
                                            }
                                        }
                                    }
                                )
                            }
                        }
                    }
                )
                if (searchOpen) {
                    Row(
                        Modifier.fillMaxWidth().padding(horizontal = 12.dp, vertical = 4.dp),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        OutlinedTextField(
                            value = q,
                            onValueChange = { q = it },
                            modifier = Modifier.weight(1f),
                            placeholder = { Text("ابحث في هذا الكتاب") },
                            singleLine = true,
                            shape = RoundedCornerShape(20.dp)
                        )
                        Text(
                            if (hitPages.isEmpty()) (if (q.isBlank()) "" else "0") else "${hitIdx + 1}/${hitPages.size}",
                            Modifier.padding(horizontal = 6.dp),
                            style = MaterialTheme.typography.labelMedium
                        )
                        TextButton(onClick = { goHit(-1) }) { Text("السابق") }
                        TextButton(onClick = { goHit(1) }) { Text("التالي") }
                    }
                }
            }
        }
    ) { pad ->
        HorizontalPager(
            state = pagerState,
            userScrollEnabled = !zoomed,
            modifier = Modifier.padding(pad).fillMaxSize()
        ) { idx ->
            if (textMode) {
                TextPage(vm, book.id, idx + 1, terms)
            } else {
                ZoomBox(onZoomChange = { zoomed = it }) {
                    PdfPageImage(source, idx, (LocalConfiguration.current.screenWidthDp *
                        LocalDensity.current.density * 1.5f).toInt().coerceIn(800, 2000))
                }
            }
        }
    }

    editing?.let { cur ->
        AlertDialog(
            onDismissRequest = { editing = null },
            title = { Text("تعديل نص الصفحة $curPage") },
            text = {
                OutlinedTextField(
                    value = cur,
                    onValueChange = { editing = it },
                    modifier = Modifier.fillMaxWidth().height(320.dp)
                )
            },
            confirmButton = {
                TextButton(onClick = {
                    vm.savePageText(book.id, curPage, cur)
                    editing = null
                }) { Text("حفظ") }
            },
            dismissButton = { TextButton(onClick = { editing = null }) { Text("إلغاء") } }
        )
    }

    if (showMarks) {
        val marks = vm.bookmarksOf(book.id)
        AlertDialog(
            onDismissRequest = { showMarks = false },
            title = { Text("العلامات المحفوظة") },
            text = {
                if (marks.isEmpty()) {
                    Text("لا توجد علامات. أضف علامة من القائمة (⋮).")
                } else {
                    Column(Modifier.verticalScroll(rememberScrollState())) {
                        marks.forEach { pg ->
                            ScopeRow("صفحة $pg") {
                                showMarks = false
                                scope.launch { pagerState.scrollToPage((pg - 1).coerceIn(0, total - 1)) }
                            }
                        }
                    }
                }
            },
            confirmButton = { TextButton(onClick = { showMarks = false }) { Text("إغلاق") } }
        )
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
    val text by produceState<String?>(null, bookId, pageNo, vm.textVersion) {
        value = vm.pageText(bookId, pageNo)
    }
    val t = text
    Column(Modifier.fillMaxSize().verticalScroll(rememberScrollState()).padding(16.dp)) {
        when {
            t == null -> CircularProgressIndicator()
            t.isBlank() -> Text(
                "لا يوجد نص لهذه الصفحة (لم تُفهرس بعد أو أنها فارغة). جرّب «الصفحة».",
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
            else -> {
                val shown = if (vm.hideTashkeel) Arabic.stripTashkeel(t) else t
                val ranges = remember(shown, terms) { Arabic.findRanges(shown, terms) }
                Text(
                    highlighted(shown, ranges, markColor(vm.highlightIdx)),
                    fontSize = vm.readerFont.sp,
                    lineHeight = (vm.readerFont * vm.lineSpacing).sp,
                    fontFamily = if (vm.fontStyle == 0) FontFamily.Serif else FontFamily.SansSerif,
                    textAlign = if (vm.justify) TextAlign.Justify else TextAlign.Start,
                    color = MaterialTheme.colorScheme.onBackground
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
import android.content.Context
import android.net.Uri
import android.provider.OpenableColumns
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableFloatStateOf
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableLongStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.documentfile.provider.DocumentFile
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

const val APP_VERSION = "1.4"

fun arrangeBooks(list: List<BookEntity>, filter: String, sort: Int): List<BookEntity> {
    val f = Arabic.normalize(filter)
    val filtered = if (f.isEmpty()) list
    else list.filter { Arabic.normalize(it.title + " " + it.author).contains(f) }
    return when (sort) {
        1 -> filtered.sortedBy { Arabic.normalize(it.title) }
        2 -> filtered.sortedWith(
            compareByDescending<BookEntity> { it.favorite }.thenByDescending { it.addedAt }
        )
        else -> filtered.sortedByDescending { it.addedAt }
    }
}

fun formatSize(bytes: Long): String {
    val mb = bytes / (1024.0 * 1024.0)
    return if (mb >= 1024) String.format("%.2f جيجابايت", mb / 1024.0)
    else String.format("%.1f ميجابايت", mb)
}

class AppViewModel(app: Application) : AndroidViewModel(app) {

    private val dao = AppDb.get(app).dao()
    private var searchJob: Job? = null
    private val prefs = app.getSharedPreferences("settings", Context.MODE_PRIVATE)

    val books = dao.observeBooks()
        .stateIn(viewModelScope, SharingStarted.Eagerly, emptyList())

    // ---------- الإعدادات ----------
    var themeMode by mutableIntStateOf(prefs.getInt("theme", 0))
    var readerFont by mutableFloatStateOf(prefs.getFloat("font", 20f))
    var defaultMode by mutableStateOf(
        SearchMode.values()[prefs.getInt("mode", 0).coerceIn(0, SearchMode.values().size - 1)]
    )
    var resultLimit by mutableIntStateOf(prefs.getInt("limit", 400))
    var extractMode by mutableIntStateOf(prefs.getInt("extract", 0))
    var workers by mutableIntStateOf(
        prefs.getInt("workers", minOf(4, maxOf(2, Runtime.getRuntime().availableProcessors() / 2)))
    )
    var ocrQuality by mutableIntStateOf(prefs.getInt("ocrq", 1))
    var hitView by mutableIntStateOf(prefs.getInt("hitview", 0))
    var lineSpacing by mutableFloatStateOf(prefs.getFloat("lineSp", 1.7f))
    var hideTashkeel by mutableStateOf(prefs.getBoolean("hideTash", false))
    var justify by mutableStateOf(prefs.getBoolean("justify", false))
    var fontStyle by mutableIntStateOf(prefs.getInt("fontStyle", 0))
    var importTotal by mutableIntStateOf(0)
    var importDone by mutableIntStateOf(0)
    var libFavOnly by mutableStateOf(false)
    var ocrIgnoreMarks by mutableStateOf(prefs.getBoolean("ocrNoMarks", false))
    var normTa by mutableStateOf(prefs.getBoolean("normTa", true))
    var normAlef by mutableStateOf(prefs.getBoolean("normAlef", true))
    var normHamza by mutableStateOf(prefs.getBoolean("normHamza", true))
    var snippetLen by mutableIntStateOf(prefs.getInt("snippet", 1))
    var liveSearch by mutableStateOf(prefs.getBoolean("live", true))
    var saveHistory by mutableStateOf(prefs.getBoolean("saveHist", true))
    var highlightIdx by mutableIntStateOf(prefs.getInt("hl", 0))
    var keepAwakeRead by mutableStateOf(prefs.getBoolean("awakeRead", false))
    var textVersion by mutableIntStateOf(0)
    var renorming by mutableStateOf(false)
    var bookmarks by mutableStateOf(
        (prefs.getString("bookmarks", "") ?: "").split("\n").filter { it.contains(":") }.toSet()
    )
    var keepAwake by mutableStateOf(prefs.getBoolean("keepAwake", true))
    var sortOrder by mutableIntStateOf(prefs.getInt("sort", 0))
    var history by mutableStateOf(
        (prefs.getString("history", "") ?: "").split("\n").filter { it.isNotBlank() }
    )

    fun updateTheme(v: Int) { themeMode = v; prefs.edit().putInt("theme", v).apply() }
    fun saveFont() { prefs.edit().putFloat("font", readerFont).apply() }
    fun updateDefaultMode(m: SearchMode) {
        defaultMode = m
        mode = m
        prefs.edit().putInt("mode", m.ordinal).apply()
    }
    fun updateLimit(v: Int) { resultLimit = v; prefs.edit().putInt("limit", v).apply() }
    fun updateExtractMode(v: Int) { extractMode = v; prefs.edit().putInt("extract", v).apply() }
    fun updateWorkers(v: Int) { workers = v; prefs.edit().putInt("workers", v).apply() }
    fun updateOcrQuality(v: Int) { ocrQuality = v; prefs.edit().putInt("ocrq", v).apply() }
    fun saveReader() { prefs.edit().putFloat("lineSp", lineSpacing).putFloat("font", readerFont).apply() }
    fun updateHideTashkeel(v: Boolean) { hideTashkeel = v; prefs.edit().putBoolean("hideTash", v).apply() }
    fun updateJustify(v: Boolean) { justify = v; prefs.edit().putBoolean("justify", v).apply() }
    fun updateFontStyle(v: Int) { fontStyle = v; prefs.edit().putInt("fontStyle", v).apply() }

    fun isBookmarked(bookId: Long, page: Int): Boolean = bookmarks.contains("$bookId:$page")

    fun toggleBookmark(bookId: Long, page: Int) {
        val k = "$bookId:$page"
        bookmarks = if (bookmarks.contains(k)) bookmarks - k else bookmarks + k
        prefs.edit().putString("bookmarks", bookmarks.joinToString("\n")).apply()
    }

    fun bookmarksOf(bookId: Long): List<Int> =
        bookmarks.filter { it.startsWith("$bookId:") }
            .mapNotNull { it.substringAfter(":").toIntOrNull() }.sorted()

    private fun dropBookmarks(bookId: Long?) {
        bookmarks = if (bookId == null) emptySet()
        else bookmarks.filterNot { it.startsWith("$bookId:") }.toSet()
        prefs.edit().putString("bookmarks", bookmarks.joinToString("\n")).apply()
    }

    fun updateHitView(v: Int) { hitView = v; prefs.edit().putInt("hitview", v).apply() }

    private fun options(): IndexOptions {
        val width = when (ocrQuality) {
            0 -> 1400
            2 -> 2400
            else -> 1900
        }
        return IndexOptions(extractMode, workers, width, ocrQuality == 2, ocrIgnoreMarks)
    }

    fun updateOcrIgnoreMarks(v: Boolean) { ocrIgnoreMarks = v; prefs.edit().putBoolean("ocrNoMarks", v).apply() }
    fun updateSnippetLen(v: Int) { snippetLen = v; prefs.edit().putInt("snippet", v).apply() }
    fun updateLiveSearch(v: Boolean) { liveSearch = v; prefs.edit().putBoolean("live", v).apply() }
    fun updateSaveHistory(v: Boolean) { saveHistory = v; prefs.edit().putBoolean("saveHist", v).apply() }
    fun updateHighlight(v: Int) { highlightIdx = v; prefs.edit().putInt("hl", v).apply() }
    fun updateKeepAwakeRead(v: Boolean) { keepAwakeRead = v; prefs.edit().putBoolean("awakeRead", v).apply() }

    fun updateNorm(ta: Boolean, alef: Boolean, hamza: Boolean) {
        normTa = ta; normAlef = alef; normHamza = hamza
        ArabicOpts.taMarbuta = ta
        ArabicOpts.alefMaksura = alef
        ArabicOpts.hamza = hamza
        prefs.edit().putBoolean("normTa", ta).putBoolean("normAlef", alef).putBoolean("normHamza", hamza).apply()
    }

    /** إعادة بناء عمود البحث لكل الصفحات بعد تغيير خيارات توحيد الحروف (سريع، دون OCR). */
    fun renormalize() {
        if (renorming) return
        viewModelScope.launch(Dispatchers.Default) {
            renorming = true
            try {
                var last = 0L
                while (true) {
                    val b = dao.textBatch(last, 300)
                    if (b.isEmpty()) break
                    dao.renormBatch(b)
                    last = b.last().id
                }
                message = "تم تطبيق خيارات البحث على الفهرس"
            } catch (e: CancellationException) {
                throw e
            } catch (e: Exception) {
                message = "تعذّر تحديث الفهرس"
            } finally {
                renorming = false
            }
        }
    }

    // ---------- تعديل نص الصفحة ----------
    fun savePageText(bookId: Long, pageNo: Int, text: String) {
        viewModelScope.launch {
            val t = text.trim()
            dao.updatePage(bookId, pageNo, t, Arabic.normalize(t))
            textVersion++
        }
    }

    /** يعيد قراءة صفحة واحدة بالـ OCR الأدق ويحفظ النتيجة. */
    fun reOcrPage(bookId: Long, pageNo: Int, done: (Boolean) -> Unit) {
        viewModelScope.launch {
            val app = getApplication<Application>()
            val t = withContext(Dispatchers.Default) {
                Work.indexer(app).ocrOne(bookId, pageNo, ocrIgnoreMarks)
            }
            if (t.isBlank()) {
                done(false)
            } else {
                dao.updatePage(bookId, pageNo, t.trim(), Arabic.normalize(t))
                textVersion++
                done(true)
            }
        }
    }
    fun updateKeepAwake(v: Boolean) { keepAwake = v; prefs.edit().putBoolean("keepAwake", v).apply() }
    fun updateSort(v: Int) { sortOrder = v; prefs.edit().putInt("sort", v).apply() }

    fun addHistory(q: String) {
        val t = q.trim()
        if (t.length < 2 || !saveHistory) return
        history = (listOf(t) + history.filter { it != t }).take(12)
        prefs.edit().putString("history", history.joinToString("\n")).apply()
    }

    fun clearHistory() {
        history = emptyList()
        prefs.edit().putString("history", "").apply()
    }

    // ---------- الحالة العامة ----------
    var tab by mutableIntStateOf(0)
    var reader by mutableStateOf<ReaderTarget?>(null)
    var message by mutableStateOf<String?>(null)
    var libraryFilter by mutableStateOf("")

    var query by mutableStateOf("")
    var mode by mutableStateOf(defaultMode)
    var scopeBookId by mutableLongStateOf(0L)
    var results by mutableStateOf<List<Hit>>(emptyList())
    var searching by mutableStateOf(false)
    var searchedOnce by mutableStateOf(false)
    private var lastTerms: List<String> = emptyList()

    init {
        ArabicOpts.taMarbuta = normTa
        ArabicOpts.alefMaksura = normAlef
        ArabicOpts.hamza = normHamza
        viewModelScope.launch {
            dao.unfinished().forEach {
                if (Work.jobs[it.id]?.isActive != true) startIndex(it.id)
            }
        }
    }

    private fun booksDir(): File =
        File(getApplication<Application>().filesDir, "books").apply { mkdirs() }

    // ---------- إضافة الكتب ----------
    fun importUris(uris: List<Uri>) {
        if (uris.isEmpty()) return
        viewModelScope.launch {
            importTotal += uris.size
            var added = 0
            var dup = 0
            for (uri in uris) {
                val id = withContext(Dispatchers.IO) { copyIn(uri) }
                importDone += 1
                if (id == null) {
                    // فشل نسخ الملف وظهرت رسالة
                } else if (id < 0) {
                    dup++
                } else {
                    added++
                    startIndex(id)
                }
            }
            if (importDone >= importTotal) {
                importTotal = 0
                importDone = 0
            }
            if (uris.size > 1 || dup > 0) {
                message = "تمت إضافة $added كتاب" + if (dup > 0) " وتخطي $dup مكرّر" else ""
            }
        }
    }

    fun importTree(tree: Uri) {
        viewModelScope.launch {
            val app = getApplication<Application>()
            val uris = withContext(Dispatchers.IO) { collectPdfs(DocumentFile.fromTreeUri(app, tree)) }
            if (uris.isEmpty()) message = "لم أجد ملفات PDF في هذا المجلد" else importUris(uris)
        }
    }

    private fun collectPdfs(dir: DocumentFile?): List<Uri> {
        val out = ArrayList<Uri>()
        dir?.listFiles()?.forEach { f ->
            if (f.isDirectory) {
                out.addAll(collectPdfs(f))
            } else if (f.type == "application/pdf" || f.name?.endsWith(".pdf", true) == true) {
                out.add(f.uri)
            }
        }
        return out
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
            val dup = dao.allBooks().any { it.id != id && it.title == title && it.pageCount == count }
            if (dup) {
                f.delete()
                dao.deleteBookFully(id)
                -1L
            } else {
                dao.setPageCount(id, count)
                id
            }
        } catch (e: Exception) {
            f.delete()
            dao.deleteBookFully(id)
            message = "تعذّر فتح الملف: $title"
            null
        }
    }

    fun startIndex(id: Long, forceOcr: Boolean = false, restart: Boolean = false) {
        Work.jobs[id]?.cancel()
        val opts = options()
        val app = getApplication<Application>()
        Work.jobs[id] = Work.scope.launch {
            if (restart || forceOcr) dao.setStatus(id, ST_QUEUED)
            IndexService.start(app)
            Work.lock.withLock { Work.indexer(app).index(id, forceOcr, restart, opts) }
        }
    }

    fun reindexAll() {
        viewModelScope.launch {
            dao.allBooks().forEach { startIndex(it.id, forceOcr = false, restart = true) }
        }
    }

    // ---------- إدارة الكتب ----------
    fun editBook(id: Long, title: String, author: String) {
        viewModelScope.launch { dao.updateInfo(id, title, author.trim()) }
    }

    fun toggleFavorite(b: BookEntity) {
        viewModelScope.launch { dao.setFavorite(b.id, !b.favorite) }
    }

    fun saveLastPage(id: Long, page: Int) {
        viewModelScope.launch { dao.setLastPage(id, page) }
    }

    fun delete(id: Long) {
        viewModelScope.launch {
            Work.jobs.remove(id)?.cancelAndJoin()
            withContext(Dispatchers.IO) {
                dao.deleteBookFully(id)
                File(booksDir(), "$id.pdf").delete()
            }
            dropBookmarks(id)
            if (scopeBookId == id) scopeBookId = 0L
        }
    }

    fun deleteAll() {
        viewModelScope.launch {
            Work.jobs.values.toList().forEach { it.cancelAndJoin() }
            Work.jobs.clear()
            withContext(Dispatchers.IO) {
                dao.deleteAllPages()
                dao.deleteAllBooks()
                booksDir().listFiles()?.forEach { it.delete() }
            }
            dropBookmarks(null)
            scopeBookId = 0L
            results = emptyList()
            searchedOnce = false
        }
    }

    suspend fun storageBytes(): Long = withContext(Dispatchers.IO) {
        val files = booksDir().listFiles()?.sumOf { it.length() } ?: 0L
        val db = getApplication<Application>().getDatabasePath("bahith.db").length()
        files + db
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
        val limit = resultLimit
        val radius = when (snippetLen) {
            0 -> 50
            2 -> 150
            else -> 80
        }
        searchJob = viewModelScope.launch {
            searching = true
            val out = withContext(Dispatchers.Default) { runSearch(terms, m, scope, limit, radius) }
            lastTerms = out.second
            results = out.first
            searchedOnce = true
            searching = false
        }
    }

    private suspend fun runSearch(
        terms: List<String>,
        m: SearchMode,
        scope: Long,
        limit: Int,
        radius: Int
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
        sql.append(" ORDER BY b.title, p.pageNo LIMIT ").append(limit)
        val rows = try {
            dao.search(SimpleSQLiteQuery(sql.toString(), args.toTypedArray()))
        } catch (e: CancellationException) {
            throw e
        } catch (e: Exception) {
            emptyList()
        }
        val hits = rows.map {
            val (snip, ranges) = Arabic.snippet(it.text, hl, radius)
            Hit(it.bookId, it.title, it.pageNo, snip, ranges)
        }
        return hits to hl
    }

    /** أرقام الصفحات المطابقة داخل كتاب واحد (للبحث من القارئ). */
    suspend fun searchInBook(bookId: Long, q: String): Pair<List<Int>, List<String>> {
        val terms = Arabic.terms(q)
        if (terms.isEmpty()) return Pair(emptyList(), emptyList())
        val m = if (terms.size >= 6) SearchMode.PHRASE else SearchMode.ALL
        val hl = if (m == SearchMode.PHRASE) listOf(terms.joinToString(" ")) else terms
        val sql = "SELECT p.bookId AS bookId, p.pageNo AS pageNo, '' AS text, '' AS title " +
            "FROM pages_fts JOIN pages p ON p.id = pages_fts.rowid " +
            "WHERE pages_fts MATCH ? AND p.bookId = ? ORDER BY p.pageNo LIMIT 3000"
        val rows = try {
            withContext(Dispatchers.Default) {
                dao.search(SimpleSQLiteQuery(sql, arrayOf<Any>(Arabic.ftsQuery(terms, m), bookId)))
            }
        } catch (e: CancellationException) {
            throw e
        } catch (e: Exception) {
            emptyList()
        }
        return Pair(rows.map { it.pageNo }, hl)
    }

    fun openHit(h: Hit) {
        addHistory(query)
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
        maven { url = uri("https://jitpack.io") }
    }
}
rootProject.name = "BahithPDF"
include(":app")
__EOF__
mkdir -p app/src/main/assets/tessdata
curl -L --fail --retry 3 -o app/src/main/assets/tessdata/ara_best.traineddata https://github.com/tesseract-ocr/tessdata_best/raw/main/ara.traineddata || echo "best model download failed (optional)"
ls -l app/src/main/assets/tessdata || true
