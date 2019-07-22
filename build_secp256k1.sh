#!/bin/sh
set -ex

if [ $# -ne 2 ]; then
    echo "Usage: sh $0 [iphoneos|iphonesimulator] [arm64|armv7s|armv7|x86_64|i386]" 1>&2
    exit 1
fi

TDIR=`mktemp -d`
trap "{ cd - ; rm -rf $TDIR; exit 255; }" SIGINT

CURRENTPATH="`pwd`"
SDK=$1
ARCH=$2
TARGETDIR="$CURRENTPATH/$SDK/$ARCH"
HOST=""

echo "Build secp256k1 in $TARGETDIR"

if [ "$SDK" = "iphoneos" ]; then
    HOST="arm-apple-darwin"
elif [ "$SDK" = "iphonesimulator" ]; then
    HOST="x86_64-apple-darwin"
else
    echo "Unknown arch: $ARCH"
    exit 1
fi;

cp -R * $TDIR
cd $TDIR

PLATFORM="`xcrun -sdk $SDK --show-sdk-platform-path`"
SDK_PATH="`xcrun -sdk $SDK --show-sdk-path`"

./configure --enable-module-recovery --libdir="$TARGETDIR" --host="$HOST" \
    CC=`xcrun -find clang` \
    CFLAGS="-O3 -arch $ARCH -isysroot $SDK_PATH -fembed-bitcode -miphoneos-version-min=9.0" \
    CXX=`xcrun -find clang++` \
    CXXFLAGS="-O3 -n -arch $ARCH -isysroot $SDK_PATH -fembed-bitcode -miphoneos-version-min=9.0"
make install

cd -
rm -rf $TDIR
