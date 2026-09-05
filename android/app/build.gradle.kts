plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.flutter_steam_tv"
    // 37, not flutter.compileSdkVersion (36): the stream_player_android plugin compiles against 37
    // because the playback engine does, and an app cannot compile against a lower SDK than a
    // library it consumes. Compile SDKs are backward compatible, so this does not raise minSdk or
    // targetSdk.
    compileSdk = 37
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        // Required by the IMA libraries the playback engine ships for client-side ad insertion:
        // media3-exoplayer-ima and interactivemedia both declare it in their AAR metadata, and the
        // build fails at checkDebugAarMetadata without it. Needed even though this app does not
        // enable ads yet — the dependency arrives with the engine either way.
        isCoreLibraryDesugaringEnabled = true
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.flutter_steam_tv"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        // 26, not flutter.minSdkVersion (24): the playback engine's floor, because Media3 and the
        // engine's own APIs need it. Android TV devices below 26 are out of scope anyway — see
        // android_stream_player/architecture.md, "What the consumer must provide".
        minSdk = 26
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

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
}
