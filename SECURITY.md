# 🔒 Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 3.0.x   | ✅ Current release |
| 2.7.x   | ✅ Security fixes  |
| < 2.7   | ❌ No longer supported |

## Code Signing & Notarization

### Current Status

LaunchpadPlus is currently **not code-signed or notarized** by Apple. This means:

- ✅ **Source code is fully transparent** and available on GitHub
- ✅ **Safe to use** when downloaded from official sources
- ⚠️ **macOS Gatekeeper warnings** will appear on first launch
- ⚠️ **Manual security approval** required from users

### Why Not Sign & Notarize?

Code signing and notarization require:
- Apple Developer Program membership ($99 USD/year)
- Maintaining certificates and provisioning profiles
- Complex build and distribution infrastructure
- Ongoing certificate renewals and maintenance

As an open-source, community-driven project, we prioritize:
- **Transparency:** All code is public and auditable
- **Accessibility:** Free to use without licensing restrictions
- **Community trust:** Security through code review, not certificates

### Future Plans

We are exploring options to provide signed releases:
- Community-funded developer account
- Automated signing in CI/CD pipelines
- Alternative distribution methods (Homebrew, etc.)

If you'd like to contribute toward code signing costs, see our [funding page](https://www.buymeacoffee.com/Waikiki.com).

## Building Signed Versions Yourself

If you need a properly signed version for your organization:

### Prerequisites

1. **Apple Developer Account** - Sign up at https://developer.apple.com
2. **Developer ID Certificate** - Create in Xcode or Developer Portal
3. **Xcode 15.0+** - Install from Mac App Store

### Signing Steps

1. **Clone the repository:**
   ```bash
   git clone https://github.com/kristof12345/Launchpad.git
   cd Launchpad
   ```

2. **Open in Xcode:**
   ```bash
   open LaunchpadPlus.xcodeproj
   ```

3. **Configure Signing:**
   - Select the LaunchpadPlus target
   - Go to "Signing & Capabilities" tab
   - Check "Automatically manage signing"
   - Select your Team from the dropdown
   - Verify the bundle identifier is unique to you

4. **Build for Release:**
   ```bash
   xcodebuild archive \
     -project LaunchpadPlus.xcodeproj \
     -scheme LaunchpadPlus \
     -configuration Release \
     -archivePath ./build/LaunchpadPlus.xcarchive
   ```

5. **Export the Archive:**
   - Open the Organizer in Xcode (Window > Organizer)
   - Select your archive
   - Click "Distribute App"
   - Choose "Developer ID"
   - Follow the prompts to sign and export

### Notarization (Optional but Recommended)

Notarization removes the need for users to bypass Gatekeeper:

1. **Create an App-Specific Password:**
   - Go to https://appleid.apple.com
   - Generate app-specific password
   - Save it securely

2. **Store credentials:**
   ```bash
   xcrun notarytool store-credentials "notarization-profile" \
     --apple-id "your-apple-id@example.com" \
     --team-id "YOUR_TEAM_ID" \
     --password "app-specific-password"
   ```

3. **Submit for notarization:**
   ```bash
   xcrun notarytool submit LaunchpadPlus.app.zip \
     --keychain-profile "notarization-profile" \
     --wait
   ```

4. **Staple the ticket:**
   ```bash
   xcrun stapler staple LaunchpadPlus.app
   ```

### Automated Signing in CI/CD

For organizations wanting automated builds:

```yaml
# Example GitHub Actions workflow
- name: Import Certificates
  uses: apple-actions/import-codesign-certs@v1
  with:
    p12-file-base64: ${{ secrets.CERTIFICATES_P12 }}
    p12-password: ${{ secrets.CERTIFICATES_PASSWORD }}

- name: Build and Sign
  run: |
    xcodebuild archive \
      -project LaunchpadPlus.xcodeproj \
      -scheme LaunchpadPlus \
      -configuration Release \
      -archivePath ./build/LaunchpadPlus.xcarchive \
      CODE_SIGN_IDENTITY="${{ secrets.CODE_SIGN_IDENTITY }}" \
      DEVELOPMENT_TEAM="${{ secrets.TEAM_ID }}"
```

## Security Best Practices

### For Users

1. **Download from official sources only:**
   - ✅ GitHub Releases: https://github.com/kristof12345/Launchpad/releases
   - ✅ Official Website: Via documented links
   - ❌ Third-party websites, torrents, or unofficial sources

