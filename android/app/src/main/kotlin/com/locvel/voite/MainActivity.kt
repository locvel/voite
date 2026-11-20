package com.locvel.voite

import android.content.Context
import android.content.ClipData
import android.content.Intent
import android.media.AudioManager
import android.media.AudioRecordingConfiguration
import android.media.MediaRecorder
import android.net.Uri
import android.os.Handler
import android.os.Looper
import android.os.StatFs
import android.provider.Settings
import androidx.core.content.FileProvider
import java.io.File
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var recordingCallback: AudioManager.AudioRecordingCallback? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.locvel.voite/app_settings",
        ).setMethodCallHandler { call, result ->
            if (call.method != "openAppSettings") {
                result.notImplemented()
                return@setMethodCallHandler
            }
            try {
                startActivity(
                    Intent(
                        Settings.ACTION_APPLICATION_DETAILS_SETTINGS,
                        Uri.parse("package:$packageName"),
                    ),
                )
                result.success(null)
            } catch (_: Exception) {
                result.error("settings_unavailable", "App settings could not be opened.", null)
            }
        }

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.locvel.voite/storage",
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "freeBytes" -> result.success(StatFs(filesDir.absolutePath).availableBytes)
                // Android Auto Backup is disabled at the application level;
                // user files live in the app's private internal storage.
                "protectAppData" -> result.success(null)
                else -> result.notImplemented()
            }
        }

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.locvel.voite/share",
        ).setMethodCallHandler { call, result ->
            try {
                when (call.method) {
                    "shareText" -> {
                        val title = call.argument<String>("title") ?: "Share transcript"
                        val text = call.argument<String>("text")
                        if (text.isNullOrBlank()) {
                            result.error("empty_text", "There is no transcript text to share.", null)
                            return@setMethodCallHandler
                        }
                        val intent = Intent(Intent.ACTION_SEND).apply {
                            type = "text/plain"
                            putExtra(Intent.EXTRA_SUBJECT, title)
                            putExtra(Intent.EXTRA_TEXT, text)
                        }
                        startActivity(Intent.createChooser(intent, title))
                        result.success(null)
                    }
                    "shareAudio" -> {
                        val title = call.argument<String>("title") ?: "Voice recording"
                        val path = call.argument<String>("path")
                        if (path.isNullOrBlank()) {
                            result.error("invalid_path", "A recording path is required.", null)
                            return@setMethodCallHandler
                        }
                        val file = File(path).canonicalFile
                        val allowedRoot = File(applicationInfo.dataDir, "app_flutter/recordings").canonicalPath + File.separator
                        if (!file.isFile || !file.canonicalPath.startsWith(allowedRoot)) {
                            result.error("invalid_path", "Only a saved recording can be shared.", null)
                            return@setMethodCallHandler
                        }
                        val uri = FileProvider.getUriForFile(
                            this,
                            "${applicationContext.packageName}.fileprovider",
                            file,
                        )
                        val intent = Intent(Intent.ACTION_SEND).apply {
                            type = "audio/wav"
                            putExtra(Intent.EXTRA_STREAM, uri)
                            putExtra(Intent.EXTRA_SUBJECT, title)
                            clipData = ClipData.newUri(contentResolver, title, uri)
                            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                        }
                        startActivity(Intent.createChooser(intent, "Share audio"))
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            } catch (error: Exception) {
                result.error("share_failed", error.localizedMessage, null)
            }
        }

        EventChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.locvel.voite/mic_mute",
        ).setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                val sink = events ?: return
                val audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager
                val callback = object : AudioManager.AudioRecordingCallback() {
                    override fun onRecordingConfigChanged(
                        configs: MutableList<AudioRecordingConfiguration>?,
                    ) {
                        val muted = configs.orEmpty()
                            .filter { it.clientAudioSource == MediaRecorder.AudioSource.VOICE_RECOGNITION }
                            .any { it.isClientSilenced }
                        sink.success(muted)
                    }
                }
                recordingCallback = callback
                audioManager.registerAudioRecordingCallback(
                    callback,
                    Handler(Looper.getMainLooper()),
                )
                val active = audioManager.activeRecordingConfigurations
                sink.success(
                    active.filter {
                        it.clientAudioSource == MediaRecorder.AudioSource.VOICE_RECOGNITION
                    }.any { it.isClientSilenced },
                )
            }

            override fun onCancel(arguments: Any?) {
                val audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager
                recordingCallback?.let(audioManager::unregisterAudioRecordingCallback)
                recordingCallback = null
            }
        })
    }
}
