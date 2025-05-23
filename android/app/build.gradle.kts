plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android") // This will now pick up Kotlin 1.9.23
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.ultrapdfconverter"
    // Downgrade to a compileSdk that is older, typically 33 or even 31/32
    // FlutLab often works well with older SDKs
    compileSdk = 33 // Try 33 first, if that fails, try 31 or 32

    defaultConfig {
        applicationId = "com.example.ultrapdfconverter"
        minSdk = 21 // Keep this as is
        targetSdk = 33 // Make targetSdk match compileSdk
        versionCode = 1
        versionName = "1.0"
    }

    compileOptions {
        // Downgrade Java to 11 (or even 8 if necessary for older FlutLab environments)
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = "11" // Match jvmTarget to Java version
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
}

flutter {
    source = "../.."
}

dependencies {
    implementation("androidx.core:core-ktx:1.10.1")
}