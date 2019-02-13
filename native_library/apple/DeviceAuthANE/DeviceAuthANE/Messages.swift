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

import Foundation

class Messages: NSObject {
    var lockOut = "Biometric authentication is disabled. Please lock and unlock your screen to enable it."
    var goToSetting = "Go to settings"
    var goToSettingDescription = "Biometric authentication is not set up on your device. " +
    "Please either enable Touch ID or Face ID on your phone."
    var okButton = "OK"
    public init?(_ freObject: FREObject?) {
        guard let rv = freObject else { return nil }
        let fre = FreObjectSwift(rv)
        super.init()
        self.lockOut = fre.lockOut ?? lockOut
        self.goToSetting = fre.goToSetting ?? goToSetting
        self.goToSettingDescription = fre.goToSettingDescription ?? goToSettingDescription
        self.okButton = fre.okButton ?? okButton
    }
}
