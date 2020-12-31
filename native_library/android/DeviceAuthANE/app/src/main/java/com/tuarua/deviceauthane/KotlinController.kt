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

import android.content.pm.PackageInfo
import android.content.pm.PackageManager
import com.adobe.fre.FREContext
import com.adobe.fre.FREObject
import com.tuarua.frekotlin.*
import androidx.core.hardware.fingerprint.FingerprintManagerCompat
import com.google.gson.Gson
import java.util.concurrent.atomic.AtomicBoolean
import com.tuarua.deviceauthane.AuthenticationHelper.Companion.AuthCompletionHandler
import com.tuarua.deviceauthane.events.DeviceAuthEvent
import java.util.*

@Suppress("unused", "UNUSED_PARAMETER", "UNCHECKED_CAST")
class KotlinController : FreKotlinMainController {
    private val authInProgress = AtomicBoolean(false)
    private val gson = Gson()
    private var packageInfo: PackageInfo? = null
    private val permissionsNeeded: Array<String> = arrayOf("android.permission.USE_FINGERPRINT")
    private fun hasRequiredPermissions(): Boolean {
        val pi = packageInfo ?: return false
        permissionsNeeded.forEach { p ->
            if (p !in pi.requestedPermissions) {
                warning("Please add $p to uses-permission list in your AIR manifest")
                return false
            }
        }
        return true
    }

    fun createGUID(ctx: FREContext, argv: FREArgv): FREObject? {
        return UUID.randomUUID().toString().toFREObject()
    }

    fun init(ctx: FREContext, argv: FREArgv): FREObject? {
        val activity = context?.activity ?: return false.toFREObject()
        val packageManager = activity.packageManager
        val pm = packageManager ?: return false.toFREObject()
        packageInfo = pm.getPackageInfo(activity.packageName, PackageManager.GET_PERMISSIONS)
        return hasRequiredPermissions().toFREObject()
    }

    private object BiometryType {
        const val NONE = 0
        const val TOUCH = 1
        const val FACE = 2
        const val NOT_ENROLLED = 3
    }

    fun getBiometryType(ctx: FREContext, argv: FREArgv): FREObject? {
        val activity = context?.activity ?: return BiometryType.NONE.toFREObject()
        val fingerprintMgr = FingerprintManagerCompat.from(activity)
        return when {
            fingerprintMgr.isHardwareDetected -> when {
                fingerprintMgr.hasEnrolledFingerprints() -> BiometryType.TOUCH.toFREObject()
                else -> BiometryType.NOT_ENROLLED.toFREObject()
            }
            else -> BiometryType.NONE.toFREObject()
        }
    }

    fun authenticate(ctx: FREContext, argv: FREArgv): FREObject? {
        argv.takeIf { argv.size > 4 } ?: return FreArgException()
        val callbackId = String(argv[0]) ?: return null
        val reason = String(argv[1]) ?: return null
        val useErrorDialogs = Boolean(argv[2]) ?: return null
        val stickyAuth = Boolean(argv[3]) ?: return null
        val messages = Messages(argv[4]) ?: return null
        val activity = context?.activity ?: return null
        if (!authInProgress.compareAndSet(false, true)) {
            return null
        }
        val authenticationHelper = AuthenticationHelper(
                activity,
                reason,
                useErrorDialogs,
                stickyAuth,
                messages,
                object : AuthCompletionHandler {
                    override fun onSuccess() {
                        if (authInProgress.compareAndSet(true, false)) {
                            dispatchEvent(DeviceAuthEvent.SUCCESS,
                                    gson.toJson(DeviceAuthEvent(callbackId)))
                        }
                    }

                    override fun onFailure() {
                        if (authInProgress.compareAndSet(true, false)) {
                            dispatchEvent(DeviceAuthEvent.FAIL,
                                    gson.toJson(DeviceAuthEvent(callbackId)))
                        }
                    }

                    override fun onError(id: DeviceAuthError, message: String) {
                        if (authInProgress.compareAndSet(true, false)) {
                            dispatchEvent(DeviceAuthEvent.FAIL,
                                    gson.toJson(DeviceAuthEvent(callbackId, mapOf(
                                            "message" to message,
                                            "id" to id.ordinal))))
                        }
                    }
                })
        authenticationHelper.authenticate()
        return null
    }

    override val TAG: String
        get() = this::class.java.simpleName
    private var _context: FREContext? = null
    override var context: FREContext?
        get() = _context
        set(value) {
            _context = value
            FreKotlinLogger.context = _context
        }
}