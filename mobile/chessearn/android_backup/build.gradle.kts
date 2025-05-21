buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath 'com.android.tools.build:gradle:8.4.0'  // Updated for Flutter 3.22.0
        classpath 'org.jetbrains.kotlin:kotlin-gradle-plugin:1.9.23'
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
        maven { url 'https://jitpack.io' }
    }
}