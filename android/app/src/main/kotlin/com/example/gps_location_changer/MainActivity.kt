package com.example.gps_location_changer

import android.app.AppOpsManager
import android.content.Context
import android.content.Intent
import android.os.Build
import android.provider.Settings
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "gps_location_changer/mock_location"
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "start" -> {
                    val intent = Intent(this, MockLocationForegroundService::class.java).apply {
                        action = MockLocationForegroundService.ACTION_START
                        putExtra("latitude", call.argument<Double>("latitude") ?: 0.0)
                        putExtra("longitude", call.argument<Double>("longitude") ?: 0.0)
                        putExtra("accuracy", call.argument<Double>("accuracy") ?: 5.0)
                        putExtra("speed", call.argument<Double>("speed") ?: 0.0)
                        putExtra("bearing", call.argument<Double>("bearing") ?: 0.0)
                        putExtra("intervalMs", call.argument<Int>("intervalMs") ?: 1000)
                    }
                    ContextCompat.startForegroundService(this, intent)
                    result.success(null)
                }
                "stop" -> {
                    val intent = Intent(this, MockLocationForegroundService::class.java).apply {
                        action = MockLocationForegroundService.ACTION_STOP
                    }
                    startService(intent)
                    result.success(null)
                }
                "isRunning" -> result.success(MockLocationForegroundService.isRunning)
                "isMockLocationEnabled" -> result.success(isMockLocationEnabled())
                "openDeveloperOptions" -> {
                    startActivity(Intent(Settings.ACTION_APPLICATION_DEVELOPMENT_SETTINGS))
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun isMockLocationEnabled(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            val appOps = getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
            val mode = appOps.unsafeCheckOpNoThrow(
                AppOpsManager.OPSTR_MOCK_LOCATION,
                android.os.Process.myUid(),
                packageName
            )
            mode == AppOpsManager.MODE_ALLOWED
        } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val appOps = getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
            val mode = appOps.checkOpNoThrow(
                AppOpsManager.OPSTR_MOCK_LOCATION,
                android.os.Process.myUid(),
                packageName
            )
            mode == AppOpsManager.MODE_ALLOWED
        } else {
            Settings.Secure.getString(contentResolver, Settings.Secure.ALLOW_MOCK_LOCATION) == "1"
        }
    }
}
