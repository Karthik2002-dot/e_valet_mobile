package com.niloufer.valet

import android.os.Bundle
import android.speech.tts.TextToSpeech
import android.util.Log
import androidx.annotation.NonNull
import com.google.firebase.messaging.RemoteMessage
import io.flutter.plugins.firebase.messaging.FlutterFirebaseMessagingService
import java.util.Locale
import java.util.UUID

/**
 * Custom FCM service that speaks the notification body aloud when the app is in
 * background or terminated. Extends Flutter's service so Dart background handler
 * and notification display still work; we only add TTS here.
 */
class ValetFirebaseMessagingService : FlutterFirebaseMessagingService() {

    override fun onMessageReceived(@NonNull remoteMessage: RemoteMessage) {
        // Speak notification body aloud (loud, hearable) when app is in background/terminated
        val body = remoteMessage.notification?.body
        val title = remoteMessage.notification?.title
        val textToSpeak = when {
            !body.isNullOrBlank() -> body
            !title.isNullOrBlank() -> title
            else -> null
        }
        if (!textToSpeak.isNullOrBlank()) {
            speakWithTts(textToSpeak)
        }
        super.onMessageReceived(remoteMessage)
    }

    private fun speakWithTts(text: String) {
        val utteranceId = "valet_tts_${UUID.randomUUID()}"
        var ttsRef: TextToSpeech? = null
        ttsRef = TextToSpeech(applicationContext) { status ->
            val tts = ttsRef ?: return@TextToSpeech
            if (status != TextToSpeech.SUCCESS) {
                Log.e(TAG, "TTS init failed: $status")
                tts.shutdown()
                return@TextToSpeech
            }
            if (tts.setLanguage(Locale.getDefault()) >= 0) {
                tts.setSpeechRate(0.45f)
                tts.setOnUtteranceProgressListener(object : android.speech.tts.UtteranceProgressListener() {
                    override fun onStart(utteranceId: String?) {}
                    override fun onDone(utteranceId: String?) {
                        tts.stop()
                        tts.shutdown()
                    }
                    override fun onError(utteranceId: String?) {
                        tts.shutdown()
                    }
                    override fun onError(utteranceId: String?, errorCode: Int) {
                        tts.shutdown()
                    }
                })
                val params = Bundle().apply { putString(TextToSpeech.Engine.KEY_PARAM_UTTERANCE_ID, utteranceId) }
                tts.speak(text, TextToSpeech.QUEUE_FLUSH, params, utteranceId)
                Log.d(TAG, "TTS speaking (background): $text")
            } else {
                Log.e(TAG, "TTS setLanguage failed")
                tts.shutdown()
            }
        }
    }

    companion object {
        private const val TAG = "ValetFCM"
    }
}
