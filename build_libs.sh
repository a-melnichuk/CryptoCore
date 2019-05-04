#!/bin/sh
set -ex

OPENSSL_VERSION=1.1.0g
SCRIPT_DIR=`pwd`

title() {
    len=${#1}
    full_len=`echo $len+10 | bc`
    echo "\n"
    seq -s* $full_len|tr -d '[:digit:]'
    echo ""
    echo "*    $1    *"
    seq -s* $full_len|tr -d '[:digit:]'
    echo "\n"
}

ios_openssl_build() {

    PIDS=""

    title "openssl"

    rm -rf openssl-$OPENSSL_VERSION openssl-$OPENSSL_VERSION.tar.gz
    curl -O https://www.openssl.org/source/openssl-$OPENSSL_VERSION.tar.gz
    tar zxf openssl-$OPENSSL_VERSION.tar.gz

#    cd openssl-$OPENSSL_VERSION

#    sh "$SCRIPT_DIR/build_openssl.sh" iphoneos arm64
#    sh "$SCRIPT_DIR/build_openssl.sh" iphoneos armv7s
#    sh "$SCRIPT_DIR/build_openssl.sh" iphoneos armv7
#    sh "$SCRIPT_DIR/build_openssl.sh" iphonesimulator x86_64
#    sh "$SCRIPT_DIR/build_openssl.sh" iphonesimulator i386

    sh "$SCRIPT_DIR/build_openssl.sh" iphoneos arm64 openssl-$OPENSSL_VERSION &
    PIDS+=" $!"
    sh "$SCRIPT_DIR/build_openssl.sh" iphoneos armv7s openssl-$OPENSSL_VERSION &
    PIDS+=" $!"
    sh "$SCRIPT_DIR/build_openssl.sh" iphoneos armv7 openssl-$OPENSSL_VERSION &
    PIDS+=" $!"
    sh "$SCRIPT_DIR/build_openssl.sh" iphonesimulator x86_64 openssl-$OPENSSL_VERSION &
    PIDS+=" $!"
    sh "$SCRIPT_DIR/build_openssl.sh" iphonesimulator i386 openssl-$OPENSSL_VERSION &
    PIDS+=" $!"

    echo "Waiting for openssl processes: $PIDS"
        for p in $PIDS; do
        if wait $p; then
            echo "openssl process $p succeeded"
        else
            echo "(!) openssl $p failed"
            exit 1
        fi
    done

    echo "After openssl processes"

    xcrun lipo -create \
        .openssl/iphoneos/arm64/libcrypto.a \
        .openssl/iphoneos/armv7s/libcrypto.a \
        .openssl/iphoneos/armv7/libcrypto.a \
        .openssl/iphonesimulator/x86_64/libcrypto.a \
        .openssl/iphonesimulator/i386/libcrypto.a \
    -o "$SCRIPT_DIR/CryptoCore/Sources/libs/openssl/libcrypto.a"

    rm -rf .openssl
    rm -rf openssl-$OPENSSL_VERSION openssl-$OPENSSL_VERSION.tar.gz
}

trap "{ cd - ; rm -rf .libs; exit 255; }" SIGINT
mkdir -p .libs
cd .libs

ios_openssl_build

cd -

