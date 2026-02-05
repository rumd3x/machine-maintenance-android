package com.rumd3x.machine_maintenance

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

/**
 * Boot receiver to ensure app is aware of boot events
 * Workmanager plugin handles its own boot receiver and rescheduling
 */
class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == Intent.ACTION_BOOT_COMPLETED ||
            intent.action == Intent.ACTION_MY_PACKAGE_REPLACED) {
            Log.d("BootReceiver", "Device booted or app updated - workmanager will reschedule tasks")
        }
    }
}
