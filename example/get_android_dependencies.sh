#!/bin/sh

AneVersion="1.2.0"
FreKotlinVersion="1.8.0"
SupportV4Version="27.1.0"
GsonVersion="2.8.4"

wget -O android_dependencies/com.tuarua.frekotlin-$FreKotlinVersion.ane https://github.com/tuarua/Android-ANE-Dependencies/blob/master/anes/kotlin/com.tuarua.frekotlin-$FreKotlinVersion.ane?raw=true
wget -O android_dependencies/com.android.support.support-v4-$SupportV4Version.ane https://github.com/tuarua/Android-ANE-Dependencies/blob/master/anes/support/com.android.support.support-v4-$SupportV4Version-air33.ane?raw=true
wget -O android_dependencies/com.google.code.gson.gson-$GsonVersion.ane https://github.com/tuarua/Android-ANE-Dependencies/blob/master/anes/misc/com.google.code.gson.gson-$GsonVersion-air33.ane?raw=true
wget -O ../native_extension/ane/DeviceAuthANE.ane https://github.com/tuarua/DeviceAuth-ANE/releases/download/$AneVersion/DeviceAuthANE.ane?raw=true
