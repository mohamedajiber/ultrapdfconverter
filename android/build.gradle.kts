buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        val kotlin_version = "1.9.23" // Example: Replace with your chosen version
        val agp_version = "8.1.0"   // Example: Replace with your chosen version

        classpath("com.android.tools.build:gradle:$agp_version")
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Apply namespace to all library modules
// This block should be *outside* the `buildscript` block for `allprojects` configuration
plugins.withId("com.android.library") {
    configure<com.android.build.gradle.LibraryExtension> {
        namespace = "com.google.ads" // Ensure this namespace is appropriate for your project
    }
}

// Keep your custom build directory setup
val newBuildDir = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.set(newBuildDir)

subprojects {
    val newSubprojectBuildDir = newBuildDir.dir(project.name)
    project.layout.buildDirectory.set(newSubprojectBuildDir)
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}