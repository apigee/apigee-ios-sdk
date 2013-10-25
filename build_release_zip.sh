#!/bin/sh
#******************************************************************************
# NOTE: This shell script is used by Apigee to produce a zip file of a release.
# You do not need to use this in order to build the framework from source. To
# do that, you just need to use ./source/Scripts/framework.sh
#
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

# the following command string pulls the version string from the sdk source
SDK_SOURCE_VERSION=`grep "kSDKVersion =" source/Classes/ApigeeClient.m | awk '{print $5}' | cut -d'"' -f2`

if [ "${SDK_VERSION}" != "${SDK_SOURCE_VERSION}" ]; then
	echo "Error: sdk source version (${SDK_SOURCE_VERSION}) does not match specified version (${SDK_VERSION})"
	exit 1
fi


# set up our tools
BUILD_COMMAND="./Scripts/framework.sh"
BUILD_DOCS_COMMAND="./source/Scripts/build_docs.sh"

DOCSET_DIR_NAME="com.apigee.documentation.ios_sdk.docset"
DOCSET_DIR_PATH="./source/build/DocSet/${DOCSET_DIR_NAME}"

# set our paths and file names
LIBRARY_BASE_NAME="apigee-ios"
FRAMEWORK_FILE_NAME="ApigeeiOSSDK.framework"
ZIP_BASE_NAME="${LIBRARY_BASE_NAME}-sdk"
ZIP_FILE_NAME="${ZIP_BASE_NAME}.zip"
TOPLEVEL_ZIP_DIR="zip"
DEST_ZIP_DIR="${TOPLEVEL_ZIP_DIR}/${LIBRARY_BASE_NAME}-sdk-${SDK_VERSION}"
BUILT_FRAMEWORK="source/build/framework/${FRAMEWORK_FILE_NAME}"
ZIP_LIB_DIR="${DEST_ZIP_DIR}/lib"

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

# remove any old DocSet that may exist
if [ -d ${DOCSET_DIR_PATH} ] ; then
  rm -r ${DOCSET_DIR_PATH}
  rmdir ${DOCSET_DIR_PATH}
fi

# generate docset
${BUILD_DOCS_COMMAND} ${DOCSET_DIR_PATH}

# zip directory exists?
if [ -d "${DEST_ZIP_DIR}" ]; then
	# erase all existing files there
	find "${DEST_ZIP_DIR}" -type f -exec rm {} \;
else
	mkdir -p "${DEST_ZIP_DIR}"
fi

# copy DocSet
if [ ! -d "${DOCSET_DIR_PATH}" ] ; then
	echo "Error: unable to find DocSet directory '${DOCSET_DIR_PATH}'"
  exit 1
else
  # copy DocSet to zip directory
  cp -R ${DOCSET_DIR_PATH} ${DEST_ZIP_DIR}
fi

# copy everything from repository
for entry in *
do
	if [ -f "$entry" ]; then
		cp "$entry" "${DEST_ZIP_DIR}"
	elif [ -d "$entry" ]; then
		if [ "$entry" != "${TOPLEVEL_ZIP_DIR}" ]; then
			cp -R "$entry" "${DEST_ZIP_DIR}"
		fi
	fi
done


# if we have source/build in zip directory, delete it and everything under it
if [ -d "${DEST_ZIP_DIR}/source/build" ]; then
	rm -rf ${DEST_ZIP_DIR}/source/build
	rmdir ${DEST_ZIP_DIR}/source/build
fi


# create directory for framework
mkdir -p "${ZIP_LIB_DIR}"

# copy framework to destination directory
cp -R "${BUILT_FRAMEWORK}" "${ZIP_LIB_DIR}"


# have build_release_zip.sh?
if [ -f "${DEST_ZIP_DIR}/build_release_zip.sh" ]; then
	# delete it
	rm "${DEST_ZIP_DIR}/build_release_zip.sh"
fi

# create the zip file
cd ${TOPLEVEL_ZIP_DIR} && zip -r -y ${ZIP_FILE_NAME} .

