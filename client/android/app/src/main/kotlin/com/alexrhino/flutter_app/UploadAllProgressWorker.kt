package com.alexrhino.flutter_app

//import androidx.work.Data

//import android.media.ExifInterface.TAG_PIXEL_X_DIMENSION
//import android.media.ExifInterface
//import androidx.exifinterface.media.ExifInterface.TAG_PIXEL_X_DIMENSION

import android.content.ContentResolver
import android.content.ContentUris
import android.content.Context
import android.graphics.Bitmap
import android.graphics.ColorSpace
import android.graphics.ImageDecoder
import android.net.Uri
import android.provider.BaseColumns
import android.provider.MediaStore
import android.util.Log
import android.util.Size
import android.util.TimeUtils
import androidx.exifinterface.media.ExifInterface
import androidx.work.*
import com.alexrhino.flutter_app.ProgressWorker.Companion.mediaTypeJson
import com.android.volley.Request
import com.android.volley.Response
import com.android.volley.toolbox.JsonObjectRequest
import com.android.volley.toolbox.StringRequest
import com.android.volley.toolbox.Volley
import kotlinx.coroutines.delay
import okhttp3.*
import org.json.JSONObject
import org.tensorflow.lite.DataType
import org.tensorflow.lite.Interpreter
import org.tensorflow.lite.support.common.FileUtil
import org.tensorflow.lite.support.common.TensorProcessor
import org.tensorflow.lite.support.image.ImageProcessor
import org.tensorflow.lite.support.image.TensorImage
import org.tensorflow.lite.support.image.ops.ResizeOp
import org.tensorflow.lite.support.image.ops.ResizeWithCropOrPadOp
import org.tensorflow.lite.support.tensorbuffer.TensorBuffer
import java.io.ByteArrayOutputStream
import java.security.MessageDigest
import org.tensorflow.lite.support.label.TensorLabel
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.RequestBody.Companion.toRequestBody
import okio.IOException
import java.util.concurrent.TimeUnit

private const val TAG = "UploadAllProgressWorker"

class UploadAllProgressWorker(context: Context, parameters: WorkerParameters) : CoroutineWorker(context, parameters) {

    override suspend fun doWork(): Result {
        //val imageUriList = getInputData().getStringArray("uriArray")
        val constraints = Constraints.Builder()
                .build()
        val projection = arrayOf(
                MediaStore.Images.Media._ID
        )
        val cursor = applicationContext.getContentResolver().query(MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
                projection, null, null, null)
        cursor!!.extras.putInt(ContentResolver.QUERY_ARG_OFFSET,0)
        cursor.moveToFirst()
        //var index = 0;
        val dbHelper = ICBDbHelper(applicationContext)
        val db = dbHelper.readableDatabase
        var imageList = mutableListOf<Long>()
// Define a projection that specifies which columns from the database
// you will actually use after this query.
        //val sqlProjection = arrayOf(BaseColumns._ID, ICBReaderContract.ICBEntry.COLUMN_NAME_URI, ICBReaderContract.ICBEntry.COLUMN_NAME_UPLOADED)

// Filter results WHERE "title" = 'My Title'


        do {
            var imageIndex = cursor.getColumnIndex(MediaStore.Images.Media._ID)
            if(imageIndex !=null) {
                Log.d("Found image index", imageIndex.toString())
                var imageID = cursor.getString(imageIndex)
                Log.d("Found image", imageID.toString())
                var imageUri = ContentUris.withAppendedId(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, imageID.toLong())
                val selection = "${ICBReaderContract.ICBEntry.COLUMN_NAME_URI} = ?"
                val selectionArgs = arrayOf(imageUri.toString())

// How you want the results sorted in the resulting Cursor
                //val sortOrder = "${ICBReaderContract.ICBEntry.COLUMN_NAME_URI} DESC"

                val dbCursor = db.query(
                        ICBReaderContract.ICBEntry.TABLE_NAME,   // The table to query
                        null,             // The array of columns to return (pass null to get all)
                        selection,              // The columns for the WHERE clause
                        selectionArgs,          // The values for the WHERE clause
                        null,                   // don't group the rows
                        null,                   // don't filter by row groups
                        null               // The sort order
                )
                var uploaded = false
                with(dbCursor) {
                    while (moveToNext()) {
                        val imageUriEntry = getString(getColumnIndexOrThrow(ICBReaderContract.ICBEntry.COLUMN_NAME_URI))
                        val imageUploadedEntry = getInt(getColumnIndexOrThrow(ICBReaderContract.ICBEntry.COLUMN_NAME_UPLOADED))
                        Log.i("AllUploadeWorkManger", "Image " + imageUriEntry + imageUploadedEntry.toString())
                        if (imageUploadedEntry == 1){
                            uploaded = true
                        }
                        //itemIds.add(itemId)
                    }
                }
                dbCursor.close()
                if (uploaded){
                    Log.i("AllUploadeWorkManger", "Image " + imageUri.toString() + " not uploaded add job")
                    continue
                }else {
                    Log.i("AllUploadeWorkManger", "To upload " + imageUri.toString())
                    imageList.add(imageID.toLong())
                }

            }
        } while(cursor.moveToNext())
        for (s in imageList) {
            Log.i("AllUploadeWorkManger", "To upload " + s.toString())
        }
        Log.i("AllUploadeWorkManger","To upload" + imageList.joinToString(","))
                val imageData = workDataOf(Pair("uriList", imageList.joinToString( "," )))
        //val workInfo = WorkManager.getInstance(applicationContext).getWorkInfosByTag("upload")
        //
        val uploadImageTask =
                OneTimeWorkRequestBuilder<ProgressWorker>()
                        //.setInitialDelay(((index/10.0)*10).toLong(), TimeUnit.SECONDS)
                        .setConstraints(constraints)
                        .setInputData(imageData)
                        .addTag("upload")
                        //.addTag(imageUri.toString())
                        .build()
        var workInfoList = WorkManager.getInstance(applicationContext).getWorkInfosForUniqueWork("uploadAll").await()
        //val workInfos = workManager.getWorkInfosForUniqueWork(workName).await()
        if (workInfoList.size == 1) {
            // for (workInfo in workInfos) {
            val workInfo = workInfoList[0]
            Log.d("workInfo.state=${workInfo.state}","id=${workInfo.id}")
            WorkManager.getInstance(applicationContext).beginUniqueWork("uploadAll",ExistingWorkPolicy.REPLACE, uploadImageTask).enqueue()

        } else {
            Log.d(TAG, "notFound")
            WorkManager.getInstance(applicationContext).beginUniqueWork("uploadAll",ExistingWorkPolicy.APPEND, uploadImageTask).enqueue()
        }
        //var taskOperation = WorkManager.getInstance(applicationContext).beginUniqueWork("uploadAll",ExistingWorkPolicy.APPEND, uploadImageTask).enqueue()
        //taskOperation.
                //index += 1;
        cursor.close()
        db.close()
        return Result.success()
    }
}