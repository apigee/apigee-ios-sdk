#!/bin/sh
#******************************************************************************
# This shell script pulls together the pieces that make up the iOS SDK
# distribution and builds a single zip file containing those pieces.
#
# The version of the SDK should be passed in as an argument.
# Example: build_sdk_zip.sh 1.4.3
#
# Be aware that one of the destination directories has a space in the name.
# This calls for extra care and caution and requires any command-line parameters
# that use it to be enclosed in quotes.
#******************************************************************************

# verify that we've been given an argument (the version string)
if [ $# -eq 0 ]
  then
    echo "Error: SDK version string should be passed as argument"
	exit 1
fi

# SDK version string is passed in as an argument to this script
SDK_VERSION="$1"

# set our file names
STATIC_LIBRARY_FILE_NAME="libInstaOpsSDK.a"
FRAMEWORK_FILE_NAME="InstaOpsSDK.framework"
ZIP_FILE_NAME="ApigeeMobileAnalytics_iOS.zip"

# set up our paths and directory names
DEST_ZIP_DIR="build/zip"
DEST_ROOT_FOLDER_NAME="ApigeeMobileAnalytics_iOS-${SDK_VERSION}"
DEST_ROOT_FOLDER_DIR="${DEST_ZIP_DIR}/${DEST_ROOT_FOLDER_NAME}"
DEST_STATIC_LIB_DIR="${DEST_ROOT_FOLDER_DIR}/Static Library"
DEST_HEADERS_DIR="${DEST_STATIC_LIB_DIR}/Headers"
SRC_STATIC_LIB_DIR="build/dist"
SRC_HEADERS_DIR="${SRC_STATIC_LIB_DIR}/Headers"
SRC_FRAMEWORK_DIR="build/framework"

# clean any existing destination directory
rm -rf ${DEST_ROOT_FOLDER_DIR}

# create the top level folder
mkdir -p ${DEST_ROOT_FOLDER_DIR}

# create folder for static library
mkdir "${DEST_STATIC_LIB_DIR}"

# create folder for headers
mkdir "${DEST_HEADERS_DIR}"

# copy header files for static library
cp ${SRC_HEADERS_DIR}/*.h "${DEST_HEADERS_DIR}"

# copy static library file
cp ${SRC_STATIC_LIB_DIR}/${STATIC_LIBRARY_FILE_NAME} "${DEST_STATIC_LIB_DIR}"

# copy framework
cp -R ${SRC_FRAMEWORK_DIR}/${FRAMEWORK_FILE_NAME} ${DEST_ROOT_FOLDER_DIR}

# create the zip file
cd ${DEST_ZIP_DIR} && zip -r -y ${ZIP_FILE_NAME} .

