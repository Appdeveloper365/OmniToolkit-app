import java.util.Properties
import java.util.Base64

plugins {
    id("com.android.application")
    id("dev.flutter.flutter-gradle-plugin")
}

if (file("google-services.json").exists()) {
    apply(plugin = "com.google.gms.google-services")
}

val localProperties = Properties()
val localPropertiesFile = rootProject.file("key.properties")
if (localPropertiesFile.exists()) {
    localPropertiesFile.inputStream().use { localProperties.load(it) }
}

val decodedKeystorePath = System.getenv("ANDROID_KEYSTORE_BASE64")?.takeIf { it.isNotBlank() }?.let { encoded ->
    val output = layout.buildDirectory.file("generated/keystore/omnitoolkit-release.jks").get().asFile
    output.parentFile.mkdirs()
    output.writeBytes(Base64.getDecoder().decode(encoded))
    output.absolutePath
}

fun signingValue(name: String): String? = System.getenv(name)?.takeIf { it.isNotBlank() } ?: localProperties.getProperty(name)
val releaseSigningConfigured = !decodedKeystorePath.isNullOrBlank() || !signingValue("ANDROID_KEYSTORE_PATH").isNullOrBlank()

android {
    namespace = "com.omnitoolkit.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.omnitoolkit.app"
        minSdk = maxOf(flutter.minSdkVersion, 23)
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            val storeFilePath = decodedKeystorePath ?: signingValue("ANDROID_KEYSTORE_PATH")
            if (!storeFilePath.isNullOrBlank()) {
                storeFile = file(storeFilePath)
                storePassword = signingValue("ANDROID_KEYSTORE_PASSWORD")
                keyAlias = signingValue("ANDROID_KEY_ALIAS")
                keyPassword = signingValue("ANDROID_KEY_PASSWORD")
            }
        }
    }

    buildTypes {
        release {
            if (!releaseSigningConfigured) {
                throw GradleException("Release signing is required. Configure android/key.properties locally or ANDROID_KEYSTORE_BASE64, ANDROID_KEYSTORE_PASSWORD, ANDROID_KEY_ALIAS, ANDROID_KEY_PASSWORD in CI.")
            }
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = false
            isShrinkResources = false
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

