package com.example.fitquest

import android.Manifest
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.pm.PackageManager
import android.os.Build
import androidx.core.app.ActivityCompat
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {

    private val CHANNEL = "fitquest/notifications"
    private val NOTIFICATION_PERMISSION_CODE = 1001
    private val MOTIVATION_CHANNEL_ID = "fitquest_motivation"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        createNotificationChannel()

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->

            when (call.method) {

                "initialize" -> {
                    createNotificationChannel()
                    result.success(true)
                }

                "requestPermission" -> {
                    requestNotificationPermission()
                    result.success(true)
                }

                "showNotification" -> {
                    val title =
                        call.argument<String>("title") ?: "FitQuest"

                    val message =
                        call.argument<String>("message")
                            ?: "Keep moving!"

                    showNotification(title, message)
                    result.success(true)
                }

                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {

            val channel = NotificationChannel(
                MOTIVATION_CHANNEL_ID,
                "FitQuest Motivation",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description =
                    "Motivational notifications from FitQuest"
            }

            val manager =
                getSystemService(NotificationManager::class.java)

            manager.createNotificationChannel(channel)
        }
    }

    private fun requestNotificationPermission() {

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {

            if (
                ActivityCompat.checkSelfPermission(
                    this,
                    Manifest.permission.POST_NOTIFICATIONS
                ) != PackageManager.PERMISSION_GRANTED
            ) {
                ActivityCompat.requestPermissions(
                    this,
                    arrayOf(Manifest.permission.POST_NOTIFICATIONS),
                    NOTIFICATION_PERMISSION_CODE
                )
            }
        }
    }

    private fun showNotification(
        title: String,
        message: String
    ) {

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {

            if (
                ActivityCompat.checkSelfPermission(
                    this,
                    Manifest.permission.POST_NOTIFICATIONS
                ) != PackageManager.PERMISSION_GRANTED
            ) {
                requestNotificationPermission()
                return
            }
        }

        val notification =
            NotificationCompat.Builder(
                this,
                MOTIVATION_CHANNEL_ID
            )
                .setSmallIcon(com.example.fitquest.R.mipmap.ic_launcher)
                .setContentTitle(title)
                .setContentText(message)
                .setPriority(NotificationCompat.PRIORITY_HIGH)
                .setAutoCancel(true)
                .build()

        NotificationManagerCompat
            .from(this)
            .notify(
                System.currentTimeMillis().toInt(),
                notification
            )
    }
}