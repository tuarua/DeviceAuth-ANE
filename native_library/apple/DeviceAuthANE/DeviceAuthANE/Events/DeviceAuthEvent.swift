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

import Foundation

class DeviceAuthEvent: NSObject {
    public static let success = "DeviceAuthEvent.Success"
    public static let fail = "DeviceAuthEvent.Fail"
    var callbackId: String?
    var error: DeviceAuthError?
    
    convenience init(callbackId: String?, error: DeviceAuthError? = nil) {
        self.init()
        self.callbackId = callbackId
        self.error = error
    }
    
    public func toJSONString() -> String {
        var props = [String: Any]()
        props["callbackId"] = callbackId
        props["error"] = error?.toDictionary()
        return JSON(props).description
    }
}
