plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.jansaathi2"

    compileSdk = flutter.compileSdkVersion

    // 🔴 IMPORTANT: Force correct NDK version
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId = "com.example.jansaathi2"

        // Firebase Phone Auth requires minSdk >= 21
        minSdk = flutter.minSdkVersion

        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

dependencies {
    // Firebase BOM (safe version management)
    implementation(platform("com.google.firebase:firebase-bom:33.7.0"))

    // Firebase Auth (OTP)
    implementation("com.google.firebase:firebase-auth")
}

flutter {
    source = "../.."
}
