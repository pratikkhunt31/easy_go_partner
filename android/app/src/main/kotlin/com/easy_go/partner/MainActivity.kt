package com.easy_go.partner

import android.app.ActivityManager.RunningServiceInfo
import android.content.Intent
import android.location.Location
import androidx.annotation.NonNull
import androidx.core.app.ActivityCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.android.KeyData.CHANNEL
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {

    private val channel = "com.easy_go.partner/locationService"
    private val locationService = LocationService()

    override fun configureFlutterEngine(flutterEngine: io.flutter.embedding.engine.FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channel).setMethodCallHandler { call, result ->
            when (call.method) {
                "startService" -> {
                    val id: String? = call.argument<String>("rideRequestId")

                    startLocationService(id!!)
                    result.success("Service started")
                }
                "stopService" -> {
                    stopLocationService()
                    result.success("Service stopped")
                }
                "isServiceRunning" -> {
                    val isRunning = isLocationServiceRunning()
                    result.success(isRunning)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun startLocationService(id: String) {
        val serviceIntent = Intent(this, LocationService::class.java)
        serviceIntent.action = LocationService.Actions.START.toString()
        serviceIntent.putExtra("rideRequestId", id)
        this.startService(serviceIntent)
    }

    private fun stopLocationService() {
        val serviceIntent = Intent(this, LocationService::class.java)
        this.stopService(serviceIntent)
    }

    private fun isLocationServiceRunning(): Boolean {
        return LocationService.isServiceRunning(this)
    }
}
