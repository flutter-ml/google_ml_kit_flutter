package com.google_mlkit_commons

import com.google.mlkit.common.model.DownloadConditions
import com.google.mlkit.common.model.RemoteModel
import com.google.mlkit.common.model.RemoteModelManager
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.lang.reflect.Method

class GenericModelManager {
    interface CheckModelIsDownloadedCallback {
        fun onCheckResult(isDownloaded: Boolean?)

        fun onError(e: Exception)
    }

    val remoteModelManager: RemoteModelManager = RemoteModelManager.getInstance()

    companion object {
        private const val DOWNLOAD = "download"
        private const val DELETE = "delete"
        private const val CHECK = "check"
    }

    fun manageModel(
        model: RemoteModel,
        call: MethodCall,
        result: MethodChannel.Result,
    ) {
        val task: String? = call.argument("task")

        if (task == null) {
            result.notImplemented()
            return
        }

        when (task) {
            DOWNLOAD -> {
                val isWifiReqRequired: Boolean = call.argument("wifi") ?: false
                val downloadConditions =
                    if (isWifiReqRequired) {
                        DownloadConditions.Builder().requireWifi().build()
                    } else {
                        DownloadConditions.Builder().build()
                    }
                downloadModel(model, downloadConditions, result)
            }

            DELETE -> {
                deleteModel(model, result)
            }

            CHECK -> {
                isModelDownloaded(
                    model,
                    object : CheckModelIsDownloadedCallback {
                        override fun onCheckResult(isDownloaded: Boolean?) {
                            result.success(isDownloaded)
                        }

                        override fun onError(e: Exception) {
                            result.error("error", e.toString(), null)
                        }
                    },
                )
            }

            else -> {
                result.notImplemented()
            }
        }
    }

    fun downloadModel(
        remoteModel: RemoteModel,
        downloadConditions: DownloadConditions,
        result: MethodChannel.Result,
    ) {
        isModelDownloaded(
            remoteModel,
            object : CheckModelIsDownloadedCallback {
                override fun onCheckResult(isDownloaded: Boolean?) {
                    if (isDownloaded == true) {
                        result.success("success")
                        return
                    }

                    remoteModelManager
                        .download(remoteModel, downloadConditions)
                        .addOnSuccessListener { result.success("success") }
                        .addOnFailureListener { exception -> result.error("error", exception.toString(), null) }
                }

                override fun onError(e: Exception) {
                    result.error("error", e.toString(), null)
                }
            },
        )
    }

    fun isModelDownloaded(
        model: RemoteModel,
        callback: CheckModelIsDownloadedCallback,
    ) {
        try {
            remoteModelManager
                .isModelDownloaded(model)
                .addOnFailureListener { exception -> callback.onError(exception) }
                .addOnSuccessListener { isModelDownloaded -> callback.onCheckResult(isModelDownloaded) }
        } catch (e: Exception) {
            callback.onError(e)
        }
    }

    fun deleteModel(
        remoteModel: RemoteModel,
        result: MethodChannel.Result,
    ) {
        isModelDownloaded(
            remoteModel,
            object : CheckModelIsDownloadedCallback {
                override fun onCheckResult(isDownloaded: Boolean?) {
                    if (isDownloaded != true) {
                        result.success("success")
                        return
                    }
                    remoteModelManager
                        .deleteDownloadedModel(remoteModel)
                        .addOnSuccessListener { result.success("success") }
                        .addOnFailureListener { exception -> result.error("error", exception.toString(), null) }
                }

                override fun onError(e: Exception) {
                    result.error("error", e.toString(), null)
                }
            },
        )
    }
}
