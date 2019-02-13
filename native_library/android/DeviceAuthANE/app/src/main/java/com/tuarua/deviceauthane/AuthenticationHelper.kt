/*
 *  Copyright 2019 Tua Rua Ltd.
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 */
package com.tuarua.deviceauthane

import android.annotation.SuppressLint
import android.app.Activity
import android.app.AlertDialog
import android.app.Application
import android.app.KeyguardManager
import android.content.Context
import android.content.DialogInterface.OnClickListener
import android.content.Intent
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.provider.Settings
import android.support.v4.content.ContextCompat
import android.support.v4.hardware.fingerprint.FingerprintManagerCompat
import android.support.v4.os.CancellationSignal
import android.view.ContextThemeWrapper
import android.view.LayoutInflater
import android.widget.ImageView
import android.widget.TextView

class AuthenticationHelper internal constructor(
        private val activity: Activity,
        private val reason: String,
        private val useErrorDialogs: Boolean,
        private val stickyAuth: Boolean,
        private val messages: Messages,
        private val completionHandler: AuthCompletionHandler) : FingerprintManagerCompat.AuthenticationCallback(), Application.ActivityLifecycleCallbacks {
    private val keyguardManager: KeyguardManager = activity.getSystemService(Context.KEYGUARD_SERVICE) as KeyguardManager
    private val fingerprintManager: FingerprintManagerCompat = FingerprintManagerCompat.from(activity)
    private var fingerprintDialog: AlertDialog? = null
    private var cancellationSignal: CancellationSignal? = null

    internal fun authenticate() {
        if (fingerprintManager.isHardwareDetected) {
            if (keyguardManager.isKeyguardSecure && fingerprintManager.hasEnrolledFingerprints()) {
                start()
            } else {
                if (useErrorDialogs) {
                    showGoToSettingsDialog()
                } else if (!keyguardManager.isKeyguardSecure) {
                    completionHandler.onError(
                            DeviceAuthError.PASSCODE_NOT_SET,
                            "Phone not secured by PIN, pattern or password, or SIM is currently locked.")
                } else {
                    completionHandler.onError(
                            DeviceAuthError.NOT_ENROLLED,
                            "No fingerprint enrolled on this device.")
                }
            }
        } else {
            completionHandler.onError(
                    DeviceAuthError.NOT_AVAILABLE,
                    "Fingerprint is not available on this device.")
        }
    }

    private fun start() {
        activity.application.registerActivityLifecycleCallbacks(this)
        resume()
    }

    private fun resume() {
        cancellationSignal = CancellationSignal()
        showFingerprintDialog()
        fingerprintManager.authenticate(null, 0, cancellationSignal, this, null)
    }

    private fun pause() {
        cancellationSignal?.cancel()
        if (fingerprintDialog?.isShowing == true) {
            fingerprintDialog?.dismiss()
        }
    }

    /**
     * Stops the fingerprint listener and dismisses the fingerprint dialog.
     *
     * @param success If the authentication was successful.
     */
    private fun stop(success: Boolean) {
        pause()
        activity.application.unregisterActivityLifecycleCallbacks(this)
        if (success) {
            completionHandler.onSuccess()
        } else {
            completionHandler.onFailure()
        }
    }


    override fun onActivityResumed(activity: Activity) {
        if (stickyAuth) {
            resume()
        }
    }

    override fun onActivityPaused(activity: Activity) {
        if (stickyAuth) {
            pause()
        } else {
            stop(false)
        }
    }

    override fun onAuthenticationError(errMsgId: Int, errString: CharSequence?) {
        updateFingerprintDialog(Companion.DialogState.FAILURE, errString.toString())
    }

    override fun onAuthenticationHelp(helpMsgId: Int, helpString: CharSequence?) {
        updateFingerprintDialog(Companion.DialogState.FAILURE, helpString.toString())
    }

    override fun onAuthenticationFailed() {
        updateFingerprintDialog(Companion.DialogState.FAILURE, messages.fingerprintNotRecognized)
    }

    override fun onAuthenticationSucceeded(result: FingerprintManagerCompat.AuthenticationResult?) {
        updateFingerprintDialog(Companion.DialogState.SUCCESS, messages.fingerprintSuccess)
        Handler(Looper.myLooper())
                .postDelayed(
                        { stop(true) },
                        DISMISS_AFTER_MS)
    }

    private fun updateFingerprintDialog(state: DialogState, message: String?) {
        val cancellationSignal = cancellationSignal ?: return
        val fingerprintDialog = fingerprintDialog ?: return
        if (cancellationSignal.isCanceled || !fingerprintDialog.isShowing) {
            return
        }
        val resultInfo = fingerprintDialog.findViewById<TextView>(R.id.fingerprint_status)
        val icon = fingerprintDialog.findViewById<ImageView>(R.id.fingerprint_icon)
        when (state) {
            Companion.DialogState.FAILURE -> {
                icon.setImageResource(R.drawable.fingerprint_warning_icon)
                resultInfo.setTextColor(ContextCompat.getColor(activity, R.color.warning_color))
            }
            Companion.DialogState.SUCCESS -> {
                icon.setImageResource(R.drawable.fingerprint_success_icon)
                resultInfo.setTextColor(ContextCompat.getColor(activity, R.color.success_color))
            }
        }
        resultInfo.text = message
    }

    @SuppressLint("InflateParams")
    private fun showFingerprintDialog() {
        val view = LayoutInflater.from(activity).inflate(R.layout.scan_fp, null, false)
        val fpDescription = view.findViewById<TextView>(R.id.fingerprint_description)
        val title = view.findViewById<TextView>(R.id.fingerprint_signin)
        val status = view.findViewById<TextView>(R.id.fingerprint_status)
        fpDescription.text = reason
        title.text = messages.signInTitle
        status.text = messages.fingerprintHint
        val context = ContextThemeWrapper(activity, R.style.AlertDialogCustom)
        val cancelHandler = OnClickListener { _, _ -> stop(false) }
        fingerprintDialog = AlertDialog.Builder(context)
                .setView(view)
                .setNegativeButton(messages.cancelButton, cancelHandler)
                .setCancelable(false)
                .show()
    }

    @SuppressLint("InflateParams")
    private fun showGoToSettingsDialog() {
        val view = LayoutInflater.from(activity).inflate(R.layout.go_to_setting, null, false)
        val message = view.findViewById<TextView>(R.id.fingerprint_required)
        val description = view.findViewById<TextView>(R.id.go_to_setting_description)
        message.text = messages.fingerprintRequiredTitle
        description.text = messages.goToSettingsDescription
        val context = ContextThemeWrapper(activity, R.style.AlertDialogCustom)
        val goToSettingHandler = OnClickListener { _, _ ->
            stop(false)
            activity.startActivity(Intent(Settings.ACTION_SECURITY_SETTINGS))
        }
        val cancelHandler = OnClickListener { _, _ -> stop(false) }
        AlertDialog.Builder(context)
                .setView(view)
                .setPositiveButton(messages.goToSettingsButton, goToSettingHandler)
                .setNegativeButton(messages.cancelButton, cancelHandler)
                .setCancelable(false)
                .show()
    }

    override fun onActivityCreated(activity: Activity, bundle: Bundle) {}
    override fun onActivityStarted(activity: Activity) {}
    override fun onActivityStopped(activity: Activity) {}
    override fun onActivitySaveInstanceState(activity: Activity, bundle: Bundle) {}
    override fun onActivityDestroyed(activity: Activity) {}

    companion object {

        /**
         * How long will the fp dialog be delayed to dismiss.
         */
        private const val DISMISS_AFTER_MS: Long = 300

        /**
         * The callback that handles the result of this authentication process.
         */
        internal interface AuthCompletionHandler {

            /**
             * Called when authentication was successful.
             */
            fun onSuccess()

            /**
             * Called when authentication failed due to user. For instance, when user cancels the auth or
             * quits the app.
             */
            fun onFailure()

            /**
             * Called when authentication fails due to non-user related problems such as system errors,
             * phone not having a FP reader etc.
             *
             * @param id  The message id to be returned to Flutter app.
             * @param message The description of the message.
             */
            fun onError(id: DeviceAuthError, message: String)
        }

        /**
         * Captures the state of the fingerprint dialog.
         */
        private enum class DialogState {
            SUCCESS,
            FAILURE
        }
    }
}
