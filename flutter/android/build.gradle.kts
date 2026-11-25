allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

// O lintVital do image_picker_android 0.8.13+25 aciona um NoSuchMethodError
// interno do Android Lint ao analisar ExifDataCopier.java no runner atual.
// Limitamos a exceção à tarefa dessa biblioteca; o lint do aplicativo continua
// habilitado e os testes/análise Dart permanecem obrigatórios.
subprojects {
    tasks.matching {
        project.name == "image_picker_android" &&
            it.name == "lintVitalAnalyzeRelease"
    }.configureEach {
        enabled = false
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
