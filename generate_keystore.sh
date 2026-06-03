#!/bin/bash
# ─── Apple.NET Keystore Generation Script ───
# Run this script to generate a release keystore for Google Play
# Usage: ./generate_keystore.sh

echo "=== Apple.NET Release Keystore Generator ==="
echo ""

# Read keystore details
read -p "Enter keystore file name (default: applenet-release-key.jks): " KEYSTORE_FILE
KEYSTORE_FILE=${KEYSTORE_FILE:-applenet-release-key.jks}

read -p "Enter key alias (default: applenet): " KEY_ALIAS
KEY_ALIAS=${KEY_ALIAS:-applenet}

read -sp "Enter keystore password: " STORE_PASS
echo ""
read -sp "Confirm keystore password: " STORE_PASS_CONFIRM
echo ""

if [ "$STORE_PASS" != "$STORE_PASS_CONFIRM" ]; then
    echo "Error: Passwords do not match!"
    exit 1
fi

read -sp "Enter key password: " KEY_PASS
echo ""
read -sp "Confirm key password: " KEY_PASS_CONFIRM
echo ""

if [ "$KEY_PASS" != "$KEY_PASS_CONFIRM" ]; then
    echo "Error: Key passwords do not match!"
    exit 1
fi

# Generate the keystore
echo ""
echo "Generating keystore..."
keytool -genkey -v \
    -keystore "$KEYSTORE_FILE" \
    -storepass "$STORE_PASS" \
    -alias "$KEY_ALIAS" \
    -keypass "$KEY_PASS" \
    -keyalg RSA \
    -keysize 2048 \
    -validity 10000 \
    -dname "CN=QTBM DEV, OU=Development, O=Apple.NET, L=Sanaa, ST=Sanaa, C=YE"

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Keystore generated successfully: $KEYSTORE_FILE"
    echo ""
    echo "Now create key.properties in the android/ folder with:"
    echo ""
    echo "storePassword=$STORE_PASS"
    echo "keyPassword=$KEY_PASS"
    echo "keyAlias=$KEY_ALIAS"
    echo "storeFile=../$KEYSTORE_FILE"
    echo ""
    echo "⚠️  IMPORTANT: Keep key.properties and the .jks file SECURE and NEVER commit them to version control!"
else
    echo "❌ Failed to generate keystore. Make sure keytool is installed (part of JDK)."
    exit 1
fi
