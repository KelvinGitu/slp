import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// `flutterfire configure` writes google-services.json here. Until it does, the
// Firebase plugin stays off: com.google.gms.google-services fails the build
// outright on a missing file, which would make a fresh clone unbuildable.
val googleServicesFile = file("google-services.json")
val hasFirebaseConfig = googleServicesFile.exists()

if (hasFirebaseConfig) {
    apply(plugin = "com.google.gms.google-services")
} else {
    logger.warn(
        "SolarTide: android/app/google-services.json not found. Firebase is " +
            "disabled for this build. Run `flutterfire configure`."
    )
}

// Release signing. key.properties is gitignored; see key.properties.example.
val keystorePropertiesFile = rootProject.file("key.properties")
val hasReleaseSigning = keystorePropertiesFile.exists()
val keystoreProperties = Properties().apply {
    if (hasReleaseSigning) keystorePropertiesFile.inputStream().use { load(it) }
}

// A release that silently falls back to the debug key only fails once it's in
// the Play Console. Fail the release build instead. Debug builds are unaffected.
gradle.taskGraph.whenReady {
    val buildingRelease = allTasks.any {
        it.project.path == project.path && it.name.contains("Release")
    }
    if (buildingRelease) {
        val problems = buildList {
            if (!hasReleaseSigning) {
                add("android/key.properties not found: the build would be signed with the debug key.")
            }
            if (!hasFirebaseConfig) {
                add("android/app/google-services.json not found: sign-in and quotes would not work.")
            }
        }
        if (problems.isNotEmpty()) {
            val detail = problems.joinToString("") { System.lineSeparator() + "  - " + it }
            throw GradleException("Release build is not shippable:" + detail)
        }
    }
}

android {
    namespace = "com.solartide.app"
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
        applicationId = "com.solartide.app"
        minSdk = 24
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hasReleaseSigning) {
            create("release") {
                storeFile = file(keystoreProperties.getProperty("storeFile"))
                storePassword = keystoreProperties.getProperty("storePassword")
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
            }
        }
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName(if (hasReleaseSigning) "release" else "debug")
        }
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

flutter {
    source = "../.."
}