2. **Verify downloads:**
   - Check the release notes on GitHub
   - Compare file sizes with official releases
   - Review recent issues for security reports

3. **Remove quarantine safely:**
   ```bash
   xattr -cr /Applications/LaunchpadPlus.app
   ```
   This is safe and doesn't compromise macOS security for other apps.

4. **Keep updated:**
   - Watch the repository for new releases
   - Check the changelog for security fixes
   - Update promptly when patches are released

5. **Review permissions:**
   - LaunchpadPlus requires minimal permissions
   - It only reads from `/Applications` folders
   - No network access or background services

### For Developers

1. **Code review all contributions:**
   - All PRs require review before merging
   - Check for suspicious code patterns
   - Verify external dependencies

2. **Dependency management:**
   - Minimize external dependencies
   - Review dependency security advisories
   - Keep dependencies updated

3. **Secure coding practices:**
   - Use Swift's memory safety features
   - Avoid force unwrapping optionals
   - Validate all user inputs
   - Follow Apple's Secure Coding Guide

4. **Testing:**
   - Write security-focused tests
   - Test edge cases and error conditions
   - Verify sandboxing limitations

## Reporting a Vulnerability

We take security seriously. If you discover a vulnerability:

### Please DO:

1. **Email the maintainer directly:** kristof12345@github (via GitHub)
2. **Provide detailed information:**
   - Description of the vulnerability
   - Steps to reproduce
   - Potential impact
   - Suggested fixes (if any)
3. **Allow time for a fix:**
   - We aim to respond within 48 hours
   - Allow 90 days for a patch before public disclosure
4. **Coordinate disclosure:**
   - Work with us on timing
   - We'll credit you in release notes (if desired)

### Please DON'T:

- ❌ Open a public GitHub issue for security vulnerabilities
- ❌ Share exploits publicly before a fix is available
- ❌ Attempt to exploit vulnerabilities on systems you don't own

### What to Expect:

1. **Acknowledgment** within 48 hours
2. **Initial assessment** within 1 week
3. **Fix timeline** communicated
4. **Coordinated disclosure** when patch is ready
5. **Public credit** in release notes (optional)

## Security Audit Trail

### Known Security Considerations

1. **Unsigned/Unnotarized:**
   - Status: Known limitation
   - Mitigation: Users must manually approve
   - Future: Exploring funding for signing

2. **File System Access:**
   - Required: Read access to `/Applications`
   - Mitigation: No write access required
   - Sandboxing: Disabled to allow app launching

3. **No App Sandbox:**
   - Reason: Required to launch other applications
   - Mitigation: Minimal permissions requested
   - Alternative: Hardened Runtime is enabled

### Past Security Issues

No security vulnerabilities have been reported to date.

## Hardened Runtime

LaunchpadPlus uses Apple's Hardened Runtime to improve security:

- ✅ **Code injection protection:** Prevents runtime code modification
- ✅ **Library validation:** Ensures only trusted libraries load
- ✅ **Memory protection:** Enhanced security for memory operations
- ✅ **Debugger protection:** Limits debugging capabilities

Configured in `Launchpad.entitlements`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <!-- Entitlements configured for Hardened Runtime -->
</dict>
</plist>
```

## Privacy Policy

LaunchpadPlus:
- ✅ Does **NOT** collect any user data
- ✅ Does **NOT** connect to the internet
- ✅ Does **NOT** send analytics or telemetry
- ✅ Stores preferences only locally in `~/Library/Preferences`
- ✅ Does **NOT** access files outside `/Applications`

## Compliance

- **GDPR:** Not applicable (no data collection)
- **CCPA:** Not applicable (no data collection)
- **SOC 2:** Not applicable (no services/data storage)

## Resources

- **Apple Security Guide:** https://developer.apple.com/security/
- **Secure Coding Guide:** https://developer.apple.com/library/archive/documentation/Security/Conceptual/SecureCodingGuide/
- **Hardened Runtime:** https://developer.apple.com/documentation/security/hardened_runtime
- **Notarization:** https://developer.apple.com/documentation/security/notarizing_macos_software_before_distribution

## Contact

- **Security Issues:** Contact maintainer via GitHub
- **General Questions:** Open a GitHub Discussion
- **Project Issues:** Open a GitHub Issue

---

*Last Updated: January 2025*
