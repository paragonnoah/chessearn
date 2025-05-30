include ':app'

def localPropertiesFile = new File(rootProject.projectDir, "local.properties")
def properties = new Properties()

if (localPropertiesFile.exists()) {
    localPropertiesFile.withReader("UTF-8") { reader -> properties.load(reader) }
}

def flutterSdkPath = properties.getProperty("flutter.sdk")
if (flutterSdkPath == null) {
    throw new GradleException("flutter.sdk not set in local.properties")
}

apply from: "$flutterSdkPath/packages/flutter_tools/gradle/flutter.gradle"