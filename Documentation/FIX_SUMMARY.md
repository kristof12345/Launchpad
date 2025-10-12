# Fix for Gatekeeper Malware Warning Issue

## Issue Summary
**Problem**: Versions 1.4.1 and 1.5 of LaunchPad triggered macOS Gatekeeper malware warnings, causing the app to be moved to trash on launch. Version 1.4 did not have this issue.

**Affected OS**: macOS 15.6 Beta 2 and later

**User Report**: https://github.com/kristof12345/Launchpad/issues/[issue_number]

## Root Cause Analysis

### What Changed Between Versions
Between version 1.4 and 1.4.1/1.5, the Release build configuration was updated to enable App Sandbox:
- **v1.4**: `ENABLE_APP_SANDBOX = NO` (working)
- **v1.4.1/1.5**: `ENABLE_APP_SANDBOX = YES` (broken)

### Why This Caused Issues
1. **App Sandbox Enabled**: The Release build enabled macOS App Sandbox
2. **Empty Entitlements**: The `Launchpad.entitlements` file contained no permissions
3. **Required System Access**: LaunchPad needs to:
   - Read `/Applications` and `/System/Applications` directories
   - Launch other applications via `NSWorkspace`
   - Access app icons and bundle metadata
4. **Gatekeeper Response**: Without proper entitlements, these operations triggered Gatekeeper's malware detection

### The App Sandbox Dilemma
To properly use App Sandbox, the app would need entitlements like:
- `com.apple.security.files.user-selected.read-only` (not sufficient for system directories)
- `com.apple.security.files.bookmarks.app-scope` (doesn't work for scanning)
- Custom entitlements requiring notarization

However, notarization requires:
- Paid Apple Developer Program membership ($99/year)
- Which the maintainer doesn't currently have

## Solution Implemented

### The Fix
Changed the Release build configuration from:
```
ENABLE_APP_SANDBOX = YES;
```
to:
```
ENABLE_APP_SANDBOX = NO;
```

This matches the Debug configuration and restores the behavior from v1.4.

### Location
File: `Launchpad.xcodeproj/project.pbxproj`
Line: ~302 (in Release configuration section)

### Why This Is Safe
1. **Hardened Runtime Still Enabled**: `ENABLE_HARDENED_RUNTIME = YES` remains active
2. **Code Signing Intact**: App is still properly code-signed
3. **No Network Access**: App doesn't connect to the internet
4. **Read-Only Operations**: App only reads system files, never modifies them
5. **Historical Precedent**: v1.4 worked fine without sandboxing

## User Experience Impact

### Before Fix
1. Download and open LaunchPad v1.4.1 or v1.5
2. macOS shows "malware detected" warning
3. App automatically moved to trash
4. User cannot run the app without workarounds

### After Fix (v1.6+)
1. Download and open LaunchPad
2. macOS shows standard "unverified developer" warning (expected)
3. User right-clicks > Open > Open (one-time approval)
4. App runs normally on all future launches

### Still Required: Manual Approval
Users will still need to manually approve the app on first launch because:
- App is not notarized (requires paid developer account)
- This is standard macOS behavior for all non-App Store apps without notarization

## Documentation Added

### SECURITY.md
Comprehensive security documentation covering:
- Why App Sandbox is disabled
- App signing and notarization status
- How to handle security warnings
- Privacy assurances
- Future plans if funding is available

### README.md Updates
- Security note near download link
- Troubleshooting section for common issues
- Link to detailed security documentation

## Testing Recommendations

For the maintainer to test v1.6:
1. Build Release configuration
2. Export as macOS app
3. Move to a clean Mac (or use `sudo spctl --master-enable` to re-enable Gatekeeper)
4. Test first launch - should show "unverified developer" not "malware"
5. Right-click > Open should work successfully
6. Subsequent launches should work without warnings

## Alternative Solutions Considered

### Option 1: Add Proper Entitlements (Not Viable)
**Why Not**: Even with entitlements, scanning system directories requires notarization, which needs a paid account.

### Option 2: Request User to Select Folders (Poor UX)
**Why Not**: Would require users to manually select `/Applications` and `/System/Applications` every time, defeating the purpose of an automatic launcher.

### Option 3: Distribute via App Store (Future Goal)
**Why Not**: Requires paid developer account ($99/year) and App Store review process. Could be pursued if project gets funding.

### Option 4: Use Launch Services (Doesn't Solve Problem)
**Why Not**: Still requires read access to system directories to discover apps.

## Long-Term Recommendations

If the project receives funding:
1. Purchase Apple Developer Program membership ($99/year)
2. Enable App Sandbox with proper entitlements
3. Submit app for notarization
4. Consider App Store distribution for easier user access

## Commit Information
- **Commit**: [commit hash from report_progress]
- **Branch**: copilot/fix-app-launch-malware-warning
- **Files Changed**:
  - `Launchpad.xcodeproj/project.pbxproj` (1 line)
  - `Documentation/SECURITY.md` (new file)
  - `README.md` (security note + troubleshooting)
  - `.gitignore` (added *.backup)

## Related Resources
- [Apple Gatekeeper Documentation](https://support.apple.com/guide/security/gatekeeper-and-runtime-protection-sec5599b66df/web)
- [App Sandbox Overview](https://developer.apple.com/documentation/security/app_sandbox)
- [Notarizing macOS Software](https://developer.apple.com/documentation/security/notarizing_macos_software_before_distribution)
- [User Workaround Guide](https://support.apple.com/guide/mac-help/mh40616/mac)
