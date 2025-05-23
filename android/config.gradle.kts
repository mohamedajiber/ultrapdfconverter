// config.gradle.kts
allprojects {
    plugins.withId("com.android.library") {
        configure<com.android.build.gradle.LibraryExtension> {
            namespace = "com.google.ads"
        }
    }
}