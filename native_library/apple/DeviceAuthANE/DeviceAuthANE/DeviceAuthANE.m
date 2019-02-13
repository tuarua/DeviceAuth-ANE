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

#import "FreMacros.h"
#import "DeviceAuthANE_oc.h"
#import <DeviceAuthANE_FW/DeviceAuthANE_FW.h>

#define FRE_OBJC_BRIDGE TRDAU_FlashRuntimeExtensionsBridge
@interface FRE_OBJC_BRIDGE : NSObject<FreSwiftBridgeProtocol>
@end
@implementation FRE_OBJC_BRIDGE {
}
FRE_OBJC_BRIDGE_FUNCS
@end

@implementation DeviceAuthANE_LIB
SWIFT_DECL(TRDAU)
CONTEXT_INIT(TRDAU) {
    SWIFT_INITS(TRDAU)
    static FRENamedFunction extensionFunctions[] =
    {
         MAP_FUNCTION(TRDAU, init)
        ,MAP_FUNCTION(TRDAU, createGUID)
        ,MAP_FUNCTION(TRDAU, authenticate)
        ,MAP_FUNCTION(TRDAU, getBiometryType)
    };
    SET_FUNCTIONS
    
}

CONTEXT_FIN(TRDAU) {
    [TRDAU_swft dispose];
    TRDAU_swft = nil;
    TRDAU_freBridge = nil;
    TRDAU_swftBridge = nil;
    TRDAU_funcArray = nil;
}
EXTENSION_INIT(TRDAU)
EXTENSION_FIN(TRDAU)
@end
