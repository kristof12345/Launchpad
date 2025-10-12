# Security and Distribution Information

## App Signing and Notarization

### Current Status
- The app is code-signed with a free Apple Developer account
- App Sandbox is **disabled** to allow necessary system access
- The app is **not notarized** (requires paid Apple Developer account)

### Why App Sandbox is Disabled

LaunchPad requires extensive system access to function properly:
1. **Read System Directories**: Scans `/Applications` and `/System/Applications` to discover installed apps
2. **Launch Applications**: Uses `NSWorkspace` to open applications when clicked
3. **Access App Metadata**: Reads app icons, names, and bundle information
4. **File System Navigation**: Recursive directory traversal to find nested applications

With App Sandbox enabled and without proper entitlements, macOS Gatekeeper flags these operations as potentially malicious, resulting in the app being moved to trash on launch.

## First Launch on macOS

### Expected Behavior
When you first launch LaunchPad, macOS may show a security warning because the app is not notarized with Apple. This is normal for apps distributed outside the App Store without a paid developer account.

### How to Open LaunchPad

If macOS prevents you from opening the app, follow these steps:

#### Option 1: Right-Click Method (Recommended)
1. Locate `Launchpad.app` in your Applications folder
2. **Right-click** (or Control-click) on the app
3. Select **"Open"** from the context menu
4. Click **"Open"** in the security dialog
5. macOS will remember this choice for future launches

#### Option 2: System Settings Method
1. Try to open LaunchPad normally (it will be blocked)
2. Go to **System Settings** > **Privacy & Security**
3. Scroll down to the **Security** section
4. Click **"Open Anyway"** next to the LaunchPad message
5. Click **"Open"** in the confirmation dialog

#### Option 3: Terminal Method
```bash
xattr -cr /Applications/Launchpad.app
```

For more information, see Apple's official guide:
https://support.apple.com/guide/mac-help/mh40616/mac

### Why This Happens

Apple's Gatekeeper security system checks:
1. **Code Signature**: ✅ LaunchPad is properly signed
2. **Notarization**: ❌ Requires paid developer account ($99/year)
3. **App Sandbox**: ❌ Disabled due to system access requirements

Since the app is not notarized, macOS requires manual approval on first launch.

## Future Plans

If the project receives sufficient financial support, the developer may:
- Purchase a paid Apple Developer account
- Submit the app to Apple for notarization
- Potentially distribute through the Mac App Store

## Building from Source

If you build LaunchPad from source:
1. The app will use your own signing certificate
2. You may need to adjust the `DEVELOPMENT_TEAM` in the Xcode project
3. App Sandbox remains disabled for proper functionality
4. First launch will still require the steps above

## Privacy and Permissions

LaunchPad respects your privacy:
- **No Network Access**: The app does not connect to the internet
- **No Data Collection**: No analytics or telemetry
- **Local Only**: All data stored locally in UserDefaults
- **Read-Only Access**: Only reads app information, never modifies system files

## Questions or Concerns?

If you have security concerns or questions, please:
- Review the source code on GitHub
- Open an issue for discussion
- Contact the maintainer

**Note**: Always download LaunchPad from the official GitHub releases page to ensure you have the authentic version.
