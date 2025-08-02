android {
    namespace "com.example.zhaiyana"
    compileSdkVersion 34
    ndkVersion "27.0.12077973"

    defaultConfig {
        applicationId "com.example.zhaiyana"
        minSdkVersion 21
        targetSdkVersion 34
        versionCode flutterVersionCode.toInteger()
        versionName flutterVersionName
    }

    buildTypes {
        release {
            signingConfig signingConfigs.debug
        }
    }
}
