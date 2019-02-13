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
@file:Suppress("FunctionName")

package com.tuarua.deviceauthane

import com.adobe.fre.FREObject
import com.tuarua.frekotlin.String
import com.tuarua.frekotlin.get

class Messages {
    var fingerprintHint: String? = null
    var fingerprintNotRecognized: String? = null
    var fingerprintSuccess: String? = null
    var cancelButton: String? = null
    var signInTitle: String? = null
    var fingerprintRequiredTitle: String? = null
    var goToSettingsButton: String? = null
    var goToSettingsDescription: String? = null
}

fun Messages(freObject: FREObject?): Messages? {
    val fre = freObject ?: return null
    val ret = Messages()
    ret.fingerprintHint = String(fre["fingerprintHint"])
    ret.fingerprintNotRecognized = String(fre["fingerprintNotRecognized"])
    ret.fingerprintSuccess = String(fre["fingerprintSuccess"])
    ret.cancelButton = String(fre["cancelButton"])
    ret.signInTitle = String(fre["signInTitle"])
    ret.fingerprintRequiredTitle = String(fre["fingerprintRequiredTitle"])
    ret.goToSettingsButton = String(fre["goToSettingsButton"])
    ret.goToSettingsDescription = String(fre["goToSettingsDescription"])
    return ret
}