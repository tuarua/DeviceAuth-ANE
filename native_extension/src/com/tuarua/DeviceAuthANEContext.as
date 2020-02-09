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
import com.tuarua.deviceAuth.DeviceAuthError;
import com.tuarua.fre.ANEError;

import flash.events.StatusEvent;
import flash.external.ExtensionContext;
import flash.utils.Dictionary;

/** @private */
public class DeviceAuthANEContext {
    internal static const NAME:String = "DeviceAuthANE";
    internal static const TRACE:String = "TRACE";
    private static var _context:ExtensionContext;
    private static var argsAsJSON:Object;
    public static var callbacks:Dictionary = new Dictionary();
    private static const SUCCESS:String = "DeviceAuthEvent.Success";
    private static const FAIL:String = "DeviceAuthEvent.Fail";

    public function DeviceAuthANEContext() {
    }

    public static function get context():ExtensionContext {
        if (_context == null) {
            try {
                _context = ExtensionContext.createExtensionContext("com.tuarua." + NAME, null);
                _context.addEventListener(StatusEvent.STATUS, gotEvent);
            } catch (e:Error) {
                trace("[" + NAME + "] ANE not loaded properly.  Future calls will fail.");
            }
        }
        return _context;
    }

    public static function createCallback(listener:Function):String {
        var id:String;
        if (listener != null) {
            id = context.call("createGUID") as String;
            callbacks[id] = listener;
        }
        return id;
    }

    private static function gotEvent(event:StatusEvent):void {
        var err:DeviceAuthError;
        var callback:Function;
        switch (event.level) {
            case TRACE:
                trace("[" + NAME + "]", event.code);
                break;
            case SUCCESS:
                try {
                    argsAsJSON = JSON.parse(event.code);
                    callback = callbacks[argsAsJSON.callbackId];
                    if (callback == null) return;
                    callback.call(null, true, null);
                    delete callbacks[argsAsJSON.callbackId];
                } catch (e:Error) {
                    trace("parsing error", event.code, e.message);
                }
                break;
            case FAIL:
                try {
                    argsAsJSON = JSON.parse(event.code);
                    callback = callbacks[argsAsJSON.callbackId];
                    if (callback == null) return;
                    if (argsAsJSON.hasOwnProperty("error") && argsAsJSON.error) {
                        err = new DeviceAuthError(argsAsJSON.error.message, argsAsJSON.error.id);
                    }
                    callback.call(null, false, err);
                    delete callbacks[argsAsJSON.callbackId];
                } catch (e:Error) {
                    trace("parsing error", event.code, e.message);
                }
                break;
        }
    }

    public static function dispose():void {
        if (_context == null) return;
        trace("[" + NAME + "] Unloading ANE...");
        _context.removeEventListener(StatusEvent.STATUS, gotEvent);
        _context.dispose();
        _context = null;
    }
}
}
