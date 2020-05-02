package com.alexrhino.flutter_app

import android.Manifest
import android.app.Activity
import android.app.job.JobInfo
import android.app.job.JobScheduler
import android.content.ComponentName
import android.content.ContentResolver.QUERY_ARG_OFFSET
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.ImageDecoder
import android.net.Uri
import android.os.Bundle
import android.provider.DocumentsContract.EXTRA_INITIAL_URI
import android.provider.MediaStore
import android.util.Base64
import android.util.Log
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import androidx.documentfile.provider.DocumentFile
import com.squareup.moshi.JsonClass
import com.squareup.moshi.Moshi
import com.squareup.moshi.Moshi.*
import com.squareup.moshi.kotlin.reflect.KotlinJsonAdapterFactory

import io.flutter.app.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import java.io.*
import android.content.ContentUris
import android.graphics.ColorSpace
import android.util.Size
import androidx.work.Constraints
import androidx.work.OneTimeWorkRequestBuilder
import androidx.work.WorkManager
import androidx.work.workDataOf
import java.net.URL
//import kotlinx.serialization.*
//import kotlinx.serialization.json.*

//import io.flutter.plugins.sharedpreferences
//import sun.text.normalizer.UTF16.append
const val MY_BACKGROUND_JOB = 0

fun scheduleJob(context: Context) {
    Log.i("Schedule job","Start schedule")
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
    Log.i("Schedule job","end schedule")
}

@JsonClass(generateAdapter = true)
data class LocalImageInfo(val imageCount:Int, val localImages:Map<String,ByteArray>)

@JsonClass(generateAdapter = true)
data class LocalImageDetail(val imageUri:String, val imageData:ByteArray)

