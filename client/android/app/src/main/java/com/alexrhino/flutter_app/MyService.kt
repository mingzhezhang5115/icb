package com.alexrhino.flutter_app

import android.app.job.JobInfo
import android.app.job.JobInfo.TriggerContentUri
import android.app.job.JobParameters
import android.app.job.JobScheduler
import android.app.job.JobService
import android.content.ComponentName
import android.content.Context
import android.database.Cursor
import android.net.Uri
import android.os.Environment
import android.os.Handler
import android.provider.MediaStore
import android.util.Log
import android.widget.Toast
import androidx.work.*
import java.util.*
import com.alexrhino.flutter_app.ProgressWorker.Companion.Progress
import com.android.volley.Request
import com.android.volley.RequestQueue
import com.android.volley.Response
import com.android.volley.VolleyError
import com.android.volley.toolbox.StringRequest
import com.android.volley.toolbox.Volley

/**
 * Example stub job to monitor when there is a change to photos in the media provider.
 */
class MyService : JobService() {
    // Fake job work.  A real implementation would do some work on a separate thread.
    val mHandler = Handler()
    val mWorker = Runnable {
        //scheduleJob(this@MyService)

        jobFinished(mRunningParams, false)
    }
    var mRunningParams: JobParameters? = null
    override fun onStartJob(params: JobParameters): Boolean {
        Log.i("PhotosContentJob", "JOB STARTED!")
        var imageList = mutableListOf<Long>()
        for (uri in params.triggeredContentUris!!) {
            var imageID = uri.lastPathSegment!!.toLong()
            imageList.add(imageID)
        }
        val constraints = Constraints.Builder()
                .build()
        val imageData = workDataOf(Pair("uriList",  imageList.joinToString( "," )))
        val cacheCleanupTask =
                OneTimeWorkRequestBuilder<ProgressWorker>()
                        .setConstraints(constraints)
                        .setInputData(imageData)
                        .addTag("upload")
                        .build()
        //WorkManager.enqueue(cacheCleanupTask);
        WorkManager.getInstance(this).enqueue(cacheCleanupTask)
        Log.i("PhotosContentJob", imageList.joinToString( "," ))
        //https://developer.android.com/topic/libraries/architecture/workmanager/how-to/define-work
/*        val queue = Volley.newRequestQueue(applicationContext)
        val url = "http://192.168.97.101:5000/"

// Request a string response from the provided URL.
        val stringRequest = StringRequest(Request.Method.GET, url,
                Response.Listener<String> { response ->
                    // Display the first 500 characters of the response string.
                    Log.i("MyService", response)
                },
//               Response.ErrorListener { error ->  Log.i("MyService", error.toString())*/
// Add the request to the RequestQueue.
  //      queue.add(stringRequest)


        scheduleJob(this)
        return false
    }

/*    fun scheduleJob(context: Context) {
        val jobScheduler = context.getSystemService(Context.JOB_SCHEDULER_SERVICE) as JobScheduler
        val job = JobInfo.Builder(
                MY_BACKGROUND_JOB,
                ComponentName(context, MyService::class.java)
        )
                .addTriggerContentUri(
                        JobInfo.TriggerContentUri(
                                MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
                                JobInfo.TriggerContentUri.FLAG_NOTIFY_FOR_DESCENDANTS
                        )
                )
                .build()
        jobScheduler.schedule(job)
    }*/

    override fun onStopJob(params: JobParameters): Boolean {
        //mHandler.removeCallbacks(mWorker)
        Log.i("PhotosContentJob", "JOB STOPPED!")
        return false
    }
/*    override fun onStartJob(params: JobParameters): Boolean {
        Log.i("PhotosContentJob", "JOB STARTED!")
        mRunningParams = params
        // Instead of real work, we are going to build a string to show to the user.
        val sb = StringBuilder()
        // Did we trigger due to a content change?
        if (params.triggeredContentAuthorities != null) {
            var rescanNeeded = false
            if (params.triggeredContentUris != null) { // If we have details about which URIs changed, then iterate through them
// and collect either the ids that were impacted or note that a generic
// change has happened.
                val ids = ArrayList<String>()
                for (uri in params.triggeredContentUris) {
                    val path = uri.pathSegments
                    if (path != null && path.size == EXTERNAL_PATH_SEGMENTS.size + 1) { // This is a specific file.
                        ids.add(path[path.size - 1])
                    } else { // Oops, there is some general change!
                        rescanNeeded = true
                    }
                }
                if (ids.size > 0) { // If we found some ids that changed, we want to determine what they are.
// First, we do a query with content provider to ask about all of them.
                    val selection = StringBuilder()
                    for (i in ids.indices) {
                        if (selection.length > 0) {
                            selection.append(" OR ")
                        }
                        selection.append(MediaStore.Images.ImageColumns._ID)
                        selection.append("='")
                        selection.append(ids[i])
                        selection.append("'")
                    }
                    // Now we iterate through the query, looking at the filenames of
// the items to determine if they are ones we are interested in.
                    var cursor: Cursor? = null
                    var haveFiles = false
                    try {
                        cursor = contentResolver.query(
                                MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
                                PROJECTION, selection.toString(), null, null)
                        while (cursor.moveToNext()) { // We only care about files in the DCIM directory.
                            val dir = cursor.getString(PROJECTION_DATA)
                            if (dir.startsWith(DCIM_DIR)) {
                                if (!haveFiles) {
                                    haveFiles = true
                                    sb.append("New photos:\n")
                                }
                                sb.append(cursor.getInt(PROJECTION_ID))
                                sb.append(": ")
                                sb.append(dir)
                                sb.append("\n")
                            }
                        }
                    } catch (e: SecurityException) {
                        sb.append("Error: no access to media!")
                    } finally {
                        cursor?.close()
                    }
                }
            } else { // We don't have any details about URIs (because too many changed at once),
// so just note that we need to do a full rescan.
                rescanNeeded = true
            }
            if (rescanNeeded) {
                sb.append("Photos rescan needed!")
            }
        } else {
            sb.append("(No photos content)")
        }
        Toast.makeText(this, sb.toString(), Toast.LENGTH_LONG).show()
        // We will emulate taking some time to do this work, so we can see batching happen.
        mHandler.postDelayed(mWorker, 10 * 1000.toLong())
        return true
    }

    override fun onStopJob(params: JobParameters): Boolean {
        mHandler.removeCallbacks(mWorker)
        return false
    }*/
}