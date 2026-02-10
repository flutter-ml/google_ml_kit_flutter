package com.google_mlkit_commons

import com.google.mlkit.common.model.DownloadConditions
import com.google.mlkit.common.model.RemoteModel
import com.google.mlkit.common.model.RemoteModelManager

open class GenericModelManager: ModelManagerApi {

    val remoteModelManager: RemoteModelManager = RemoteModelManager.getInstance()

    override fun isModelDownloaded(
        model: String,
        callback: (Result<Boolean>) -> Unit
    ) {
        try {
            val remoteModel = createRemoteModel(model)

            remoteModelManager.isModelDownloaded(remoteModel)
                .addOnSuccessListener { isDownloaded ->
                    callback(Result.success(isDownloaded))
                }
                .addOnFailureListener { exception ->
                    callback(Result.failure(exception))
                }
        } catch(e: Exception) {
            callback(Result.failure(e))
        }
    }

    override fun downloadModel(
        request: ModelManagementRequest,
        callback: (Result<ModelManagementResponse>) -> Unit
    ) {
        val remoteModel = createRemoteModel(request.model)

        // First check if the model is already downloaded
        remoteModelManager.isModelDownloaded(remoteModel)
            .addOnSuccessListener {  isDownloaded ->
                if (isDownloaded) {
                    callback(Result.success(
                        ModelManagementResponse(success = true, message = null)
                    ))
                    return@addOnSuccessListener
                }

                // Download the model
                val downloadConditions = if (request.isWifiRequired ?: false) {
                    DownloadConditions.Builder().requireWifi().build()
                } else {
                    DownloadConditions.Builder().build()
                }

                remoteModelManager.download(remoteModel, downloadConditions)
                    .addOnSuccessListener {
                        callback(Result.success(
                            ModelManagementResponse(success =  true, message = null)
                        ))
                    }
                    .addOnFailureListener { exception ->
                        callback(Result.success(
                            ModelManagementResponse(success =  false, message = exception.message)
                        ))
                    }
            }
            .addOnFailureListener { exception ->
                callback(Result.success(
                    ModelManagementResponse(success =  false, message = exception.message)
                ))
            }
    }

    override fun deleteModel(
        model: String,
        callback: (Result<ModelManagementResponse>) -> Unit
    ) {
        val remoteModel = createRemoteModel(model)

        // First check if the model exists
        remoteModelManager.isModelDownloaded(remoteModel)
            .addOnSuccessListener {  isDownloaded ->
                if (!isDownloaded) {
                    callback(Result.success(ModelManagementResponse(success =  true, message = null)))
                    return@addOnSuccessListener
                }

                // Delete the model
                remoteModelManager.deleteDownloadedModel(remoteModel)
                    .addOnSuccessListener {
                        callback(Result.success(
                            ModelManagementResponse(success = true, message = null)
                        ))
                    }
                    .addOnFailureListener { exception ->
                        callback(Result.success(
                            ModelManagementResponse(success = false, message =  exception.message)
                        ))
                    }
            }
            .addOnFailureListener {  exception ->
                callback(Result.success(
                    ModelManagementResponse(success = false, message = exception.message)
                ))
            }
    }

    protected open fun createRemoteModel(modelName: String) : RemoteModel {
        throw NotImplementedError("Subclasses must implement createRemoteModel")
    }
}