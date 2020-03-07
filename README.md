# DeviceAuth-ANE

Perform local, on-device authentication of the user with this Adobe Air Native Extension for iOS 9.0+ and Android 21+.   

Offers Fingerprint on iOS/Android and FaceID on iOS.

-------------

## Android

#### The ANE + Dependencies

cd into /example and run:
- macOS (Terminal)
```shell
bash get_android_dependencies.sh
```
- Windows Powershell
```shell
PS get_android_dependencies.ps1
```

```xml
<extensions>
<extensionID>com.tuarua.frekotlin</extensionID>
<extensionID>com.google.code.gson.gson</extensionID>
<extensionID>androidx.legacy.legacy-support-v4</extensionID>
<extensionID>com.tuarua.DeviceAuthANE</extensionID>
...
</extensions>
```

You will also need to include the following in your app manifest. Update accordingly.

```xml
<uses-sdk android:minSdkVersion="21" android:targetSdkVersion="27" />
<uses-permission android:name="android.permission.USE_FINGERPRINT"/>
```

-------------

## iOS

#### The ANE + Dependencies

N.B. You must use a Mac to build an iOS app using this ANE. Windows is NOT supported.

From the command line cd into /example and run:

```shell
bash get_ios_dependencies.sh
```

This folder, ios_dependencies/device/Frameworks, must be packaged as part of your app when creating the ipa. How this is done will depend on the IDE you are using.
After the ipa is created unzip it and confirm there is a "Frameworks" folder in the root of the .app package.   

-------------

If you wish to use FaceID you will also need to include the following in your app manifest. Update accordingly.
```xml
<InfoAdditions><![CDATA[            
<key>NSFaceIDUsageDescription</key>
<string>Reason for authenticating using face id?</string>
]]></InfoAdditions>
```

### Prerequisites

You will need:

- IntelliJ IDEA
- AIR 33.0.2.338+
- Xcode 11.3
- wget on macOS via `brew install wget`
- Powershell on Windows
- Android Studio 3 if you wish to edit the Android source
