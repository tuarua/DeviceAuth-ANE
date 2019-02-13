/* Copyright 2018 Tua Rua Ltd.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

package com.tuarua.deviceAuth {
public class DeviceAuthError extends Error {
    /** Indicates that the user has not yet configured a passcode (iOS) or
     * PIN/pattern/password (Android) on the device. */
    public static const PASSCODE_NOT_SET:int = 0;
    /** Indicates the user has not enrolled any fingerprints on the device.*/
    public static const NOT_ENROLLED:int = 1;
    /** Indicates the device does not have a Touch ID/fingerprint scanner. */
    public static const NOT_AVAILABLE:int = 2;
    /** Indicates the user has chosen to enter Password instead on the device. iOS only*/
    public static const USER_FALLBACK:int = 3;
    public function DeviceAuthError(message:* = "", id:* = 0) {
        super(message, id);
    }
}
}
