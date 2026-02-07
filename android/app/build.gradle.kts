plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.github.triplet.play") version "3.10.1"
}

android {
    namespace = "com.machinemaintenance.machine_maintenance"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.machinemaintenance.machine_maintenance"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}

play {
    // Path to service account JSON key file (set via environment variable in Jenkins)
    val serviceAccountJsonPath = System.getenv("PLAY_STORE_CONFIG_JSON")
    if (serviceAccountJsonPath != null) {
        serviceAccountCredentials.set(file(serviceAccountJsonPath))
    }
    
    // Track for release (production, beta, alpha, internal)
    // Set via PLAY_STORE_TRACK environment variable, defaults to "internal" for safety
    val releaseTrack = System.getenv("PLAY_STORE_TRACK") ?: "internal"
    track.set(releaseTrack)
    
    // Release status (completed, draft, halted, inProgress)
    releaseStatus.set(com.github.triplet.gradle.androidpublisher.ReleaseStatus.COMPLETED)
    
    // Default locale for release notes
    defaultToAppBundles.set(true)
}
