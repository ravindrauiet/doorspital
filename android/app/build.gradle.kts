import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("com.google.gms.google-services")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystorePropertiesFile.inputStream().use { keystoreProperties.load(it) }
}

val requiredKeystoreProperties = listOf("storeFile", "storePassword", "keyAlias", "keyPassword")
val missingKeystoreProperties = requiredKeystoreProperties.filter {
    keystoreProperties.getProperty(it).isNullOrBlank()
}
val isReleaseTask = gradle.startParameter.taskNames.any { it.contains("release", ignoreCase = true) }

android {
    namespace = "com.company.doorspitals"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.company.doorspitals"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            if (keystorePropertiesFile.exists() && missingKeystoreProperties.isEmpty()) {
                storeFile = rootProject.file(keystoreProperties.getProperty("storeFile"))
                storePassword = keystoreProperties.getProperty("storePassword")
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
            }
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

if (isReleaseTask && (!keystorePropertiesFile.exists() || missingKeystoreProperties.isNotEmpty())) {
    throw GradleException(
        buildString {
            append("Release signing is not configured. Create android/key.properties with storeFile, ")
            append("storePassword, keyAlias, and keyPassword.")
            if (missingKeystoreProperties.isNotEmpty()) {
                append(" Missing: ")
                append(missingKeystoreProperties.joinToString(", "))
                append(".")
            }
        }
    )
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}
