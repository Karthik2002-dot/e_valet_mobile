package com.niloufer.valet

import android.content.Context
import android.os.Build
import android.os.Bundle
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
import android.speech.tts.TextToSpeech
import android.util.Log
import androidx.annotation.NonNull
import com.google.firebase.messaging.RemoteMessage
import io.flutter.plugins.firebase.messaging.FlutterFirebaseMessagingService
import java.util.Locale
import java.util.UUID

/**
 * Custom FCM service that speaks the notification body aloud and starts a
 * repeating vibration alert when the app is in background or terminated.
 * Extends Flutter's service so the Dart background handler and notification
 * display still work normally.
 */
class ValetFirebaseMessagingService : FlutterFirebaseMessagingService() {

    override fun onMessageReceived(@NonNull remoteMessage: RemoteMessage) {
        // DIAGNOSTIC: this line only appears in logcat if onMessageReceived is
        // actually called by Android.  If you never see it while the app is in
        // the background, the FCM message has a 'notification' block — see the
        // README note below about data-only messages.
        Log.d(TAG, "onMessageReceived called — type=${remoteMessage.data["type"]} " +
                "hasNotification=${remoteMessage.notification != null}")

        // Start repeating vibration for retrieval requests so the driver is
        // alerted even when the app is in background or terminated.
        if (remoteMessage.data["type"] == "retrieval_request") {
            startRepeatingVibration()
        }

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

    /**
     * Vibrate with a repeating pattern (700 ms on / 500 ms off) until cancelled.
     * The Flutter VibrationController.stop() → Vibration.cancel() call from Dart
     * will cancel this when the driver accepts or passes the request, because
     * both use the same system Vibrator for the app's UID.
     */
    private fun startRepeatingVibration() {
        try {
            // pattern: [delay, vibrate, pause, vibrate, ...] in milliseconds
            val pattern = longArrayOf(0L, 700L, 500L, 700L)
            val repeatIndex = 0 // repeat the whole waveform from the start

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                // Android 12+ — VibratorManager is the recommended API
                val vm = getSystemService(Context.VIBRATOR_MANAGER_SERVICE) as VibratorManager
                vm.defaultVibrator.vibrate(
                    VibrationEffect.createWaveform(pattern, repeatIndex)
                )
            } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                // Android 8–11
                @Suppress("DEPRECATION")
                val vibrator = getSystemService(Context.VIBRATOR_SERVICE) as Vibrator
                vibrator.vibrate(VibrationEffect.createWaveform(pattern, repeatIndex))
            } else {
                // Android < 8 — deprecated API, still works
                @Suppress("DEPRECATION")
                val vibrator = getSystemService(Context.VIBRATOR_SERVICE) as Vibrator
                @Suppress("DEPRECATION")
                vibrator.vibrate(pattern, repeatIndex)
            }
            Log.d(TAG, "Repeating vibration started for retrieval_request")
        } catch (e: Exception) {
            Log.e(TAG, "Failed to start vibration: ${e.message}")
        }
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
