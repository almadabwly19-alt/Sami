#!/bin/bash
set -e

echo "=== بدء إنشاء وإعداد مشروع باحث PDF (Bahith PDF) ==="

# 1. إنشاء مجلدات المشروع الأساسية
mkdir -p .github/workflows
mkdir -p app/src/main/java/com/bahith/pdf
mkdir -p app/src/main/res/values
mkdir -p app/src/main/assets/tessdata

# 2. إنشاء ملف إعداد البناء build.gradle.kts
cat << 'EOF' > app/build.gradle.kts
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
        
        vectorDrawables {
            useSupportLibrary = true
        }
        
        ndk {
            abiFilters.addAll(listOf("arm64-v8a", "armeabi-v7a", "x86", "x86_64"))
        }
    }

    buildTypes {
        release {
            isMinifyEnabled = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    buildFeatures {
        compose = true
    }
    
    packaging {
        resources {
            excludes += "/META-INF/{AL2.0,LGPL2.1}"
        }
    }
}

dependencies {
    implementation("androidx.core:core-ktx:1.12.0")
    implementation("androidx.lifecycle:lifecycle-runtime-ktx:2.7.0")
    implementation("androidx.activity:activity-compose:1.8.2")
    implementation(platform("androidx.compose:compose-bom:2023.08.00"))
    implementation("androidx.compose.ui:ui")
    implementation("androidx.compose.ui:ui-graphics")
    implementation("androidx.compose.ui:ui-tooling-preview")
    implementation("androidx.compose.material3:material3:1.2.0")
    implementation("com.google.code.gson:gson:2.10.1")
}
EOF

# 3. إنشاء ملف الأتمتة لبناء الـ APK عبر GitHub Actions
cat << 'EOF' > .github/workflows/build.yml
name: Build Complete Bahith PDF APK

on:
  push:
    branches: [ "main", "master" ]
  workflow_dispatch:

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout Repository
        uses: actions/checkout@v4

      - name: Set up JDK 17
        uses: actions/setup-java@v4
        with:
          distribution: 'temurin'
          java-version: '17'

      - name: Setup Android SDK
        uses: android-actions/setup-android@v3

      - name: Install Build Tools and Platforms
        run: |
          sdkmanager "platforms;android-34" "build-tools;34.0.0"

      - name: Download High-Accuracy Arabic OCR Data (Tessdata Best)
        run: |
          mkdir -p app/src/main/assets/tessdata
          curl -L --fail -o app/src/main/assets/tessdata/ara.traineddata https://github.com/tesseract-ocr/tessdata_best/raw/main/ara.traineddata
          ls -l app/src/main/assets/tessdata

      - name: Accept Android Licenses
        run: yes | sdkmanager --licenses > /dev/null || true

      - name: Setup Gradle Cache
        uses: gradle/actions/setup-gradle@v4
        with:
          gradle-version: '8.9'

      - name: Build Debug APK
        run: gradle assembleDebug --no-daemon --stacktrace

      - name: Upload APK Artifact
        uses: actions/upload-artifact@v4
        with:
          name: bahith-pdf-final-apk
          path: app/build/outputs/apk/debug/app-debug.apk
EOF

echo "=== تم إنشاء السكربتات والملفات بنجاح جاهزة للرفع والبناء! ==="
