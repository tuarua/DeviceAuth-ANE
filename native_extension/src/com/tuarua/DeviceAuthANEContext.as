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
    private static var _isDisposed:Boolean;
    private static var argsAsJSON:Object;
    public static var closures:Dictionary = new Dictionary();
    public static var closureCallers:Dictionary = new Dictionary();
    private static const SUCCESS:String = "DeviceAuthEvent.Success";
    private static const FAIL:String = "DeviceAuthEvent.Fail";

    public function DeviceAuthANEContext() {
    }

    public static function get context():ExtensionContext {
        if (_context == null) {
            try {
                _context = ExtensionContext.createExtensionContext("com.tuarua." + NAME, null);
                _context.addEventListener(StatusEvent.STATUS, gotEvent);
                _isDisposed = false;
            } catch (e:Error) {
                trace("[" + NAME + "] ANE not loaded properly.  Future calls will fail.");
            }
        }
        return _context;
    }

    public static function createEventId(listener:Function, listenerCaller:Object = null):String {
        var eventId:String;
        if (listener != null) {
            eventId = context.call("createGUID") as String;
            closures[eventId] = listener;
            if (listenerCaller) {
                closureCallers[eventId] = listenerCaller;
            }
        }
        return eventId;
    }

    private static function gotEvent(event:StatusEvent):void {
        var err:DeviceAuthError;
        var closure:Function;
        switch (event.level) {
            case TRACE:
                trace("[" + NAME + "]", event.code);
                break;
            case SUCCESS:
                // trace("gotEvent SUCCESS", event.code);
                try {
                    argsAsJSON = JSON.parse(event.code);
                    closure = closures[argsAsJSON.eventId];
                    if (closure == null) return;
                    closure.call(null, true, null);
                    delete closures[argsAsJSON.eventId];
                } catch (e:Error) {
                    trace("parsing error", event.code, e.message);
                }
                break;
            case FAIL:
                // trace("gotEvent FAIL", event.code);
                try {
                    argsAsJSON = JSON.parse(event.code);
                    closure = closures[argsAsJSON.eventId];
                    if (closure == null) return;
                    if (argsAsJSON.hasOwnProperty("error") && argsAsJSON.error) {
                        err = new DeviceAuthError(argsAsJSON.error.message, argsAsJSON.error.id);
                    }
                    closure.call(null, false, err);
                    delete closures[argsAsJSON.eventId];
                } catch (e:Error) {
                    trace("parsing error", event.code, e.message);
                }
                break;
        }
    }

    public static function dispose():void {
        if (_context == null) return;
        _isDisposed = true;
        trace("[" + NAME + "] Unloading ANE...");
        _context.removeEventListener(StatusEvent.STATUS, gotEvent);
        _context.dispose();
        _context = null;
    }

    public static function get isDisposed():Boolean {
        return _isDisposed;
    }

    private static function throwError(error:ANEError):void {
        throw error;
    }

}
}
