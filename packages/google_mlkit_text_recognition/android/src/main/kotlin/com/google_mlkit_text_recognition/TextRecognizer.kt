package com.google_mlkit_text_recognition

import android.content.Context
import android.graphics.Point
import android.graphics.Rect
import com.google.mlkit.vision.text.TextRecognition
import com.google.mlkit.vision.text.chinese.ChineseTextRecognizerOptions
import com.google.mlkit.vision.text.devanagari.DevanagariTextRecognizerOptions
import com.google.mlkit.vision.text.japanese.JapaneseTextRecognizerOptions
import com.google.mlkit.vision.text.korean.KoreanTextRecognizerOptions
import com.google.mlkit.vision.text.latin.TextRecognizerOptions
import com.google_mlkit_commons.InputImageConverter
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class TextRecognizer(
    private val context: Context,
) : MethodChannel.MethodCallHandler {
    private val instances = mutableMapOf<String, com.google.mlkit.vision.text.TextRecognizer>()

    companion object {
        private const val START = "vision#startTextRecognizer"
        private const val CLOSE = "vision#closeTextRecognizer"
    }

    override fun onMethodCall(
        call: MethodCall,
        result: MethodChannel.Result,
    ) {
        when (call.method) {
            START -> {
                handleDetection(call, result)
            }

            CLOSE -> {
                closeDetector(call)
                result.success(null)
            }

            else -> {
                result.notImplemented()
            }
        }
    }

    private fun initialize(call: MethodCall): com.google.mlkit.vision.text.TextRecognizer? =
        when (call.argument<Int>("script")) {
            0 -> TextRecognition.getClient(TextRecognizerOptions.DEFAULT_OPTIONS)
            1 -> TextRecognition.getClient(ChineseTextRecognizerOptions.Builder().build())
            2 -> TextRecognition.getClient(DevanagariTextRecognizerOptions.Builder().build())
            3 -> TextRecognition.getClient(JapaneseTextRecognizerOptions.Builder().build())
            4 -> TextRecognition.getClient(KoreanTextRecognizerOptions.Builder().build())
            else -> null
        }

    private fun handleDetection(
        call: MethodCall,
        result: MethodChannel.Result,
    ) {
        val imageData = call.argument<Map<String, Any>>("imageData") ?: return
        val inputImage = InputImageConverter.getInputImageFromData(imageData, context, result) ?: return

        val id = call.argument<String>("id") ?: return
        val textRecognizer =
            instances.getOrPut(id) {
                initialize(call) ?: run {
                    result.error("TextRecognizerError", "TextRecognizer is not initialized", null)
                    return
                }
            }

        textRecognizer
            .process(inputImage)
            .addOnSuccessListener { text ->
                val textResult =
                    mutableMapOf<String, Any>(
                        "text" to text.text,
                        "blocks" to
                            text.textBlocks.map { block ->
                                mutableMapOf<String, Any?>().apply {
                                    addData(this, block.text, block.boundingBox, block.cornerPoints, block.recognizedLanguage, null, null)
                                    put(
                                        "lines",
                                        block.lines.map { line ->
                                            mutableMapOf<String, Any?>().apply {
                                                addData(
                                                    this,
                                                    line.text,
                                                    line.boundingBox,
                                                    line.cornerPoints,
                                                    line.recognizedLanguage,
                                                    line.confidence,
                                                    line.angle,
                                                )
                                                put(
                                                    "elements",
                                                    line.elements.map { element ->
                                                        mutableMapOf<String, Any?>().apply {
                                                            addData(
                                                                this,
                                                                element.text,
                                                                element.boundingBox,
                                                                element.cornerPoints,
                                                                element.recognizedLanguage,
                                                                element.confidence,
                                                                element.angle,
                                                            )
                                                            put(
                                                                "symbols",
                                                                element.symbols.map { symbol ->
                                                                    mutableMapOf<String, Any?>().apply {
                                                                        addData(
                                                                            this,
                                                                            symbol.text,
                                                                            symbol.boundingBox,
                                                                            symbol.cornerPoints,
                                                                            symbol.recognizedLanguage,
                                                                            symbol.confidence,
                                                                            symbol.angle,
                                                                        )
                                                                    }
                                                                },
                                                            )
                                                        }
                                                    },
                                                )
                                            }
                                        },
                                    )
                                }
                            },
                    )
                result.success(textResult)
            }.addOnFailureListener { e ->
                result.error("TextRecognizerError", e.toString(), null)
            }
    }

    private fun addData(
        addTo: MutableMap<String, Any?>,
        text: String,
        rect: Rect?,
        cornerPoints: Array<Point>?,
        recognizedLanguage: String,
        confidence: Float?,
        angle: Float?,
    ) {
        addTo["text"] = text
        addTo["rect"] = rect?.let { getBoundingPoints(it) }
        addTo["points"] = cornerPoints?.map { mapOf("x" to it.x, "y" to it.y) } ?: emptyList<Map<String, Int>>()
        addTo["recognizedLanguages"] = listOf(recognizedLanguage)
        addTo["confidence"] = confidence
        addTo["angle"] = angle
    }

    private fun getBoundingPoints(rect: Rect) =
        mapOf(
            "left" to rect.left,
            "right" to rect.right,
            "top" to rect.top,
            "bottom" to rect.bottom,
        )

    private fun closeDetector(call: MethodCall) {
        val id = call.argument<String>("id") ?: return
        instances.remove(id)?.close()
    }
}
