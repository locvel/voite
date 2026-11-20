import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

tasks.register("validateReleaseSigning") {
    doLast {
        val requiredValues = listOf("keyAlias", "keyPassword", "storeFile", "storePassword")
        val missingValues = requiredValues.filter {
            keystoreProperties.getProperty(it).isNullOrBlank()
        }
        if (!keystorePropertiesFile.isFile || missingValues.isNotEmpty()) {
            throw GradleException(
                "Release builds require a complete android/key.properties and upload keystore.",
            )
        }
        val uploadKey = project.file(keystoreProperties.getProperty("storeFile"))
        if (!uploadKey.isFile) {
            throw GradleException("The upload keystore configured for release was not found.")
        }
    }
}

tasks.configureEach {
    if (name == "assembleRelease" || name == "bundleRelease") {
        dependsOn("validateReleaseSigning")
    }
}

android {
    namespace = "com.locvel.voite"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.locvel.voite"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 30
        targetSdk = 36
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        ndk {
            // The app's strict 30 MB AAB gate currently requires 64-bit ARM only.
            abiFilters += "arm64-v8a"
        }
    }

    packaging {
        jniLibs {
            // sherpa_onnx is split into prebuilt ABI subprojects; filter those too.
            // This means 32-bit ARM and x86 Android devices are not supported.
            excludes += setOf(
                "lib/armeabi-v7a/**",
                "lib/x86/**",
                "lib/x86_64/**",
            )
        }
    }

    signingConfigs {
        create("release") {
            if (keystorePropertiesFile.exists()) {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        release {
            // Release artifacts must use the upload key; never silently sign
            // them with the public debug key.
            signingConfig = signingConfigs.getByName("release")
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
            ndk {
                debugSymbolLevel = "SYMBOL_TABLE"
            }
        }
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

tasks.named("preBuild").configure {
    dependsOn("syncAppName")
}

tasks.register<Exec>("syncAppName") {
    workingDir(rootProject.projectDir.parentFile)
    commandLine("python3", "tool/sync_app_name.py")
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
