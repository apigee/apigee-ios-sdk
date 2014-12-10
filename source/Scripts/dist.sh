#!/bin/sh
#  package-build.sh
#  ApigeeiOSSDK
#
#  Copyright (c) 2012 Apigee. All rights reserved.

function failed()
{
    echo "Build failed: $1" >&2
    exit $2
}

function build_sdk()
{
    xcodebuild -workspace ApigeeiOSSDK.xcworkspace -scheme ApigeeiOSSDK -derivedDataPath build -configuration $cfg -sdk $sdk clean;
    xcodebuild -workspace ApigeeiOSSDK.xcworkspace -scheme ApigeeiOSSDK -derivedDataPath build -configuration $cfg -sdk $sdk || failed "${sdk}-${cfg} failed to build" $?
}

function buildall()
{
    for cfg in $CONFIGURATION; do
        for sdk in $SDKS; do
        
            #build sdk using configuration
            build_sdk
        done

        lib_386=build/Build/Products/${cfg}-iphonesimulator/lib${LIBNAME}.a
        lib_arm=build/Build/Products/${cfg}-iphoneos/lib${LIBNAME}.a
        lib_fat=lib${FRAMEWORKNAME}.a

        if [ ${cfg} == "Debug" ]; then
            lib_fat=libApigeeiOSSDK-d.a
        fi

        lipo -create ${lib_arm} ${lib_386} -output build/dist/${lib_fat}
    done
}

#xcode
#DEVELOPER_DIR="/Applications/Xcode5-DP.app/Contents/Developer"
#export DEVELOPER_DIR

#artifacts
LIBNAME="ApigeeiOSSDK"
FRAMEWORKNAME="ApigeeiOSSDK"

#configuration
SDKS="iphoneos iphonesimulator"

#CONFIGURATION="Debug Release" uncomment if you want debug configurations built
CONFIGURATION="Release"

#clean before creating new distribution
rm -rf build/dist
mkdir -p build/dist/Headers

#build all artifacts
buildall

#copy headers
find build/Build/Products/${cfg}-iphoneos/include -name '*.h' -exec cp {} build/dist/Headers \;

