pluginManagement {
    val flutterSdkPath =
        run {
            val properties = java.util.Properties()
            file("local.properties").inputStream().use { properties.load(it) }
            val flutterSdkPath = properties.getProperty("flutter.sdk")
            require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
            flutterSdkPath
        }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    // 9.3.2 to match android_stream_player, the engine behind stream_player_android. Its
    // transitive dependencies (Media3 1.11, Compose 1.12, core-ktx 1.19) all require AGP 9.1.0 or
    // higher, so 9.0.1 failed to configure. Matching the engine exactly leaves one AGP version
    // across the bridge rather than two to keep in step.
    id("com.android.application") version "9.3.2" apply false
    // Explicit, because AGP 9.3.2's built-in Kotlin is 2.2.10 and Flutter 3.47 requires >= 2.2.20.
    // See the note beside `android.builtInKotlin` in gradle.properties.
    id("org.jetbrains.kotlin.android") version "2.3.20" apply false
}

include(":app")
