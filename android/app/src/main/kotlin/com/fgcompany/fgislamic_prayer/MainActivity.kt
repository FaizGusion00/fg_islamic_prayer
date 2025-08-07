package com.fgcompany.fgislamic_prayer

import android.os.Build
import java.util.TimeZone
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.fgcompany.fgislamic_prayer/sdk"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getSdkInt" -> {
                    result.success(Build.VERSION.SDK_INT)
                }
                "getTimeZoneName" -> {
                    result.success(TimeZone.getDefault().id)
                }
                else -> result.notImplemented()
            }
        }
    }
}