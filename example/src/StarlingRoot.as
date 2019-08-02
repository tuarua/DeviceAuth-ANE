package {

import com.tuarua.DeviceAuthANE;
import com.tuarua.deviceAuth.BiometryType;
import com.tuarua.deviceAuth.DeviceAuthError;

import flash.desktop.NativeApplication;
import flash.events.Event;

import starling.display.Sprite;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;
import starling.text.TextField;
import starling.utils.Align;

import views.SimpleButton;

public class StarlingRoot extends Sprite {
    private var authenticateBtn:SimpleButton = new SimpleButton("Authenticate");
    private var statusLabel:TextField;
    private var deviceAuth:DeviceAuthANE;

    public function StarlingRoot() {
        super();
        TextField.registerCompositor(Fonts.getFont("fira-sans-semi-bold-13"), "Fira Sans Semi-Bold 13");
        NativeApplication.nativeApplication.addEventListener(Event.EXITING, onExiting);
    }

    public function start():void {
        deviceAuth = DeviceAuthANE.deviceAuth;
        DeviceAuthANE.useErrorDialogs = true;
        initMenu();
    }

    private function initMenu():void {
        authenticateBtn.y = 100;
        authenticateBtn.addEventListener(TouchEvent.TOUCH, onAuthenticateTouch);
        authenticateBtn.x = (stage.stageWidth - 200) / 2;

        var biometryType:int = deviceAuth.biometryType;
        if (biometryType != BiometryType.NONE) {
            addChild(authenticateBtn);
        }

        statusLabel = new TextField(stage.stageWidth, 100, "");
        statusLabel.format.setTo(Fonts.NAME, 13, 0x222222, Align.CENTER, Align.TOP);
        statusLabel.touchable = false;
        statusLabel.y = authenticateBtn.y + 75;
        switch (biometryType) {
            case BiometryType.NONE:
                statusLabel.text = "No Biometry available";
                break;
            case BiometryType.NOT_ENROLLED:
                statusLabel.text = "No Biometry set up";
                break;
            case BiometryType.TOUCH:
                statusLabel.text = "Touch Biometry available";
                break;
            case BiometryType.FACE:
                statusLabel.text = "Face Biometry available";
                break;
        }
        addChild(statusLabel);
    }

    private function onAuthenticateTouch(event:TouchEvent):void {
        event.stopPropagation();
        var touch:Touch = event.getTouch(authenticateBtn, TouchPhase.ENDED);
        if (touch && touch.phase == TouchPhase.ENDED) {
            deviceAuth.authenticate("Confirm that's you", function (success:Boolean, error:DeviceAuthError):void {
                statusLabel.text = "Success: " + success;
                if (error) {
                    statusLabel.text = error.message;

                    switch (error.errorID) {
                        case DeviceAuthError.NOT_AVAILABLE:
                            break;
                        case DeviceAuthError.NOT_ENROLLED:
                            break;
                        case DeviceAuthError.PASSCODE_NOT_SET:
                            break;
                        case DeviceAuthError.USER_FALLBACK:
                            //present app password instead iOS only
                            break;
                    }
                }
            });
        }
    }

    private function onExiting(event:Event):void {
        DeviceAuthANE.dispose();
    }

}
}
