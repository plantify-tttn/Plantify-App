plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// ĐỌC key.properties (ở thư mục android/)
import java.util.Properties
import java.io.FileInputStream

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.example.plantify" // TODO: đổi sang appId thật sự (ví dụ: com.yourcompany.plantify)
    compileSdk = 36
    ndkVersion = "27.0.12077973"

    // ⚠️ Khuyến nghị dùng Java 17 cho AGP mới
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId = "com.example.plantify" // TODO: đổi sang appId thật sự
        minSdk = 23
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        // tạo cấu hình release từ key.properties (nếu file tồn tại)
        if (keystorePropertiesFile.exists()) {
            create("release") {
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
            }
        }
    }

    buildTypes {
        getByName("release") {
            // dùng signing release (không dùng debug nữa)
            signingConfig = signingConfigs.findByName("release") ?: signingConfigs.getByName("debug")

            // Bật tối ưu kích thước & obfuscation
            isMinifyEnabled = true
            isShrinkResources = true

            proguardFiles(
                getDefaultProguardFile("proguard-android.txt"),
                "proguard-rules.pro"
            )
        }

        // (tùy chọn) debug vẫn giữ nguyên
        getByName("debug") {
            // mặc định dùng debug keystore
        }
    }

    // (tùy chọn) nếu cần: packagingOptions, lint, buildFeatures…
}

flutter {
    source = "../.."
}
