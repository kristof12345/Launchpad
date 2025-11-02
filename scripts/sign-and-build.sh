#!/bin/bash
# Build and Sign LaunchpadPlus for Distribution
#
# This script helps you build a properly signed and optionally notarized
# version of LaunchpadPlus that can be distributed without Gatekeeper warnings.
#
# Prerequisites:
# - Apple Developer Account (https://developer.apple.com)
# - Developer ID Application certificate installed
# - Xcode Command Line Tools
#
# Usage:
#   ./scripts/sign-and-build.sh [options]
#
# Options:
#   --notarize      Submit for notarization (requires Apple ID credentials)
#   --help          Show this help message
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PROJECT_NAME="LaunchpadPlus"
PROJECT_FILE="LaunchpadPlus.xcodeproj"
SCHEME="LaunchpadPlus"
CONFIGURATION="Release"
BUILD_DIR="./build"
ARCHIVE_PATH="$BUILD_DIR/$PROJECT_NAME.xcarchive"
EXPORT_PATH="$BUILD_DIR/export"
ZIP_NAME="$PROJECT_NAME-signed.zip"

# Parse command line arguments
NOTARIZE=false
for arg in "$@"; do
    case $arg in
        --notarize)
            NOTARIZE=true
            shift
            ;;
        --help)
            echo "Usage: $0 [--notarize] [--help]"
            echo ""
            echo "Options:"
            echo "  --notarize      Submit for notarization (requires Apple ID credentials)"
            echo "  --help          Show this help message"
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $arg${NC}"
            exit 1
            ;;
    esac
done

echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  LaunchpadPlus - Build and Sign Script${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo ""

# Check prerequisites
echo -e "${YELLOW}Checking prerequisites...${NC}"

if ! command -v xcodebuild &> /dev/null; then
    echo -e "${RED}Error: xcodebuild not found. Please install Xcode Command Line Tools.${NC}"
    exit 1
fi

if [ ! -d "$PROJECT_FILE" ]; then
    echo -e "${RED}Error: $PROJECT_FILE not found. Run this script from the repository root.${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Prerequisites satisfied${NC}"
echo ""

# Check for Developer ID certificate
echo -e "${YELLOW}Checking for Developer ID certificate...${NC}"
CERT_COUNT=$(security find-identity -v -p codesigning | grep "Developer ID Application" | wc -l)
if [ $CERT_COUNT -eq 0 ]; then
    echo -e "${RED}Error: No 'Developer ID Application' certificate found.${NC}"
    echo -e "${YELLOW}Please install a Developer ID certificate from https://developer.apple.com${NC}"
    exit 1
fi

# List available certificates
echo -e "${GREEN}Found Developer ID certificate(s):${NC}"
security find-identity -v -p codesigning | grep "Developer ID Application"
echo ""

# Prompt for Team ID
read -p "Enter your Team ID (e.g., ABCD123456): " TEAM_ID
if [ -z "$TEAM_ID" ]; then
    echo -e "${RED}Error: Team ID is required${NC}"
    exit 1
fi

# Clean previous build
echo -e "${YELLOW}Cleaning previous builds...${NC}"
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"
echo -e "${GREEN}✓ Build directory cleaned${NC}"
echo ""

# Build and Archive
echo -e "${YELLOW}Building and archiving $PROJECT_NAME...${NC}"
xcodebuild archive \
    -project "$PROJECT_FILE" \
    -scheme "$SCHEME" \
    -configuration "$CONFIGURATION" \
    -archivePath "$ARCHIVE_PATH" \
    -destination 'platform=macOS' \
    DEVELOPMENT_TEAM="$TEAM_ID" \
    CODE_SIGN_STYLE=Automatic

echo -e "${GREEN}✓ Archive created successfully${NC}"
echo ""

# Create export options plist
echo -e "${YELLOW}Creating export options...${NC}"
cat > "$BUILD_DIR/ExportOptions.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>developer-id</string>
    <key>teamID</key>
    <string>$TEAM_ID</string>
    <key>signingStyle</key>
    <string>automatic</string>
</dict>
</plist>
EOF

# Export Archive
echo -e "${YELLOW}Exporting signed application...${NC}"
xcodebuild -exportArchive \
    -archivePath "$ARCHIVE_PATH" \
    -exportPath "$EXPORT_PATH" \
    -exportOptionsPlist "$BUILD_DIR/ExportOptions.plist"

echo -e "${GREEN}✓ Application exported and signed${NC}"
echo ""

# Verify signature
echo -e "${YELLOW}Verifying code signature...${NC}"
codesign -dvv "$EXPORT_PATH/$PROJECT_NAME.app" 2>&1 | grep -E "Authority|TeamIdentifier|Identifier"
echo ""
spctl -a -vv "$EXPORT_PATH/$PROJECT_NAME.app"
echo -e "${GREEN}✓ Code signature verified${NC}"
echo ""

# Notarization (if requested)
if [ "$NOTARIZE" = true ]; then
    echo -e "${YELLOW}Preparing for notarization...${NC}"
    
    # Create ZIP for notarization
    cd "$EXPORT_PATH"
    zip -r "../../$ZIP_NAME" "$PROJECT_NAME.app"
    cd ../..
    
    echo -e "${YELLOW}Submitting for notarization...${NC}"
    echo -e "${BLUE}For security, notarytool requires stored credentials in keychain.${NC}"
    echo -e "${BLUE}If you haven't set up a profile, run this first:${NC}"
    echo ""
    echo -e "${BLUE}  xcrun notarytool store-credentials \"notarization-profile\" \\${NC}"
    echo -e "${BLUE}    --apple-id \"your@email.com\" \\${NC}"
    echo -e "${BLUE}    --team-id \"YOUR_TEAM_ID\" \\${NC}"
    echo -e "${BLUE}    --password \"app-specific-password\"${NC}"
    echo ""
    echo -e "${YELLOW}Create app-specific password at: https://appleid.apple.com${NC}"
    echo ""
    
    # Check if profile exists by querying notarization history
    # Note: We use 'notarytool history' as a lightweight check. If it fails, it could mean
    # the profile doesn't exist OR there are network/auth issues. Either way,
    # the user needs to set up or refresh credentials.
    echo -e "${YELLOW}Verifying keychain profile...${NC}"
    if ! xcrun notarytool history --keychain-profile "notarization-profile" &>/dev/null; then
        echo -e "${RED}Error: Cannot access keychain profile 'notarization-profile'.${NC}"
        echo -e "${YELLOW}This could mean:${NC}"
        echo -e "${YELLOW}  1. Profile doesn't exist (most common)${NC}"
        echo -e "${YELLOW}  2. Network connectivity issues${NC}"
        echo -e "${YELLOW}  3. Credentials need to be refreshed${NC}"
        echo ""
        echo -e "${YELLOW}Please run the command above to store/update your credentials.${NC}"
        exit 1
    fi
    echo -e "${GREEN}✓ Keychain profile verified${NC}"
    echo ""
    
    # Submit for notarization using keychain profile
    echo -e "${YELLOW}Submitting to Apple (this may take several minutes)...${NC}"
    xcrun notarytool submit "$ZIP_NAME" \
        --keychain-profile "notarization-profile" \
        --wait
    
    # Staple the ticket
    echo -e "${YELLOW}Stapling notarization ticket...${NC}"
    xcrun stapler staple "$EXPORT_PATH/$PROJECT_NAME.app"
    
    # Re-create ZIP with stapled app
    rm "$ZIP_NAME"
    cd "$EXPORT_PATH"
    zip -r "../../$ZIP_NAME" "$PROJECT_NAME.app"
    cd ../..
    
    echo -e "${GREEN}✓ Notarization complete and ticket stapled${NC}"
    echo ""
else
    # Create ZIP without notarization
    cd "$EXPORT_PATH"
    zip -r "../../$ZIP_NAME" "$PROJECT_NAME.app"
    cd ../..
fi

# Calculate checksum
echo -e "${YELLOW}Calculating checksum...${NC}"
shasum -a 256 "$ZIP_NAME" > "$ZIP_NAME.sha256"
CHECKSUM=$(cat "$ZIP_NAME.sha256")
echo -e "${GREEN}$CHECKSUM${NC}"
echo ""

# Summary
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✓ Build complete!${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${GREEN}Signed application:${NC} $EXPORT_PATH/$PROJECT_NAME.app"
echo -e "${GREEN}Distribution ZIP:${NC} $ZIP_NAME"
echo -e "${GREEN}Checksum file:${NC} $ZIP_NAME.sha256"
echo ""

if [ "$NOTARIZE" = true ]; then
    echo -e "${GREEN}✓ Application is signed and notarized${NC}"
    echo -e "${BLUE}Users can install this without any security warnings.${NC}"
else
    echo -e "${YELLOW}⚠ Application is signed but NOT notarized${NC}"
    echo -e "${BLUE}Users will still need to allow it in System Settings.${NC}"
    echo -e "${BLUE}To notarize, run: $0 --notarize${NC}"
fi

echo ""
echo -e "${BLUE}Distribution instructions:${NC}"
echo -e "  1. Upload $ZIP_NAME to your distribution channel"
echo -e "  2. Share the SHA-256 checksum for verification"
echo -e "  3. Users can verify with: shasum -c $ZIP_NAME.sha256"
echo ""
