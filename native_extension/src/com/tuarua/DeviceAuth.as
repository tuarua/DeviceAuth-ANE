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


package com.tuarua {
import com.tuarua.deviceAuth.AndroidMessages;
import com.tuarua.deviceAuth.IosMessages;
import com.tuarua.fre.ANEError;

public class DeviceAuth {
    private static var _shared:DeviceAuth;
    private static var _androidMessages:AndroidMessages = new AndroidMessages();
    private static var _iosMessages:IosMessages = new IosMessages();
    private static var _useErrorDialogs:Boolean = true;
    private static var _stickyAuth:Boolean = false;

    public function DeviceAuth() {
        if (_shared) {
            throw new Error(DeviceAuthANEContext.NAME + " is a singleton, use .shared()");
        }
        if (DeviceAuthANEContext.context) {
            var ret:* = DeviceAuthANEContext.context.call("init");
            if (ret is ANEError) throw ret as ANEError;
        }
        _shared = this;
    }

    public static function shared():DeviceAuth {
        if (_shared == null) {
            new DeviceAuth();
        }
        return _shared;
    }

    public function get biometryType():int {
        var ret:* = DeviceAuthANEContext.context.call("getBiometryType");
        if (ret is ANEError) throw ret as ANEError;
        return ret as int;
    }

    /** @reason is the message to show to user while prompting them
     * for authentication. This is typically along the lines of: 'Please scan
     * your finger to access MyApp.'*/
    public function authenticate(reason:String, listener:Function):void {
        DeviceAuthANEContext.context.call("authenticate", DeviceAuthANEContext.createCallback(listener),
                reason, _useErrorDialogs, _stickyAuth, _androidMessages, _iosMessages);
    }

    public static function get androidMessages():AndroidMessages {
        return _androidMessages;
    }

    public static function get iosMessages():IosMessages {
        return _iosMessages;
    }

    /** true means the system will attempt to handle user
     * fixable issues encountered while authenticating. For instance, if
     * fingerprint reader exists on the phone but there's no fingerprint
     * registered, the plugin will attempt to take the user to settings to add
     * one. */
    public static function set useErrorDialogs(value:Boolean):void {
        _useErrorDialogs = value;
    }

    /** is used when the application goes into background for any
     * reason while the authentication is in progress. Due to security reasons,
     * the authentication has to be stopped at that time. If stickyAuth is set
     * to true, authentication resumes when the app is resumed. If it is set to
     * false (default), then as soon as app is paused a failure message is sent
     * back to AIR and it is up to the client app to restart authentication or
     * do something else. */
    public static function set stickyAuth(value:Boolean):void {
        _stickyAuth = value;
    }

    public static function dispose():void {
        if (DeviceAuthANEContext.context) {
            DeviceAuthANEContext.dispose();
        }
    }

}
}
