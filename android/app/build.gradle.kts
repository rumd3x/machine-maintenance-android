plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.github.triplet.play") version "3.10.1"
}

import java.util.Properties
import java.io.FileInputStream

// Load keystore properties
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
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

    // Signing configuration
    signingConfigs {
        create("release") {
            if (keystorePropertiesFile.exists()) {
                keyAlias = keystoreProperties["keyAlias"].toString()
                keyPassword = keystoreProperties["keyPassword"].toString()
                storeFile = file(keystoreProperties["storeFile"].toString())
                storePassword = keystoreProperties["storePassword"].toString()
            }
        }
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
            // MUST use release signing - no fallback for production builds
            // Jenkins creates key.properties dynamically before building
            signingConfig = signingConfigs.getByName("release")
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
    // Use DRAFT for apps that haven't been published yet, COMPLETED for published apps
    // Set via PLAY_STORE_RELEASE_STATUS environment variable, defaults to "draft"
    val releaseStatusValue = System.getenv("PLAY_STORE_RELEASE_STATUS") ?: "draft"
    releaseStatus.set(
        when (releaseStatusValue.lowercase()) {
            "completed" -> com.github.triplet.gradle.androidpublisher.ReleaseStatus.COMPLETED
            "halted" -> com.github.triplet.gradle.androidpublisher.ReleaseStatus.HALTED
            "inprogress" -> com.github.triplet.gradle.androidpublisher.ReleaseStatus.IN_PROGRESS
            else -> com.github.triplet.gradle.androidpublisher.ReleaseStatus.DRAFT
        }
    )
    
    // Default locale for release notes
    defaultToAppBundles.set(true)
}
