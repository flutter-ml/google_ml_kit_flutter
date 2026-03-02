package com.google_mlkit_commons

import android.content.Context
import android.graphics.ImageFormat
import android.net.Uri
import android.util.Log
import com.google.mlkit.vision.common.InputImage
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.IOException
import java.nio.IntBuffer

object InputImageConverter {
    // Returns an [InputImage] from the image data received
    @JvmStatic
    fun getInputImageFromData(
        imageData: Map<String, Any>,
        context: Context,
        result: MethodChannel.Result,
    ): InputImage? {
        // Differentiates whether the image data is a path for an image file,
        // Contains image data in the form of bytes, or a bitmap
        val model = imageData["type"] as? String

        return when (model) {
            "bitmap" -> {
                handleBitmapImage(imageData, result)
            }

            "file" -> {
                handleFileImage(imageData, context, result)
            }

            "bytes" -> {
                handleBytesImage(imageData, result)
            }

            else -> {
                result.error("InputImageConverterError", "Invalid Input Image", null)
                null
            }
        }
    }

    private fun handleFileImage(
        imageData: Map<String, Any>,
        context: Context,
        result: MethodChannel.Result,
    ): InputImage? =
        try {
            val path = imageData["path"] as? String
            InputImage.fromFilePath(context, Uri.fromFile(File(path)))
        } catch (e: IOException) {
            Log.e("ImageError", "Getting Image failed")
            Log.e("ImageError", e.toString())
            result.error("InputImageConverterError", e.toString(), e)
            null
        }

    private fun handleBitmapImage(
        imageData: Map<String, Any>,
        result: MethodChannel.Result,
    ): InputImage? {
        return try {
            val bitmapData = imageData["bitmapData"] as? ByteArray
            if (bitmapData == null) {
                result.error("InputImageConverterError", "Bitmap data is null", null)
                return null
            }

            // Extract the rotation
            val rotation = imageData["rotation"] as? Int ?: 0

            // Try to create a bitmap from raw RGBA data first
            val inputImage =
                try {
                    createBitmapFromRawData(imageData, bitmapData, rotation)
                } catch (e: Exception) {
                    Log.e("ImageError", "Error creating bitmap from raw data", e)
                    null
                }

            // Fallback: try to decode as standard image format (JPEG, PNG)
            inputImage ?: run {
                try {
                    val bitmap =
                        android.graphics.BitmapFactory.decodeByteArray(
                            bitmapData,
                            0,
                            bitmapData.size,
                        )
                    if (bitmap == null) {
                        result.error(
                            "InputImageConverterError",
                            "Failed to decode bitmap from the provided data",
                            null,
                        )
                        return null
                    }
                    InputImage.fromBitmap(bitmap, rotation)
                } catch (e: Exception) {
                    Log.e("ImageError", "Getting Bitmap failed", e)
                    result.error("InputImageConverterError", e.toString(), e)
                    null
                }
            }
        } catch (e: Exception) {
            Log.e("ImageError", "Getting Bitmap failed")
            Log.e("ImageError", e.toString())
            result.error("InputImageConverterError", e.toString(), e)
            null
        }
    }

    private fun createBitmapFromRawData(
        imageData: Map<String, Any>,
        bitmapData: ByteArray,
        rotation: Int,
    ): InputImage? {
        val metadataMap = imageData["metadata"] as? Map<*, *> ?: return null

        val width = (metadataMap["width"]?.toString()?.toDouble()?.toInt()) ?: return null
        val height = (metadataMap["height"]?.toString()?.toDouble()?.toInt()) ?: return null

        // Create a bitmap from the Flutter UI raw RGBA bytes
        val bitmap = android.graphics.Bitmap.createBitmap(width, height, android.graphics.Bitmap.Config.ARGB_8888)
        val intBuffer = IntBuffer.allocate(bitmapData.size / 4)

        // Convert RGBA bytes to int pixels
        for (i in bitmapData.indices step 4) {
            val r = bitmapData[i].toInt() and 0xFF
            val g = bitmapData[i + 1].toInt() and 0xFF
            val b = bitmapData[i + 2].toInt() and 0xFF
            val a = bitmapData[i + 3].toInt() and 0xFF
            intBuffer.put((a shl 24) or (r shl 16) or (g shl 8) or b)
        }
        intBuffer.rewind()

        bitmap.copyPixelsFromBuffer(intBuffer)
        return InputImage.fromBitmap(bitmap, rotation)
    }

    private fun handleBytesImage(
        imageData: Map<String, Any>,
        result: MethodChannel.Result,
    ): InputImage? =
        try {
            val metaData = imageData["metadata"] as? Map<*, *> ?: throw IllegalArgumentException("Metadata is null")

            val data = imageData["bytes"] as? ByteArray ?: throw IllegalArgumentException("Bytes data is null")

            val imageFormat = metaData["image_format"]?.toString()?.toInt() ?: throw IllegalArgumentException("Image format is null")

            val rotationDegrees = metaData["rotation"]?.toString()?.toInt() ?: throw IllegalArgumentException("Rotation is null")

            val width = metaData["width"]?.toString()?.toDouble()?.toInt() ?: throw IllegalArgumentException("Width is null")

            val height = metaData["height"]?.toString()?.toDouble()?.toInt() ?: throw IllegalArgumentException("Height is null")

            when (imageFormat) {
                ImageFormat.NV21, ImageFormat.YV12 -> {
                    InputImage.fromByteArray(data, width, height, rotationDegrees, imageFormat)
                }

                ImageFormat.YUV_420_888 -> {
                    // Create an InputImage directly from a YUV_420_888 byte array using the reported image format.
                    InputImage.fromByteArray(
                        data,
                        width,
                        height,
                        rotationDegrees,
                        imageFormat,
                    )
                }

                else -> {
                    result.error(
                        "InputImageConverterError",
                        "ImageFormat $imageFormat is not supported. Supported formats are: " +
                            "NV21 (${ImageFormat.NV21}), " +
                            "YV12 (${ImageFormat.YV12}), " +
                            "YUV_420_888 (${ImageFormat.YUV_420_888}).",
                        null,
                    )
                    null
                }
            }
        } catch (e: Exception) {
            Log.e("ImageError", "Getting Image failed")
            Log.e("ImageError", e.toString())
            result.error("InputImageConverterError", e.toString(), e)
            null
        }
}
