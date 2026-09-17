allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

subprojects {
    tasks.whenTaskAdded {
        if (name.contains("verifyReleaseResources", ignoreCase = true)) {
            enabled = false
        }
    }
    val injectNamespace = {
        val android = extensions.findByType<com.android.build.gradle.BaseExtension>()
        if (android != null && android.namespace == null) {
            android.namespace = if (project.group.toString().isEmpty()) "com.odjek.${project.name}" else project.group.toString()
        }
    }
    if (state.executed) {
        injectNamespace()
    } else {
        afterEvaluate { injectNamespace() }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
