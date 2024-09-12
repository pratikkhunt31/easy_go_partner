package com.easy_go.partner

import android.Manifest
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.location.Location
import android.os.Build
import android.os.IBinder
import android.os.Looper
import android.util.Log
import androidx.core.app.ActivityCompat
import androidx.core.app.NotificationCompat
import com.google.android.gms.location.*
import com.google.firebase.database.DatabaseReference
import com.google.firebase.database.FirebaseDatabase

class LocationService : Service() {
    private lateinit var fusedLocationClient: FusedLocationProviderClient
    private lateinit var locationCallback: LocationCallback
    private lateinit var databaseReference: DatabaseReference

    private lateinit var rideRequestId: String

    override fun onBind(intent: Intent?): IBinder? {
        return null
    }

    override fun onCreate() {
        super.onCreate()

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                "LocationServiceChannel",
                "Location Service",
                NotificationManager.IMPORTANCE_HIGH
            )

            val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            manager.createNotificationChannel(channel)
        }

        fusedLocationClient = LocationServices.getFusedLocationProviderClient(this)
        databaseReference = FirebaseDatabase.getInstance().getReference("Ride Request")

        locationCallback = object : LocationCallback() {
            override fun onLocationResult(p0: LocationResult) {
                p0 ?: return
                for (location in p0.locations) {
                    updateLocationInFirebase(location)
                }
            }
        }
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            Actions.START.toString() -> startService()
        }

        if (intent?.extras != null) {
            rideRequestId = intent.extras!!.getString("rideRequestId")!!
        }

        return super.onStartCommand(intent, flags, startId)
    }

    override fun onDestroy() {
        stopLocationUpdates()

        super.onDestroy()
    }

    enum class Actions {
        START
    }

    private fun startLocationUpdates() {
        val locationRequest = LocationRequest.Builder(Priority.PRIORITY_HIGH_ACCURACY, 5000)
            .setMinUpdateIntervalMillis(2000)
            .build()

        if (ActivityCompat.checkSelfPermission(
                this,
                Manifest.permission.ACCESS_FINE_LOCATION
            ) != PackageManager.PERMISSION_GRANTED && ActivityCompat.checkSelfPermission(
                this,
                Manifest.permission.ACCESS_COARSE_LOCATION
            ) != PackageManager.PERMISSION_GRANTED
        ) {
            return
        }

        fusedLocationClient.requestLocationUpdates(locationRequest, locationCallback, Looper.getMainLooper())
    }

    private fun stopLocationUpdates() {
        Log.d("LocationService", "Stopping the service.")

        fusedLocationClient.removeLocationUpdates(locationCallback)
    }

    private fun startService() {
        val notification = NotificationCompat.Builder(this, "LocationServiceChannel")
            .setContentTitle("Location Service Active")
            .setContentText("We are updating your location and sharing with user.")
            .setSmallIcon(R.mipmap.ic_launcher)
            .setOngoing(true)
            .build()

        startForeground(1, notification)
        startLocationUpdates()
    }

    private fun updateLocationInFirebase(location : Location) {
        Log.d("LocationService", "Updating location: ${location.latitude}, ${location.longitude}")

        databaseReference.child(rideRequestId).child("d_location").setValue(mapOf(
            "latitude" to location.latitude,
            "longitude" to location.longitude
        ))
            .addOnSuccessListener {
                Log.d("LocationService", "Location updated successfully.")
            }
            .addOnFailureListener { e ->
                Log.e("LocationService", "Failed to update location.", e)
            }
    }

    companion object {
        // Method to check if the service is running
        fun isServiceRunning(context: Context): Boolean {
            return LocationServiceHelper.isMyServiceRunning(LocationService::class.java, context)
        }
    }
}
