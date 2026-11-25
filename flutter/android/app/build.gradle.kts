import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.isFile) {
    FileInputStream(keystorePropertiesFile).use { keystoreProperties.load(it) }
}

val releaseSigningKeys = listOf("storePassword", "keyPassword", "keyAlias", "storeFile")
val hasReleaseSigning = keystorePropertiesFile.isFile &&
    releaseSigningKeys.all { key -> !keystoreProperties.getProperty(key).isNullOrBlank() }

android {
    namespace = "com.example.travia"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.travia"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // Usa a chave local somente quando todas as propriedades existirem.
            // Sem credenciais, mantém o fallback de desenvolvimento para permitir
            // validações locais sem inventar ou expor uma assinatura de produção.
            if (hasReleaseSigning) {
                signingConfig = signingConfigs.create("release") {
                    keyAlias = keystoreProperties.getProperty("keyAlias")
                    keyPassword = keystoreProperties.getProperty("keyPassword")
                    storeFile = file(keystoreProperties.getProperty("storeFile"))
                    storePassword = keystoreProperties.getProperty("storePassword")
                }
            } else {
                signingConfig = signingConfigs.getByName("debug")
            }
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

// Flutter 3.50.1 inclui o integration_test no registrante Android gerado,
// embora o plugin permaneça em dev_dependencies e não entre no classpath do
// aplicativo. Mantemos a dependência explícita para que o registrante gerado
// compile em todos os variants; o plugin não contém credenciais nem código da
// aplicação.
dependencies {
    implementation(project(":integration_test"))
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
