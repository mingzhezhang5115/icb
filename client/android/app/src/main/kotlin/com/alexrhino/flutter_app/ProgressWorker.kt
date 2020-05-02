package com.alexrhino.flutter_app

//import androidx.work.Data

//import android.media.ExifInterface.TAG_PIXEL_X_DIMENSION
//import android.media.ExifInterface
//import androidx.exifinterface.media.ExifInterface.TAG_PIXEL_X_DIMENSION

import android.content.ContentUris
import android.content.ContentValues
import android.content.Context
import android.graphics.Bitmap
import android.graphics.ColorSpace
import android.graphics.ImageDecoder
import android.net.Uri
import android.provider.BaseColumns
import android.provider.MediaStore
import android.util.Log
import androidx.exifinterface.media.ExifInterface
import androidx.work.CoroutineWorker
import androidx.work.WorkerParameters
import androidx.work.workDataOf
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
import java.nio.MappedByteBuffer

//https://developer.android.com/topic/libraries/architecture/workmanager/how-to/intermediate-progress
class ProgressWorker(context: Context, parameters: WorkerParameters) :
        CoroutineWorker(context, parameters) {
    private val TAG = "ProgressWorker"

    //private val dbHelper = ICBDbHelper(applicationContext)
    companion object {
        const val Progress = "Progress"
        private const val delayDuration = 1L
        val mediaTypeJson = "application/json; charset=utf-8".toMediaType()
        //val dbHelper = ICBDbHelper(context = this.)
    }

    private val queue = Volley.newRequestQueue(this.applicationContext)
    private var uploadUrl = ""
    fun getUploadUrl(myByteArray: ByteArray, imageSha1: String, humanReadableName: String): okhttp3.Response {
        var client = OkHttpClient()
        //var jsonKey = "tag_name"
        var payload = JSONObject().put("image_sha1", imageSha1)
        payload.put("human_readable_name", humanReadableName)
        var requestBody = payload.toString().toRequestBody(mediaTypeJson)
        val request = okhttp3.Request.Builder()
                .url("http://10.42.0.238:5000/images")
                .put(requestBody)
                .build()
        var resp = client.newCall(request).execute()
        return resp
    }

    private fun putTag(imageUUID: String, imageTag: String): okhttp3.Response {


        var client = OkHttpClient()
        //var jsonKey = "tag_name"
        var payload = JSONObject().put("tag_name", imageTag)
        var requestBody = payload.toString().toRequestBody(mediaTypeJson)
        val request = okhttp3.Request.Builder()
                .url(HttpUrl.Builder()
                        .scheme("http")
                        .host("10.42.0.238")
                        .port(5000)
                        .addPathSegment("images")
                        .addPathSegment(imageUUID)
                        .addPathSegment("tags")
                        .addPathSegment(imageTag)
                        .build())
                .put(requestBody)
                .build()
        var resp = client.newCall(request).execute()
        return resp
    }

//    private fun upload_image(byteArray: ByteArray, uploadUrl: String) {
///*        var myUrl = URL(uploadUrl)
//        var connection: HttpURLConnection = myUrl.openConnection() as HttpURLConnection
//        connection.doOutput = true
//        connection.requestMethod = "PUT"
//        try {
//            val outputStream: DataOutputStream = DataOutputStream(connection.outputStream)
//            outputStream.write(byteArray)
//            outputStream.flush()
//        } catch (exception: Exception) {
//            Log.i(TAG, exception.toString())
//
//        }
//        //connection.getOutputStream(ByteArray)
//        //connection.getOutputStream().write(byteArray)
//        //connection.outputStream.write(byteArray)
//        //connection.outputStream.close()
//        //onnection.getOutputStream().close()
//        //outputStream.write(byteArray)
//        //outputStream.close()
//        //bos.write(byteArray)
//        //bos.close()
//        if (connection.responseCode != HttpURLConnection.HTTP_OK && connection.responseCode != HttpURLConnection.HTTP_CREATED) {
//            try {
//
//
//                val reader: BufferedReader = BufferedReader(InputStreamReader(connection.inputStream))
//                val output: String = reader.readLine()
//                Log.i(TAG, output)
//                //println("There was error while connecting the chat $output")
//                //System.exit(0)
//
//            } catch (exception: Exception) {
//                throw Exception("Exception while push the notification  $exception.message")
//            }
//        }*/
///*        connection.connect()
//        var resp = connection.getInputStream()
//        //val buf: ByteArrayOutputStream = ByteArrayOutputStream()
//        var result2 = resp.readBytes()
//        Log.i(TAG, result2.toString())*/
//        var stringRequest = object : StringRequest(Request.Method.PUT, uploadUrl,
//                Response.Listener<String> { response ->
//                    // Display the first 500 characters of the response string.
//                    Log.i(TAG, response)
//                },
//                Response.ErrorListener { error ->
//                    when (error::class.simpleName) {
//                        "NoConnectionError" -> {
//                            Log.i(TAG, error.toString())
//                        }
//                        else -> {
//                            Log.i(TAG, "Unexpected error occur: " + error.toString())
//                        }
//                    }
//                    Log.i(TAG, error.toString())
//                }) {
//            override fun getBody(): ByteArray {
//
//                //   TODO add Body, Header section works  //////////
//
//                return byteArray
//            }
//        }
//        this.queue.add(stringRequest)
//    }

    private fun uploadImage(byteArray: ByteArray, uploadUrl: String): okhttp3.Response {
        var client = OkHttpClient()
        //var jsonKey = "tag_name"
        var payload = byteArray
        var requestBody = byteArray.toRequestBody()
        val request = okhttp3.Request.Builder()
                .url(uploadUrl)
                .put(requestBody)
                .build()
        var resp = client.newCall(request).execute()
        return resp
    }

    override suspend fun doWork(): Result {
        //val firstUpdate = workDataOf(Progress to 0)
        //val lastUpdate = workDataOf(Progress to 100)
        val imageUriArrayString = getInputData().getString("uriList")
        Log.i(TAG, "Recieve request " + imageUriArrayString)
        if (imageUriArrayString!!.trim().length == 0) {
            return Result.success()
        }
        var imageUriList = imageUriArrayString!!.split(",")
        val dbHelper = ICBDbHelper(applicationContext)
        val dbReader = dbHelper.readableDatabase
        val dbWriter = dbHelper.writableDatabase
        val selection = "${ICBReaderContract.ICBEntry.COLUMN_NAME_URI} = ?"

        var tfliteOption = Interpreter.Options()
        var tfliteModel: MappedByteBuffer = FileUtil.loadMappedFile(this.applicationContext, "mobilenet_v1_1.0_224_quant.tflite")
        var labels = FileUtil.loadLabels(this.applicationContext, "labels_mobilenet_quant_v1_224.txt")
        var tflite = Interpreter(tfliteModel, tfliteOption)

        val imageTensorIndex = 0
        val imageShape = tflite.getInputTensor(imageTensorIndex).shape() // {1, height, width, 3}

        var imageSizeY = imageShape[1]
        var imageSizeX = imageShape[2]
        val imageDataType: DataType = tflite.getInputTensor(imageTensorIndex).dataType()
        val probabilityTensorIndex = 0
        val probabilityShape = tflite.getOutputTensor(probabilityTensorIndex).shape() // {1, NUM_CLASSES}

        val probabilityDataType: DataType = tflite.getOutputTensor(probabilityTensorIndex).dataType()

        // Creates the input tensor.
        // Creates the input tensor.
        var inputImageBuffer = TensorImage(imageDataType)
        //inputImageBuffer.

        // Creates the output tensor and its processor.
        // Creates the output tensor and its processor.
        var outputProbabilityBuffer = TensorBuffer.createFixedSize(probabilityShape, probabilityDataType)

        // Creates the post processor for the output probability.
        // Creates the post processor for the output probability.
        var probabilityProcessor = TensorProcessor.Builder().build()

        for (index in imageUriList!!.indices) {
            //print(index)
            var imageUriID = imageUriList[index]
            var imageUriInput = ContentUris.withAppendedId(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, imageUriID.toLong()).toString()
            Log.i(TAG, "Check and upload " + imageUriInput)
            val selectionArgs = arrayOf(imageUriInput)
            val readerCursor = dbReader.query(
                    ICBReaderContract.ICBEntry.TABLE_NAME,   // The table to query
                    null,             // The array of columns to return (pass null to get all)
                    selection,              // The columns for the WHERE clause
                    selectionArgs,          // The values for the WHERE clause
                    null,                   // don't group the rows
                    null,                   // don't filter by row groups
                    null               // The sort order
            )
            var uploaded = false
            with(readerCursor) {
                while (moveToNext()) {
                    val imageUriEntry = getString(getColumnIndexOrThrow(ICBReaderContract.ICBEntry.COLUMN_NAME_URI))
                    val imageUploadedEntry = getInt(getColumnIndexOrThrow(ICBReaderContract.ICBEntry.COLUMN_NAME_UPLOADED))
                    Log.i(TAG, "Image " + imageUriEntry + imageUploadedEntry.toString())
                    if (imageUploadedEntry == 1) {
                        Log.i(TAG, "Image " + imageUriEntry + imageUploadedEntry.toString() + "has been uploaded")
                        uploaded = true
                    }
                    //itemIds.add(itemId)
                }
            }
            readerCursor.close()
            //db.close()

            if (uploaded) {
                //dbReader.close()
                //dbHelper.close()
                //Log.i(TAG, "Image " + imageUriEntry + imageUploadedEntry.toString())
                continue
            }
            //cursor.close()


            var imageSource = ImageDecoder.createSource(applicationContext.contentResolver, Uri.parse(imageUriInput))

            var humanReadableName = "Unkown"
            val projection = arrayOf<String>(MediaStore.MediaColumns.DISPLAY_NAME, MediaStore.MediaColumns.BUCKET_DISPLAY_NAME, MediaStore.MediaColumns.TITLE)
            var cur = applicationContext.contentResolver.query(Uri.parse(imageUriInput), projection, null, null, null)
            if (cur != null) {
                try {
                    if (cur.moveToFirst()) {
                        Log.i(TAG, cur.getString(0) + cur.getString(1) + cur.getString(2))
                        humanReadableName = cur.getString(0)
                    }
                } finally {
                    cur.close()
                }
            }
//        cur!!.close()
            var exifTags = mutableListOf<String>();

            var myInputStream = applicationContext.contentResolver.openInputStream(Uri.parse(imageUriInput))
            if (myInputStream != null) {
                var myExif = ExifInterface(myInputStream)
                //Log.i(TAG, myExif.getAttribute(ExifInterface.TAG_PIXEL_X_DIMENSION).toString())
                var exifTag = myExif.getAttribute(ExifInterface.TAG_IMAGE_LENGTH);
                Log.i(TAG, exifTag.toString())
                if(exifTag !=null ){
                    exifTags.add("ExifHeight-" + exifTag.toString())
                }
                Log.i(TAG, myExif.getAttribute(ExifInterface.TAG_IMAGE_UNIQUE_ID).toString())
                Log.i(TAG, myExif.getAttribute(ExifInterface.TAG_IMAGE_WIDTH).toString())
                exifTag = myExif.getAttribute(ExifInterface.TAG_IMAGE_WIDTH)
                if(exifTag !=null ){
                    exifTags.add("ExifHWidth-" + exifTag.toString())
                }
                exifTag = myExif.getAttribute(ExifInterface.TAG_MAKE)
                if(exifTag !=null){
                    exifTags.add("ExifMake-" + exifTag.toString())
                }
                Log.i(TAG, myExif.getAttribute(ExifInterface.TAG_MAKE).toString())
                Log.i(TAG, myExif.getAttribute(ExifInterface.TAG_X_RESOLUTION).toString())
                Log.i(TAG, myExif.getAttribute(ExifInterface.TAG_Y_RESOLUTION).toString())
                Log.i(TAG, myExif.getAttribute(ExifInterface.TAG_COMPRESSION).toString())
                Log.i(TAG, myExif.getAttribute(ExifInterface.TAG_MODEL).toString())
                Log.i(TAG, myExif.getAttribute(ExifInterface.TAG_FLASH).toString())
                Log.i(TAG, myExif.getAttribute(ExifInterface.TAG_ORIENTATION).toString())
                Log.i(TAG, myExif.getAttribute(ExifInterface.TAG_DATETIME).toString())
                Log.i(TAG, myExif.getAttribute(ExifInterface.TAG_DATETIME_DIGITIZED).toString())
                //Log.i(TAG, myExif.getAttribute(ExifInterface.TAG_crea).toString())

                myInputStream.close()
            }
//
///*        ExifInterface::class.staticProperties.forEach(){ it ->
//
//            Log.i(TAG,"Properties" + it.toString())
//        }*/
//        //{ it.name == "TAG_PIXEL_X_DIMENSION" }
//        //Log.i(TAG, "Test123: + " + aBC.toString())
            var myBitmap = ImageDecoder.decodeBitmap(imageSource)
            myBitmap.setColorSpace(ColorSpace.get(ColorSpace.Named.LINEAR_EXTENDED_SRGB))
            var myOutputStream = ByteArrayOutputStream()
            myBitmap.compress(Bitmap.CompressFormat.PNG, 100, myOutputStream)
            var myByteArray = myOutputStream.toByteArray()
            myOutputStream.close()
            val md: MessageDigest = MessageDigest.getInstance("SHA-1")
            var mySha1 = md.digest(myByteArray).fold("", { str, it -> str + "%02x".format(it) })
            Log.i(TAG, "MySha1" + mySha1)
            Log.i("ProgressWorker", imageUriInput)
//        //setProgress(firstUpdate)
///*        FileOutputStream("mobilenet_v1_1.0_224_quant.tflite").use { out ->
//            context.assets.open(Database.ASSET).use {
//                it.copyTo(out)
//            }
//        }*/

//
            var aBitmap = myBitmap.copy(Bitmap.Config.ARGB_8888, true)
            inputImageBuffer.load(aBitmap)
            var cropSize = Math.min(aBitmap.getWidth(), aBitmap.getHeight())
            var imageProcessor = ImageProcessor.Builder().add(ResizeWithCropOrPadOp(cropSize, cropSize)).add(ResizeOp(imageSizeX, imageSizeY, ResizeOp.ResizeMethod.NEAREST_NEIGHBOR)).build()
            inputImageBuffer = imageProcessor.process(inputImageBuffer)

            tflite.run(inputImageBuffer.getBuffer(), outputProbabilityBuffer.getBuffer().rewind())
            var labeledProbability = TensorLabel(labels, probabilityProcessor.process(outputProbabilityBuffer))
                    .getMapWithFloatValue()
            var maxLabel = ""
            var maxValue = 0.0f
            for ((k, v) in labeledProbability) {
                //Log.i(TAG, k + ':' + v.toString())
                //Log.i(TAG, v.toString())
                if (v >= maxValue) {
                    maxValue = v
                    maxLabel = k
                }
            }
            Log.i(TAG, "Max Label: " + maxLabel + ",maxValue:" + maxValue.toString())
//
//
//        tflite.close()
            var uploadResponse = getUploadUrl(myByteArray, mySha1, humanReadableName)
            //Log.i(TAG,"Respond body " + uploadResponse.body!!.string())
            var uploadRespJson = JSONObject(uploadResponse.body!!.string())
            uploadResponse.close()
            if (uploadRespJson.has("upload_url")) {
                var uploadUrl = uploadRespJson.get("upload_url")
                Log.i(TAG, uploadUrl.toString())
                var imageUUID = uploadRespJson.get("image_uuid")
                Log.i(TAG, imageUUID.toString())
                var putTagResp = putTag(imageUUID.toString(), maxLabel.toString())
                Log.i(TAG, "Respond body " + putTagResp.body!!.string())
                putTagResp.close()
                if(exifTags.size > 0){
                    for (exifTag in exifTags){
                        putTagResp = putTag(imageUUID.toString(),exifTag);
                        putTagResp.close();
                    }
                }
                var uploadResp = uploadImage(myByteArray, uploadUrl.toString())
                uploadResp.close()

            }else{
                Log.i(TAG, "Fail to get upload url from server, either it has been uploaded or there is an issue ")
            }
            val values = ContentValues().apply {
                put(ICBReaderContract.ICBEntry.COLUMN_NAME_URI, imageUriInput)
                put(ICBReaderContract.ICBEntry.COLUMN_NAME_UPLOADED, 1)
            }
            val count = dbWriter.insert(
                    ICBReaderContract.ICBEntry.TABLE_NAME,
                    null,
                    values)
        }
        tflite.close()
        dbReader.close()
        dbWriter.close()
        dbHelper.close()
        return Result.success()
    }
}

