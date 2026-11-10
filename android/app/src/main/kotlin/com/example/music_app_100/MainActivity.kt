package com.example.music_app_100

import android.content.Intent
import com.ryanheise.audioservice.AudioServiceActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : AudioServiceActivity() {
    private val SHARE_CHANNEL = "com.example.music_app_100/share"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SHARE_CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "shareTrack") {
                val title = call.argument<String>("title") ?: ""
                val artist = call.argument<String>("artist") ?: ""
                val album = call.argument<String>("album") ?: ""

                try {
                    val shareIntent = Intent(Intent.ACTION_SEND).apply {
                        type = "text/plain"
                        val shareText = buildString {
                            append("🎵 أستمع الآن إلى: ")
                            append(title)
                            if (artist.isNotBlank() && artist != "فنان غير معروف" && artist != "Unknown Artist") {
                                append(" - ")
                                append(artist)
                            }
                            if (album.isNotBlank() && album != "Unknown Album") {
                                append(" ($album)")
                            }
                            append("\nعبر تطبيق Music Player")
                        }
                        putExtra(Intent.EXTRA_SUBJECT, title)
                        putExtra(Intent.EXTRA_TEXT, shareText)
                    }

                    val chooser = Intent.createChooser(shareIntent, "مشاركة المقطع الصوتي")
                    chooser.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    startActivity(chooser)
                    result.success(true)
                } catch (e: Exception) {
                    result.error("SHARE_ERROR", e.localizedMessage, null)
                }
            } else {
                result.notImplemented()
            }
        }
    }
}
