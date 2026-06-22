package com.example.health_minister_application

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.yegna_health/maps_config"
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "getGoogleMapsApiKey" -> result.success(getString(R.string.google_maps_api_key))
                else -> result.notImplemented()
            }
        }

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.yegna_health/device"
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "getLocalTimeZone" -> result.success(java.util.TimeZone.getDefault().id)
                else -> result.notImplemented()
            }
        }
    }
}
