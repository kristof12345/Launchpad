# Build and Release Scripts

This directory contains scripts for building, signing, and distributing LaunchpadPlus.

## Available Scripts

### `sign-and-build.sh`

Builds a code-signed version of LaunchpadPlus that can be distributed without Gatekeeper warnings.

**Prerequisites:**
- Apple Developer Account
- Developer ID Application certificate
- Xcode Command Line Tools

**Usage:**

Build and sign (without notarization):
```bash
./scripts/sign-and-build.sh
```

Build, sign, and notarize:
```bash
./scripts/sign-and-build.sh --notarize
```

Show help:
```bash
./scripts/sign-and-build.sh --help
```

**What it does:**
1. Verifies you have the required certificates
2. Builds a Release archive of LaunchpadPlus
3. Signs the app with your Developer ID
4. (Optional) Submits for notarization and staples the ticket
5. Creates a distribution-ready ZIP file
6. Generates SHA-256 checksum for verification

**Output:**
- `LaunchpadPlus-signed.zip` - Distribution package
- `LaunchpadPlus-signed.zip.sha256` - Checksum file
- `build/` directory with archive and exported app

## For Maintainers

### Creating a Release

1. **Update version** in Xcode project settings
2. **Update CHANGELOG** with release notes
3. **Create and push git tag:**
   ```bash
   git tag -a v3.1.0 -m "Release version 3.1.0"
   git push origin v3.1.0
   ```
4. **Trigger release workflow** on GitHub Actions
5. **Edit the draft release** created by the workflow
6. **Publish the release**

### Automated Releases

The `release.yml` workflow automatically creates releases when you push a version tag:

- **Unsigned builds:** Run automatically for all tags
- **Signed builds:** Require manual workflow dispatch with signing secrets

Configure these secrets in GitHub repository settings:
- `CERTIFICATES_P12` - Base64-encoded .p12 file
- `CERTIFICATES_PASSWORD` - Password for .p12 file
- `CODE_SIGN_IDENTITY` - Code signing identity name
- `DEVELOPMENT_TEAM` - Team ID
- `APPLE_ID` - Apple ID email (for notarization)
- `NOTARIZATION_PASSWORD` - App-specific password

### Testing Scripts Locally

Before pushing script changes, test them locally:

```bash
# Test unsigned build
xcodebuild clean build \
  -project LaunchpadPlus.xcodeproj \
  -scheme LaunchpadPlus \
  -configuration Release \
  CODE_SIGN_IDENTITY="" \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGNING_ALLOWED=NO

# Test signed build (requires certificates)
./scripts/sign-and-build.sh
```

## Documentation

See also:
- [CONTRIBUTING.md](../CONTRIBUTING.md) - Development guidelines
- [SECURITY.md](../SECURITY.md) - Security policy and code signing details
- [TROUBLESHOOTING.md](../TROUBLESHOOTING.md) - User installation help

## Support

If you encounter issues with these scripts:
1. Check you have Xcode Command Line Tools: `xcode-select --install`
2. Verify your certificates: `security find-identity -v -p codesigning`
3. Review the script output for specific errors
4. Open an issue on GitHub with the error details
