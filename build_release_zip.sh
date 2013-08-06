#!/bin/sh
#******************************************************************************
# This shell script pulls together the pieces that make up the iOS SDK
# distribution and builds a single zip file containing those pieces.
#
# The version of the SDK should be passed in as an argument.
# Example: build_sdk_zip.sh 1.4.3
#******************************************************************************

# verify that we've been given an argument (the version string)
if [ $# -eq 0 ]
  then
    echo "Error: SDK version string should be passed as argument"
	exit 1
fi

# SDK version string is passed in as an argument to this script
SDK_VERSION="$1"

# set up our tools
BUILD_COMMAND="./Scripts/framework.sh"

# set our paths and file names
LIBRARY_BASE_NAME="apigee-ios"
FRAMEWORK_FILE_NAME="ApigeeiOSSDK.framework"
ZIP_BASE_NAME="${LIBRARY_BASE_NAME}-sdk"
ZIP_FILE_NAME="${ZIP_BASE_NAME}.zip"
TOPLEVEL_ZIP_DIR="zip"
DEST_ZIP_DIR="${TOPLEVEL_ZIP_DIR}/${LIBRARY_BASE_NAME}-sdk-${SDK_VERSION}"
BUILT_FRAMEWORK="source/build/framework/${FRAMEWORK_FILE_NAME}"
ZIP_BIN_DIR="${DEST_ZIP_DIR}/bin"

# make a clean build
cd source
"${BUILD_COMMAND}"
BUILD_EXIT_CODE=$?
cd ..


if [[ ${BUILD_EXIT_CODE} != 0 ]] ; then
    exit ${BUILD_EXIT_CODE}
fi

# new framework file found?
if [ ! -d "${BUILT_FRAMEWORK}" ] ; then
	echo "Error: unable to find framework '${BUILT_FRAMEWORK}'"
	exit 1
fi

# zip directory exists?
if [ -d "${DEST_ZIP_DIR}" ]; then
	# erase all existing files there
	find "${DEST_ZIP_DIR}" -type f -exec rm {} \;
else
	mkdir -p "${DEST_ZIP_DIR}"
fi

# copy everything from repository
for entry in *
do
	if [ -f "$entry" ]; then
		cp "$entry" "${DEST_ZIP_DIR}"
	elif [ -d "$entry" ]; then
		if [ "$entry" != "${TOPLEVEL_ZIP_DIR}" ]; then
			cp -r "$entry" "${DEST_ZIP_DIR}"
		fi
	fi
done


# if we have source/build in zip directory, delete it and everything under it
if [ -d "${DEST_ZIP_DIR}/source/build" ]; then
	rm -rf "${DEST_ZIP_DIR}/source/build"
	rmdir "${DEST_ZIP_DIR}/source/build"
fi


# create directory for binaries
mkdir -p "${ZIP_BIN_DIR}"

# copy framework to destination directory
cp -r "${BUILT_FRAMEWORK}" "${ZIP_BIN_DIR}"


# create the zip file
cd ${TOPLEVEL_ZIP_DIR} && zip -r -y ${ZIP_FILE_NAME} .

