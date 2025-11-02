# 🛠️ Troubleshooting Guide

This guide helps you resolve common issues with LaunchpadPlus.

## 🔒 macOS Security & Gatekeeper Issues

### "LaunchpadPlus is malware" or moved to Trash

**Problem:** When opening LaunchpadPlus, macOS displays a warning that the app is malware and moves it to the Trash. You cannot find the "Open Anyway" option in System Settings > Privacy & Security.

**Why this happens:** LaunchpadPlus is not code-signed and notarized by Apple. macOS Gatekeeper blocks unsigned applications as a security measure starting with macOS Catalina (10.15) and newer versions.

#### Solution 1: Remove Quarantine Attribute (Recommended)

This is the safest and most reliable method:

1. **Download LaunchpadPlus** and move it to your Applications folder
2. **Open Terminal** (found in Applications > Utilities)
3. **Run this command:**
   ```bash
   xattr -cr /Applications/LaunchpadPlus.app
   ```
4. **Launch the app** - it should now open without issues

**What this does:** The `-cr` flags remove the quarantine attribute that macOS adds to downloaded files, allowing the app to run.

#### Solution 2: Right-Click Method

If Solution 1 doesn't work, try this:

1. **Move LaunchpadPlus** to Applications folder
2. **Right-click (or Control-click)** on LaunchpadPlus.app
3. **Select "Open"** from the context menu
4. **Click "Open"** in the security dialog that appears

This method creates a security exception for this specific app.

#### Solution 3: Disable Gatekeeper Temporarily (Not Recommended)

⚠️ **Warning:** This reduces your Mac's security. Only use this as a last resort and re-enable Gatekeeper afterward.

1. **Open Terminal**
2. **Disable Gatekeeper:**
   ```bash
   sudo spctl --master-disable
   ```
3. **Enter your password** when prompted
4. **Open LaunchpadPlus** from Applications
5. **Re-enable Gatekeeper immediately after:**
   ```bash
   sudo spctl --master-enable
   ```

#### Solution 4: Check Security Settings

Sometimes the "Open Anyway" button appears after the first attempt:

1. **Try to open LaunchpadPlus** - it will be blocked
2. **Immediately go to** System Settings > Privacy & Security
3. **Scroll down** to the Security section
4. **Look for a message** about LaunchpadPlus being blocked
5. **Click "Open Anyway"** if the button appears

### Verifying the Fix

After applying any solution, verify it worked:

1. Close Terminal and any open apps
2. Double-click LaunchpadPlus from Applications
3. The app should launch without warnings

### Why Isn't LaunchpadPlus Signed?

Code signing and notarization require:
- An Apple Developer account ($99/year)
- Complex build and distribution processes
- Ongoing maintenance for certificate renewals

As an open-source project, LaunchpadPlus prioritizes accessibility and transparency. All source code is available on GitHub for security review.

### Is It Safe?

Yes, if downloaded from official sources:
- ✅ **Official GitHub Releases:** https://github.com/kristof12345/Launchpad/releases
- ✅ **Project Website:** Via official download links
- ❌ **Third-party sites:** Avoid downloading from unofficial sources

You can verify safety by:
1. Building from source yourself (see CONTRIBUTING.md)
2. Reviewing the code on GitHub
3. Checking community discussions and reviews

## 🚀 Performance Issues

### App Launches Slowly

**Solutions:**
- Reduce the number of items per page in Settings
- Clear app cache by removing saved layouts (Settings > Actions > Reset Layout)
- Restart LaunchpadPlus

### Animations Are Laggy

**Solutions:**
- Reduce icon size in Settings
- Decrease number of columns/rows per page
- Check Activity Monitor for high CPU usage from other apps

## 🔍 Search Not Working

### Search Doesn't Find Apps

**Solutions:**
- Verify apps are installed in `/Applications` or `/System/Applications`
- Restart LaunchpadPlus to refresh app list
- Check if app name matches what you're typing

### Search Is Slow

**Solutions:**
- Reduce total number of apps by hiding system utilities
- Clear search cache (restart app)

## 📁 Folder Issues

### Can't Create Folders

**Solutions:**
- Make sure you're dragging one app icon onto another app icon
- Try holding the drag for 1-2 seconds before releasing
- Check Settings > Features > Drop Delay isn't too short

### Apps Disappear from Folders

**Solutions:**
- This happens if you drag an app out of the folder boundaries
- Use Settings > Actions > Import Layout to restore from backup
- Manually re-add apps to the folder

## ⚙️ Settings Not Saving

### Changes Reset After Restart

**Solutions:**
- Check file permissions on `~/Library/Preferences`
- Clear preferences and reconfigure:
  ```bash
  defaults delete waikiki.program.Launchpad
  ```
- Reinstall LaunchpadPlus

## 🖥️ Display Issues

### App Window Doesn't Fill Screen

**Solutions:**
- This is normal - LaunchpadPlus uses your screen's full resolution
- Check display settings in System Settings > Displays
- Try disconnecting/reconnecting external displays

### Wrong Screen on Multi-Monitor Setup

**Solutions:**
- LaunchpadPlus appears on the screen with the active window
- Click on the target screen before launching
- Configure in System Settings > Displays > Arrangement

## 🔄 Update Issues

### "Update Available" Keeps Appearing

**Solutions:**
- Download and install the latest version from GitHub releases
- Clear update cache by removing app preferences
- Ignore update notifications if you prefer your current version

## 📝 Getting More Help

If none of these solutions work:

1. **Check GitHub Issues:** https://github.com/kristof12345/Launchpad/issues
2. **Search existing issues** for similar problems
3. **Create a new issue** with:
   - macOS version (About This Mac)
   - LaunchpadPlus version
   - Detailed description of the problem
   - Steps to reproduce
   - Screenshots if applicable

## 🔧 Advanced Troubleshooting

### Reset All Settings

```bash
# Remove all LaunchpadPlus preferences
defaults delete waikiki.program.Launchpad

# Remove quarantine from app
xattr -cr /Applications/LaunchpadPlus.app

# Restart LaunchpadPlus
```

### Check App Permissions

```bash
# View current attributes
xattr -l /Applications/LaunchpadPlus.app

# List permissions
ls -la@ /Applications/LaunchpadPlus.app
```

### Enable Debug Mode

LaunchpadPlus doesn't currently have a debug mode, but you can:
1. Build from source with debugging enabled
2. Monitor Console.app for LaunchpadPlus logs
3. Check crash reports in `~/Library/Logs/DiagnosticReports`

## 📚 Additional Resources

- **README:** Installation and basic usage
- **CONTRIBUTING:** Building from source
- **GitHub Discussions:** Community support
- **Website:** https://kristof12345.github.io/Launchpad/
