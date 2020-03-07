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
import FreSwift
import LocalAuthentication

public class SwiftController: NSObject {
    public static var TAG = "DeviceAuthANE"
    public var context: FreContextSwift!
    public var functionsToSet: FREFunctionMap = [:]
    
    struct AuthenticateArgs {
        var callbackId: String
        var reason: String
        var useErrorDialogs: Bool
        var stickyAuth: Bool
        var messages: Messages
    }
    
    internal var lastCallArgs: AuthenticateArgs?
    
    enum BiometryType: UInt {
        case none
        case touch
        case face
        case notEnrolled
    }
    
    func initController(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        return true.toFREObject()
    }
    
    func getBiometryType(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        let lactx = LAContext()
        var authError: NSError?
        if lactx.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError) {
            if authError == nil {
                if #available(iOS 11.0, *) {
                    return lactx.biometryType.rawValue.toFREObject()
                } else {
                    return BiometryType.touch.rawValue.toFREObject()
                }
            }
        } else if authError?.code == LAError.touchIDNotEnrolled.rawValue {
            return BiometryType.notEnrolled.rawValue.toFREObject()
        }
        return BiometryType.none.rawValue.toFREObject()
    }
    
    func authenticate(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        guard argc > 5,
            let callbackId = String(argv[0]),
            let reason = String(argv[1]),
            let useErrorDialogs = Bool(argv[2]),
            let stickyAuth = Bool(argv[3]),
            let messages = Messages(argv[5])
            else {
                return FreArgError().getError()
        }
        authenticate(callbackId: callbackId, reason: reason, useErrorDialogs: useErrorDialogs,
                     stickyAuth: stickyAuth, messages: messages)
        return nil
    }
    
    func authenticate(callbackId: String, reason: String, useErrorDialogs: Bool, stickyAuth: Bool, messages: Messages) {
        lastCallArgs = nil
        let lactx = LAContext()
        var authError: NSError?
        if lactx.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError) {
            lactx.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                                 localizedReason: reason) { success, evaluateError in
                if success {
                    self.dispatchEvent(name: DeviceAuthEvent.success,
                                       value: DeviceAuthEvent(callbackId: callbackId).toJSONString())
                } else {
                    switch evaluateError {
                    case LAError.passcodeNotSet?,
                         LAError.touchIDNotAvailable?,
                         LAError.touchIDNotEnrolled?,
                         LAError.touchIDLockout?,
                         LAError.userFallback?:
                        self.handleErrors(callbackId: callbackId,
                                          error: evaluateError,
                                          useErrorDialogs: useErrorDialogs,
                                          messages: messages)
                        return
                    case LAError.systemCancel?:
                        if stickyAuth {
                            self.lastCallArgs = AuthenticateArgs(callbackId: callbackId,
                                                                 reason: reason,
                                                                 useErrorDialogs: useErrorDialogs,
                                                                 stickyAuth: stickyAuth,
                                                                 messages: messages)
                            return
                        }
                    default: break
                    }
                    self.dispatchEvent(name: DeviceAuthEvent.fail,
                                       value: DeviceAuthEvent(callbackId: callbackId).toJSONString())
                }
            }
        } else {
            if let err = authError {
                handleErrors(callbackId: callbackId, error: err, useErrorDialogs: useErrorDialogs, messages: messages)
            }
        }
    }
    
    func handleErrors(callbackId: String, error: Error?, useErrorDialogs: Bool, messages: Messages) {
        guard let error = error else { return }
        var errorCode = DeviceAuthError.notAvailable
        switch error {
        case LAError.passcodeNotSet,
             LAError.touchIDNotEnrolled:
            if useErrorDialogs {
                alertMessage(message: messages.goToSettingDescription,
                             firstButton: messages.okButton,
                             callbackId: callbackId,
                             secondButton: messages.goToSetting)
                return
            }
        case LAError.touchIDLockout:
            alertMessage(message: messages.lockOut, firstButton: messages.okButton, callbackId: callbackId)
                return
        default: break
        }
        
        switch error {
        case LAError.passcodeNotSet:
            errorCode = DeviceAuthError.passcodeNotSet
        case LAError.touchIDNotEnrolled:
            errorCode = DeviceAuthError.notEnrolled
        case LAError.userFallback:
            errorCode = DeviceAuthError.userFallback
        default: break
        }
        
        self.dispatchEvent(name: DeviceAuthEvent.fail,
                           value: DeviceAuthEvent(callbackId: callbackId,
                                                  error: DeviceAuthError(message: error.localizedDescription,
                                                                         id: errorCode)).toJSONString())
    }
    
    private func alertMessage(message: String, firstButton: String, callbackId: String, secondButton: String? = nil) {
        let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: firstButton, style: .default) { _ in
            self.dispatchEvent(name: DeviceAuthEvent.fail,
                               value: DeviceAuthEvent(callbackId: callbackId).toJSONString())
        }
        alert.addAction(defaultAction)
        if let secondButton = secondButton {
            let secondAction = UIAlertAction(title: secondButton, style: .default) { _ in
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.openURL(url)
                    self.dispatchEvent(name: DeviceAuthEvent.fail,
                                       value: DeviceAuthEvent(callbackId: callbackId).toJSONString())
                }
            }
            alert.addAction(secondAction)
            if let rootViewController = UIApplication.shared.keyWindow?.rootViewController {
                rootViewController.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    @objc func applicationBecomeActive(_ notification: Notification) {
        if let lastCallArgs = lastCallArgs {
            authenticate(callbackId: lastCallArgs.callbackId,
                         reason: lastCallArgs.reason,
                         useErrorDialogs: lastCallArgs.useErrorDialogs,
                         stickyAuth: lastCallArgs.stickyAuth,
                         messages: lastCallArgs.messages)
        }
    }
    
}
