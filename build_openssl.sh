#!/bin/sh
set -ex

if [ $# -ne 3 ]; then
    echo "Usage: sh $0 [iphoneos|iphonesimulator] [arm64|armv7s|armv7|x86_64|i386]" 1>&2
    exit 1
fi

TDIR=`mktemp -d`
trap "{ cd - ; rm -rf $TDIR; exit 255; }" SIGINT

CURRENTPATH="`pwd`"
SDK=$1
ARCH=$2
OPENSSL_FOLDER=$3

cp -R $OPENSSL_FOLDER/* $TDIR
cd $TDIR


echo "Start build in path $CURRENTPATH/$TDIR"

PLATFORM="`xcrun -sdk $SDK --show-sdk-platform-path`"
SDK_PATH="`xcrun -sdk $SDK --show-sdk-path`"

export CROSS_TOP="$PLATFORM/Developer"
export CROSS_SDK="`basename $SDK_PATH`"
export BUILD_TOOLS="`xcode-select --print-path`"
export CC="`xcrun -find gcc` -arch $ARCH -isysroot $SDK_PATH -Wno-ignored-optimization-argument"

TARGETDIR="$CURRENTPATH/.openssl/$SDK/$ARCH"
mkdir -p "$TARGETDIR"

./Configure iphoneos-cross no-shared no-dso no-hw no-engine no-ssl3 no-comp no-idea no-asm no-dtls no-dtls1 no-threads no-err no-psk no-srp no-ec2m no-weak-ssl-ciphers -fembed-bitcode -miphoneos-version-min=8.0

make clean
make depend
make build_libs

cp libcrypto.a "$TARGETDIR/libcrypto.a"

cd -
rm -rf $TDIR

exit 0
