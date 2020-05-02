package com.alexrhino.flutter_app

import io.flutter.app.FlutterApplication
import androidx.work.Configuration
//        #android:name="io.flutter.app.FlutterApplication"
//https://stackoverflow.com/questions/55334431/facing-below-error-toolsnode-associated-with-an-element-type-uses-permission
class FlutterApplication : FlutterApplication(), Configuration.Provider {
    override fun getWorkManagerConfiguration() =
    Configuration.Builder()
    .setMinimumLoggingLevel(android.util.Log.DEBUG)
    .build()
}
