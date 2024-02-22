#!/bin/bash

APK_URL='https://mapdownload.autonavi.com/apps/auto/manual/V750/Auto_7.5.0.600056_beta.apk'
APK_RELEASE_NAME='Auto_7.5.0.600056_beta_clone.apk'
PACKAGE_NAME='com.autonavi.amapautoclone' # 包名
APP_NAME='高德比亚迪' # App显示名称
FIXED_CHANNEL='on' # 锁定13通道，on表示锁定，off表示不锁定

mkdir ./out
curl -sL -o amap.apk ${APK_URL}

apktool d amap.apk
sed -i 's/    const\/4 p0, 0x0/    const\/4 p0, 0x1/' `grep -ril "ApkSignUtil.java" ./amap/`

if [ $FIXED_CHANNEL='on' ]
then
    sed -i '/^    iput p1, p0/i\    const\/16 p1, 0xE\n' ./amap/smali/com/autonavi/amapauto/jni/config/AudioConfigData.smali
    sed -i '/^    return v1/i\    const\/16 v1, 0xE\n' ./amap/smali/com/autonavi/amapauto/jni/config/AudioConfigData.smali
    sed -i '/^    const\/4 v0, 0x0/i\    const\/16 v0, 0xE\n' ./amap/smali/com/autonavi/amapauto/jni/config/AudioConfigData.smali
    sed -i '/^    const\/4 v0, 0x0/i\    iput v0, p0, Lcom\/autonavi\/amapauto\/jni\/config\/AudioConfigData;->audioChannel:I\n' ./amap/smali/com/autonavi/amapauto/jni/config/AudioConfigData.smali
end

sed -i "s/package=\"com.autonavi.amapauto/package=\"${PACKAGE_NAME}/" ./amap/AndroidManifest.xml
sed -i "s/com.autonavi.amapauto.permission/${PACKAGE_NAME}.permission/' ./amap/AndroidManifest.xml
sed -i "s/android:authorities=\"com.autonavi.amapauto/android:authorities=\"${PACKAGE_NAME}/" ./amap/AndroidManifest.xml
sed -i "s/\>高德地图</\>${APP_NAME}</" ./amap/res/values-zh/strings.xml
sed -i "s/\>高德地图</\>${APP_NAME}</" ./amap/res/values/strings.xml

apktool b amap -o amap_clone.apk
apksigner sign --ks key.keystore --ks-pass pass:qwertasdfgzxcvb --out ./out/${APK_RELEASE_NAME} amap_clone.apk

rm ./amap_clone.apk