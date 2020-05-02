package com.alexrhino.flutter_app

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log
import android.widget.Toast

private const val TAG = "MyBroadcastReceiver"

class MyReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
/*        StringBuilder().apply {
            append("Action: ${intent.action}\n")
            append("URI: ${intent.toUri(Intent.URI_INTENT_SCHEME)}\n")
            toString().also { log ->
                Log.d(TAG, log)
                Toast.makeText(context, log, Toast.LENGTH_LONG).show()
            }
        }*/
        Log.i(TAG, "Received broadcast" + intent.action.toString())
        scheduleJob(context)
    }

}

