#!/bin/zsh

echo "🛠  Building Fn Key Toggle Menu Bar App..."

# .app bundle name
APP_NAME="FnToggle"
BUILD_DIR="Build"
APP_BUNDLE="${BUILD_DIR}/${APP_NAME}.app"
# Static bundle ID
BUNDLE_ID="com.github.ahmetbilall.fntoggle"

# Clean old files
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

# Create .app bundle structure
mkdir -p "${APP_BUNDLE}/Contents/MacOS"
mkdir -p "${APP_BUNDLE}/Contents/Resources"

# Create Info.plist
cat > "${APP_BUNDLE}/Contents/Info.plist" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>FnToggle</string>
    <key>CFBundleIdentifier</key>
    <string>${BUNDLE_ID}</string>
    <key>CFBundleName</key>
    <string>Fn Toggle</string>
    <key>CFBundleVersion</key>
    <string>1.0.0</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0.0</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>LSUIElement</key>
    <true/>
    <key>NSPrincipalClass</key>
    <string>NSApplication</string>
    <key>LSMinimumSystemVersion</key>
    <string>10.14</string>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
</dict>
</plist>
EOF

# Copy AppIcon.icns
if [ -f "Sources/Resources/AppIcon.icns" ]; then
    cp "Sources/Resources/AppIcon.icns" "${APP_BUNDLE}/Contents/Resources/"
else
    echo "⚠️  Warning: AppIcon.icns not found in Sources/Resources/"
fi

# Compile Swift files and put into .app bundle
swiftc \
    -framework Cocoa \
    -framework IOKit \
    Sources/Localizable.swift \
    Sources/FnStateManager.swift \
    Sources/FnKeyListener.swift \
    Sources/MenuBarApp.swift \
    Sources/main.swift \
    -o "${APP_BUNDLE}/Contents/MacOS/${APP_NAME}"

if [ $? -eq 0 ]; then
    echo "✅ Build successful! ${APP_BUNDLE}"
    
    # Refresh Finder cache for app icons
    echo "🔄 Refreshing Finder cache..."
    /System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f "${APP_BUNDLE}"

    # Ask user about removing quarantine attributes
    echo ""
    echo "⚠️  Remove quarantine attributes?"
    echo "   This removes a security layer from the app."
    echo "   Safe for your own builds, but should be done knowingly."
    echo "💡 If you choose No, you can remove later with: xattr -cr ${APP_BUNDLE}"
    echo -n "   Remove quarantine? (y/N): "
    read REPLY
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "🧹 Removing quarantine attributes..."
        if xattr -cr "${APP_BUNDLE}"; then
            echo "✅ Quarantine removed"
        else
            echo "⚠️  Could not remove quarantine attributes"
            echo "💡 Try manually: xattr -cr ${APP_BUNDLE}"
        fi
    else
        echo "ℹ️  Quarantine kept - app may show security warnings"
    fi
    
    echo "🚀 Run: open ${APP_BUNDLE}"
else
    echo "❌ Build failed!"
    exit 1
fi