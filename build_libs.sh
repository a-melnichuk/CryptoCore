#!/bin/sh
set -ex

OPENSSL_VERSION=1.1.0g
SCRIPT_DIR=`pwd`
LIB_DIR=".libs"
LIB_PATH="$SCRIPT_DIR/$LIB_DIR"

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

ios_secp256k1_build() {
    LIB_NAME="secp256k1"
    LIB="$LIB_PATH/.$LIB_NAME"

    title "$LIB_NAME"
    rm -rf "$LIB"
    git clone https://melnichukal2@bitbucket.org/melnichukal2/secp256k1-extended.git "$LIB"
    cd "$LIB"
    ./autogen.sh

    PIDS=""
    sh "$SCRIPT_DIR/build_$LIB_NAME.sh" iphoneos arm64 &
    PIDS+=" $!"
    sh "$SCRIPT_DIR/build_$LIB_NAME.sh" iphoneos armv7s &
    PIDS+=" $!"
    sh "$SCRIPT_DIR/build_$LIB_NAME.sh" iphoneos armv7 &
    PIDS+=" $!"
    sh "$SCRIPT_DIR/build_$LIB_NAME.sh" iphonesimulator x86_64 &
    PIDS+=" $!"
    sh "$SCRIPT_DIR/build_$LIB_NAME.sh" iphonesimulator i386 &
    PIDS+=" $!"

    echo "Waiting for $LIB_NAME processes: $PIDS"
    for p in $PIDS; do
        if wait $p; then
            echo "$LIB_NAME process $p succeeded"
        else
            echo "(!) $LIB_NAME $p failed"
        exit 1
        fi
    done

    echo "After $LIB_NAME processes"

    xcrun lipo -create \
        "$LIB/iphoneos/arm64/lib$LIB_NAME.a" \
        "$LIB/iphoneos/armv7s/lib$LIB_NAME.a" \
        "$LIB/iphoneos/armv7/lib$LIB_NAME.a" \
        "$LIB/iphonesimulator/x86_64/lib$LIB_NAME.a" \
        "$LIB/iphonesimulator/i386/lib$LIB_NAME.a" \
        -o "$SCRIPT_DIR/CryptoCore/Sources/libs/$LIB_NAME/lib$LIB_NAME.a"

    cd "$LIB_PATH"
    rm -rf "$LIB"
}

ios_openssl_build() {
    LIB_NAME="openssl"
    LIB="$LIB_PATH/.$LIB_NAME"
    PIDS=""

    title "$LIB_NAME"

    rm -rf openssl-$OPENSSL_VERSION openssl-$OPENSSL_VERSION.tar.gz
    curl -O https://www.openssl.org/source/openssl-$OPENSSL_VERSION.tar.gz
    tar zxf openssl-$OPENSSL_VERSION.tar.gz

    sh "$SCRIPT_DIR/build_$LIB_NAME.sh" iphoneos arm64 openssl-$OPENSSL_VERSION &
    PIDS+=" $!"
    sh "$SCRIPT_DIR/build_$LIB_NAME.sh" iphoneos armv7s openssl-$OPENSSL_VERSION &
    PIDS+=" $!"
    sh "$SCRIPT_DIR/build_$LIB_NAME.sh" iphoneos armv7 openssl-$OPENSSL_VERSION &
    PIDS+=" $!"
    sh "$SCRIPT_DIR/build_$LIB_NAME.sh" iphonesimulator x86_64 openssl-$OPENSSL_VERSION &
    PIDS+=" $!"
    sh "$SCRIPT_DIR/build_$LIB_NAME.sh" iphonesimulator i386 openssl-$OPENSSL_VERSION &
    PIDS+=" $!"

    echo "Waiting for $LIB_NAME processes: $PIDS"
        for p in $PIDS; do
        if wait $p; then
            echo "$LIB_NAME process $p succeeded"
        else
            echo "(!) $LIB_NAME $p failed"
            exit 1
        fi
    done

    echo "After $LIB_NAME processes"

    xcrun lipo -create \
        "$LIB/iphoneos/arm64/libcrypto.a" \
        "$LIB/iphoneos/armv7s/libcrypto.a" \
        "$LIB/iphoneos/armv7/libcrypto.a" \
        "$LIB/iphonesimulator/x86_64/libcrypto.a" \
        "$LIB/iphonesimulator/i386/libcrypto.a" \
        -o "$SCRIPT_DIR/CryptoCore/Sources/libs/$LIB_NAME/libcrypto.a"

    cd "$LIB_PATH"
    rm -rf "$LIB"
    rm -rf openssl-$OPENSSL_VERSION openssl-$OPENSSL_VERSION.tar.gz
}

trap "{ cd - ; rm -rf $LIB_DIR; exit 255; }" SIGINT
mkdir -p "$LIB_DIR"
cd "$LIB_DIR"

ios_openssl_build
ios_secp256k1_build

cd "$SCRIPT_DIR"
rm -rf "$LIB_DIR"