class MainActivity : FlutterActivity() {
    //var sharedText = "Home1"
    //const val MY_BACKGROUND_JOB = 0
    var myUri = MediaStore.Images.Media.EXTERNAL_CONTENT_URI
    var moshi =  Builder().add(KotlinJsonAdapterFactory()).build()
    var jsonAdapter = moshi.adapter(LocalImageInfo::class.java)
    private lateinit var _myresult: MethodChannel.Result
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        GeneratedPluginRegistrant.registerWith(this)
        if (ContextCompat.checkSelfPermission(this,
                        Manifest.permission.READ_EXTERNAL_STORAGE)
                != PackageManager.PERMISSION_GRANTED) {

            // Permission is not granted
            // Should we show an explanation?
            if (ActivityCompat.shouldShowRequestPermissionRationale(this,
                            Manifest.permission.READ_EXTERNAL_STORAGE)) {
                // Show an explanation to the user *asynchronously* -- don't block
                // this thread waiting for the user's response! After the user
                // sees the explanation, try again to request the permission.
            } else {
                // No explanation needed, we can request the permission.
                ActivityCompat.requestPermissions(this,
                        arrayOf(Manifest.permission.READ_EXTERNAL_STORAGE),
                        1)

                // MY_PERMISSIONS_REQUEST_READ_CONTACTS is an
                // app-defined int constant. The callback method gets the
                // result of the request.
            }
        } else {
            // Permission has already been granted
        }

/*    var mContentObserver = object : ContentObserver(Handler()) {
      override fun onChange(selfChange: Boolean, uri: Uri) {
        Log.d("mingzhe call",uri.toString())
      }
    }*/
        //MyService.scheduleJob(this)
        //var myresult = MethodChannel.Result()
        MethodChannel(flutterView, "app.channel.shared.data").setMethodCallHandler { call, result ->
            when (call.method) {
                "getSharedText" -> result.success("123")
                "getImagesCount" -> {
                    var start = call.argument<Int>("start")
                    var count = call.argument<Int>("count")
                    Log.d("get local image from ",start.toString())
                    Log.d("get local image limit  ",count.toString())
                    if (start == null){
                        start = 0
                    }
                    if (count == null){
                        count = 15
                    }
                    var imagesInfo = getImageCount(start,count)

                    result.success(imagesInfo)
                }
                "getImagesList" -> {
                    var imagesInfo = getImageList()

                    result.success(imagesInfo)
                }
                "getImageDetail" -> {
                    var imageUri = call.argument<String>("uri")
                    if(imageUri!=null) {
                        var imagesInfo = getImageDetail(imageUri)
                        result.success(imagesInfo)
                    }
                    else{
                        result.error("Image Uri Error","Image Uri is not correct","Error")
                    }
                }
                "uploadImage" -> {
                    var imageUri = call.argument<String>("uri")
                    if(imageUri!=null) {
                            var imageID = imageUri.split("/").last()
                            val constraints = Constraints.Builder()
                                    .build()
                            val imageData = workDataOf(Pair("uriList", imageID.toString()))
                            val cacheCleanupTask =
                                    OneTimeWorkRequestBuilder<ProgressWorker>()
                                            .setConstraints(constraints)
                                            .setInputData(imageData)
                                            .addTag("upload")
                                            .build()
                            //WorkManager.enqueue(cacheCleanupTask);
                            WorkManager.getInstance(this).enqueue(cacheCleanupTask)
                        result.success("Job added")
                    }
                    else{
                        result.error("Image Uri Error","Image Uri is not correct","Error")
                    }
                }
                "addDirectory" -> {
                    //var imagesCount = getImageCount()
                    //result.success(imagesCount)
                    //result.success(listOf("content://com.android.providers.downloads.documents/tree/downloads","content://com.android.externalstorage.documents/tree/07F6-1D1D%3ADCIM"))
                }
                "uploadLocalAll" -> {
                    val constraints = Constraints.Builder()
                            .build()
                    val uploadAllTask =
                            OneTimeWorkRequestBuilder<UploadAllProgressWorker>()
                                    .setConstraints(constraints)
                                    .addTag("uploadAll")
                                    .build()
                    //WorkManager.enqueue(cacheCleanupTask);
                    Log.d("UploadAll job ","Added")
                    WorkManager.getInstance(this).enqueue(uploadAllTask)
                    result.success("Job added")
                    //var imagesCount = getImageCount()
                    //result.success(imagesCount)
                    //result.success(listOf("content://com.android.providers.downloads.documents/tree/downloads","content://com.android.externalstorage.documents/tree/07F6-1D1D%3ADCIM"))
                }
                "startService" -> result.success("Started")
                else -> result.success("else")
            }
        }
        //openFile()
        scheduleJob(this);

    }
    fun getImageDetail(imageUri:String): String {
        var imageSource = ImageDecoder.createSource(applicationContext.contentResolver, Uri.parse(imageUri))
        //var myInputStream = applicationContext.contentResolver.openInputStream(Uri.parse(imageUri))
        var myBitmap = ImageDecoder.decodeBitmap(imageSource)
        myBitmap.setColorSpace(ColorSpace.get(ColorSpace.Named.LINEAR_EXTENDED_SRGB))
        var myOutputStream = ByteArrayOutputStream()
        myBitmap.compress(Bitmap.CompressFormat.PNG, 100, myOutputStream)
        var myByteArray = myOutputStream.toByteArray()
        var moshi =  Builder().add(KotlinJsonAdapterFactory()).build()
        var jsonAdapter = moshi.adapter(LocalImageDetail::class.java)
        
        var localImageDetail = LocalImageDetail(imageUri = imageUri,imageData = myByteArray)
        var localJson = jsonAdapter.toJson(localImageDetail)
        return localJson
    }
    fun getImageCount(start: Int,count: Int): String {

        Log.d("mingzhe call", "getImageCount")

        val projection = arrayOf(
                MediaStore.Images.Media._ID
        )
        val cursor = getContentResolver().query(MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
                null, null, null, null)
        cursor!!.extras.putInt(QUERY_ARG_OFFSET,0)
        Log.d("mingzhe call exter cursor", MediaStore.Images.Media.EXTERNAL_CONTENT_URI.toString())
        Log.d("mingzhe call exter cursor", cursor.toString())
        Log.d("mingzhe call", "count" + cursor!!.count.toString())
        var localImages = mutableMapOf<String,ByteArray>()
        var countExternal = cursor!!.count
        cursor.moveToFirst()

        cursor.move(start)

        var index = 0;
        do {
            var imageIndex = cursor.getColumnIndex(MediaStore.Images.Media._ID)
            if(imageIndex !=null) {
                Log.d("Found image index", imageIndex.toString())
                var imageID = cursor.getString(imageIndex)
                Log.d("Found image", imageID.toString())
                var imageUri = ContentUris.withAppendedId(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, imageID.toLong())
                var myThumbNail = contentResolver.loadThumbnail(imageUri, Size(128, 128), null)
                var output = ByteArrayOutputStream()
                myThumbNail.compress(Bitmap.CompressFormat.PNG, 100, output)
                localImages[imageUri.toString()] = output.toByteArray()
                index += 1;
            }
        } while(cursor.moveToNext() && index <count)
        cursor.close()
        var localImageInfo = LocalImageInfo(countExternal,localImages = localImages)

        //var jsonAdapter = moshi.adapter(LocalImageInfo::class.java)
        var localJson = jsonAdapter.toJson(localImageInfo)

        //Log.d("mingzhe call", "count" + localJson.toString())
        return localJson
        //result.success("Count"+count.toString())
    }

    fun getImageList(): String {

        Log.d("mingzhe call", "getImageList")

        val projection = arrayOf(
                MediaStore.Images.Media._ID
        )
        val cursor = getContentResolver().query(MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
                null, null, null, null)
        cursor!!.extras.putInt(QUERY_ARG_OFFSET,0)
        Log.d("mingzhe call exter cursor", MediaStore.Images.Media.EXTERNAL_CONTENT_URI.toString())
        Log.d("mingzhe call exter cursor", cursor.toString())
        Log.d("mingzhe call", "count" + cursor!!.count.toString())
        var localImages = mutableMapOf<String,ByteArray>()
        var countExternal = cursor!!.count
        cursor.moveToFirst()
        var imageIndex = cursor.getColumnIndex(MediaStore.Images.Media._ID)
        Log.d("Found image index", imageIndex.toString())
        var imageID = cursor.getString(imageIndex)
        Log.d("Found image", imageID.toString())
        var imageUri = ContentUris.withAppendedId(MediaStore.Images.Media.EXTERNAL_CONTENT_URI,imageID.toLong())


/*        if (myUri != MediaStore.Images.Media.EXTERNAL_CONTENT_URI) {
            var imageCount = DocumentFile.fromTreeUri(this, myUri)!!.listFiles()
            Log.d("mingzhe call myuri cursor", imageCount.size.toString())
        }
        val cursor1 = getContentResolver().query(MediaStore.Images.Media.INTERNAL_CONTENT_URI,
                null, null, null, null)
        Log.d("mingzhe call inter cursor", MediaStore.Images.Media.INTERNAL_CONTENT_URI.toString())
        Log.d("mingzhe call inter cursor", cursor1.toString())
        val count = cursor1!!.count
        Log.d("mingzhe call", "count" + count.toString())
        //cursor.EXTRA_TOTAL_COUNT
        cursor1!!.close()*/
        var myThumbNail = contentResolver.loadThumbnail(imageUri, Size(128,128),null)
        var output = ByteArrayOutputStream()
        myThumbNail.compress(Bitmap.CompressFormat.PNG,100,output)
        localImages[imageUri.toString()] = output.toByteArray()
        cursor.close()
        var localImageInfo = LocalImageInfo(countExternal,localImages = localImages)
        //var moshi =  Builder().add(KotlinJsonAdapterFactory()).build()

        var localJson = jsonAdapter.toJson(localImageInfo)

        //Log.d("mingzhe call", "count" + localJson.toString())
        return localJson
        //result.success("Count"+count.toString())
    }
    fun openFile() {
        Log.d("mingzhe call", "Open directory to get permission")
        val intent = Intent(Intent.ACTION_OPEN_DOCUMENT_TREE).apply {
            intent.putExtra(EXTRA_INITIAL_URI, "content://media/external/images/media/")
            //addCategory(Intent.CATEGORY_OPENABLE)
            //type = "*/*"

            // Optionally, specify a URI for the file that should appear in the
            // system file picker when it loads.
        }

        startActivityForResult(intent, 2)
    }

    //https://developer.android.com/guide/topics/providers/document-provider
    //https://developer.android.com/training/data-storage/shared/documents-files
    override fun onActivityResult(
            requestCode: Int, resultCode: Int, resultData: Intent?) {
        Log.d("mingzhe call", "request " + requestCode.toString() + " resultCode " + requestCode.toString())
        if (requestCode == 2
                && resultCode == Activity.RESULT_OK) {
            Log.d("mingzhe call", "Open directory to get permission result")
            // The result data contains a URI for the document or directory that
            // the user selected.
            resultData?.data?.also { uri ->
                // Perform operations on the document using its URI.
                val contentResolver = applicationContext.contentResolver
                val takeFlags: Int = Intent.FLAG_GRANT_READ_URI_PERMISSION or
                        Intent.FLAG_GRANT_WRITE_URI_PERMISSION
// Check for the freshest data.
                contentResolver.takePersistableUriPermission(uri, takeFlags)
                myUri = uri
                Log.d("mingzhe call", uri.toString())
/*        val preferences = this.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        Log.d("mingzhe call",preferences.all.keys.toString())
        var directoryInSyncing = preferences.getString("flutter.directories",null)!!.substring("VGhpcyBpcyB0aGUgcHJlZml4IGZvciBhIGxpc3Qu".length)
        var  directoryInSyncingList = decodeList(directoryInSyncing)!!.toMutableList()
        //var directoryInSyncingList = decodeList(directoryInSyncing)
        //var mylist = directoryInSyncingList.toSet()
        Log.d("mingzhe call directory list string",directoryInSyncingList.toString())
        if (directoryInSyncingList.contains( uri.toString())){

        }else {
          directoryInSyncingList.add(uri.toString())
          Log.d("mingzhe call new directory list",directoryInSyncingList.toString())
          preferences.edit().putString("flutter.directories", "VGhpcyBpcyB0aGUgcHJlZml4IGZvciBhIGxpc3Qu" + encodeList(directoryInSyncingList.toList())).commit()
          Log.d("mingzhe call directory list string after",decodeList(preferences.getString("flutter.directories",null)!!.substring("VGhpcyBpcyB0aGUgcHJlZml4IGZvciBhIGxpc3Qu".length)).toString())
        }
        Log.d("mingzhe call",preferences.getLong("flutter.counter",0).toString())*/
            }
            //_myresult.success(listOf("content://com.android.providers.downloads.documents/tree/downloads","content://com.android.externalstorage.documents/tree/07F6-1D1D%3ADCIM"))
            _myresult.success(listOf(myUri.toString(), "123"))
        }
    }

    private fun encodeList(list: List<String?>): String? {
        var stream: ObjectOutputStream? = null
        return try {
            val byteStream = ByteArrayOutputStream()
            stream = ObjectOutputStream(byteStream)
            stream.writeObject(list)
            stream.flush()
            Base64.encodeToString(byteStream.toByteArray(), 0)
        } finally {
            if (stream != null) {
                stream.close()
            }
        }
    }

    private fun decodeList(encodedList: String): List<String?>? {
        var stream: ObjectInputStream? = null
        return try {
            stream = ObjectInputStream(ByteArrayInputStream(Base64.decode(encodedList, 0)))
            stream.readObject() as List<String?>
        } catch (e: ClassNotFoundException) {
            throw IOException(e)
        } finally {
            stream?.close()
        }
    }
}
