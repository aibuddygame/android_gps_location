package com.gps.faker

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Context
import android.content.Intent
import android.location.Criteria
import android.location.Location
import android.location.LocationManager
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.os.PowerManager
import android.os.SystemClock
import androidx.core.app.NotificationCompat

class MockLocationForegroundService : Service() {
    private lateinit var locationManager: LocationManager
    private val handler = Handler(Looper.getMainLooper())
    private var wakeLock: PowerManager.WakeLock? = null
    private var updateRunnable: Runnable? = null

    private var latitude: Double = 0.0
    private var longitude: Double = 0.0
    private var accuracy: Float = 5f
    private var speed: Float = 0f
    private var bearing: Float = 0f
    private var intervalMs: Long = 1000L

    override fun onCreate() {
        super.onCreate()
        locationManager = getSystemService(Context.LOCATION_SERVICE) as LocationManager
        createNotificationChannel()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_STOP -> stopMocking()
            ACTION_START, null -> startMocking(intent)
        }
        return START_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onDestroy() {
        stopUpdates(removeProvider = true)
        super.onDestroy()
    }

    private fun startMocking(intent: Intent?) {
        latitude = intent?.getDoubleExtra("latitude", latitude) ?: latitude
        longitude = intent?.getDoubleExtra("longitude", longitude) ?: longitude
        accuracy = (intent?.getDoubleExtra("accuracy", accuracy.toDouble()) ?: accuracy.toDouble()).toFloat()
        speed = (intent?.getDoubleExtra("speed", speed.toDouble()) ?: speed.toDouble()).toFloat()
        bearing = (intent?.getDoubleExtra("bearing", bearing.toDouble()) ?: bearing.toDouble()).toFloat()
        intervalMs = (intent?.getIntExtra("intervalMs", intervalMs.toInt()) ?: intervalMs.toInt())
            .coerceAtLeast(250)
            .toLong()

        startForeground(NOTIFICATION_ID, buildNotification())
        acquireWakeLock()
        ensureTestProvider()
        isRunning = true
        scheduleNextUpdate(immediate = true)
    }

    private fun stopMocking() {
        stopUpdates(removeProvider = true)
        stopForeground(STOP_FOREGROUND_REMOVE)
        stopSelf()
    }

    private fun stopUpdates(removeProvider: Boolean) {
        updateRunnable?.let { handler.removeCallbacks(it) }
        updateRunnable = null
        isRunning = false
        wakeLock?.takeIf { it.isHeld }?.release()
        wakeLock = null
        if (removeProvider) {
            runCatching {
                locationManager.removeTestProvider(LocationManager.GPS_PROVIDER)
            }
        }
    }

    private fun scheduleNextUpdate(immediate: Boolean) {
        updateRunnable?.let { handler.removeCallbacks(it) }
        updateRunnable = Runnable {
            runCatching {
                pushLocation()
                scheduleNextUpdate(immediate = false)
            }.onFailure {
                stopMocking()
            }
        }
        handler.postDelayed(updateRunnable!!, if (immediate) 0L else intervalMs)
    }

    private fun ensureTestProvider() {
        runCatching {
            locationManager.addTestProvider(
                LocationManager.GPS_PROVIDER,
                false,
                false,
                false,
                false,
                true,
                true,
                true,
                Criteria.POWER_LOW,
                Criteria.ACCURACY_FINE
            )
        }
        runCatching {
            locationManager.setTestProviderEnabled(LocationManager.GPS_PROVIDER, true)
        }
    }

    private fun pushLocation() {
        val location = Location(LocationManager.GPS_PROVIDER).apply {
            latitude = this@MockLocationForegroundService.latitude
            longitude = this@MockLocationForegroundService.longitude
            accuracy = this@MockLocationForegroundService.accuracy
            speed = this@MockLocationForegroundService.speed
            bearing = this@MockLocationForegroundService.bearing
            time = System.currentTimeMillis()
            elapsedRealtimeNanos = SystemClock.elapsedRealtimeNanos()
        }
        locationManager.setTestProviderLocation(LocationManager.GPS_PROVIDER, location)
    }

    private fun acquireWakeLock() {
        if (wakeLock?.isHeld == true) return
        val powerManager = getSystemService(Context.POWER_SERVICE) as PowerManager
        wakeLock = powerManager.newWakeLock(
            PowerManager.PARTIAL_WAKE_LOCK,
            "GpsLocationChanger:MockLocation"
        ).apply {
            setReferenceCounted(false)
            acquire()
        }
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val channel = NotificationChannel(
            CHANNEL_ID,
            getString(R.string.mock_location_channel),
            NotificationManager.IMPORTANCE_LOW
        )
        getSystemService(NotificationManager::class.java).createNotificationChannel(channel)
    }

    private fun buildNotification(): Notification {
        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setSmallIcon(android.R.drawable.ic_menu_mylocation)
            .setContentTitle(getString(R.string.app_name))
            .setContentText("Mocking %.6f, %.6f every %d ms".format(latitude, longitude, intervalMs))
            .setOngoing(true)
            .setOnlyAlertOnce(true)
            .build()
    }

    companion object {
        const val ACTION_START = "com.gps.faker.START"
        const val ACTION_STOP = "com.example.gps_location_changer.STOP"
        private const val CHANNEL_ID = "mock_location"
        private const val NOTIFICATION_ID = 7401

        @Volatile
        var isRunning: Boolean = false
            private set
    }
}
