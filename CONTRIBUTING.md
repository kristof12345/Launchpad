# 🤝 Contributing to LaunchpadPlus

Thank you for your interest in contributing to LaunchpadPlus! This guide will help you get started.

## 📋 Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [Building the Project](#building-the-project)
- [Code Signing for Development](#code-signing-for-development)
- [Testing](#testing)
- [Making Changes](#making-changes)
- [Submitting Pull Requests](#submitting-pull-requests)
- [Release Process](#release-process)

## Code of Conduct

Be respectful, inclusive, and constructive. We're all here to make LaunchpadPlus better.

## Getting Started

### Prerequisites

- macOS 15.6 or later
- Xcode 15.0 or later
- Swift 6.0 (included with Xcode)
- Git

### Fork and Clone

1. **Fork the repository** on GitHub
2. **Clone your fork:**
   ```bash
   git clone https://github.com/YOUR_USERNAME/Launchpad.git
   cd Launchpad
   ```
3. **Add upstream remote:**
   ```bash
   git remote add upstream https://github.com/kristof12345/Launchpad.git
   ```

## Development Setup

### Open in Xcode

```bash
open LaunchpadPlus.xcodeproj
```

### Configure Signing (Optional for Development)

For local development and testing, you can either:

#### Option 1: Use Automatic Signing (Recommended for Quick Testing)

1. Select the **LaunchpadPlus** target
2. Go to **Signing & Capabilities** tab
3. Check **"Automatically manage signing"**
4. Select your **Personal Team** or **Developer Team**
5. Change the **Bundle Identifier** to something unique (e.g., `com.yourname.LaunchpadPlus`)

#### Option 2: Disable Signing for Development

If you just want to build and test locally without worrying about signing:

1. Build from command line:
   ```bash
   xcodebuild clean build \
     -project LaunchpadPlus.xcodeproj \
     -scheme LaunchpadPlus \
     -configuration Debug \
     CODE_SIGN_IDENTITY="" \
     CODE_SIGNING_REQUIRED=NO \
     CODE_SIGNING_ALLOWED=NO
   ```

2. Remove quarantine from built app:
   ```bash
   xattr -cr ~/Library/Developer/Xcode/DerivedData/*/Build/Products/Debug/LaunchpadPlus.app
   ```

### First Build

1. **Select the LaunchpadPlus scheme** in Xcode
2. **Select your Mac as the destination**
3. **Press ⌘R** to build and run

The app should launch successfully on your Mac.

## Building the Project

### Build Configurations

- **Debug:** Development builds with debugging symbols
- **Release:** Optimized builds for distribution

### Build from Xcode

- **Build:** ⌘B
- **Run:** ⌘R
- **Test:** ⌘U
- **Clean:** ⌘⇧K

### Build from Command Line

#### Debug Build

```bash
xcodebuild clean build \
  -project LaunchpadPlus.xcodeproj \
  -scheme LaunchpadPlus \
  -configuration Debug \
  -destination 'platform=macOS'
```

#### Release Build (Unsigned)

```bash
xcodebuild clean build \
  -project LaunchpadPlus.xcodeproj \
  -scheme LaunchpadPlus \
  -configuration Release \
  -destination 'platform=macOS,arch=arm64' \
  CODE_SIGN_IDENTITY="" \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGNING_ALLOWED=NO
```

#### Universal Binary (Apple Silicon + Intel)

```bash
xcodebuild clean build \
  -project LaunchpadPlus.xcodeproj \
  -scheme LaunchpadPlus \
  -configuration Release \
  -destination 'platform=macOS,arch=arm64' \
  -destination 'platform=macOS,arch=x86_64' \
  CODE_SIGN_IDENTITY="" \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGNING_ALLOWED=NO
```

### Locate Built App

The built app will be at:
```
~/Library/Developer/Xcode/DerivedData/LaunchpadPlus-*/Build/Products/Debug/LaunchpadPlus.app
```

Or use this command to find it:
```bash
find ~/Library/Developer/Xcode/DerivedData -name "LaunchpadPlus.app" -type d | grep Debug
```

## Code Signing for Development

### When Do You Need Signing?

- ✅ **Local testing:** No signing needed (use `xattr -cr`)
- ✅ **Running in Xcode:** Automatic signing handles it
- ⚠️ **Sharing with others:** They'll need to bypass Gatekeeper
- ⚠️ **App Store distribution:** Requires Developer ID

### Signing with Your Developer ID

If you have an Apple Developer account:

1. **Set your team:**
   ```bash
   xcodebuild build \
     -project LaunchpadPlus.xcodeproj \
     -scheme LaunchpadPlus \
     DEVELOPMENT_TEAM=YOUR_TEAM_ID
   ```

2. **Create a signed build:**
   ```bash
   xcodebuild archive \
     -project LaunchpadPlus.xcodeproj \
     -scheme LaunchpadPlus \
     -configuration Release \
     -archivePath ./build/LaunchpadPlus.xcarchive
   ```

3. **Export the archive:**
   - Open Xcode Organizer
   - Select your archive
   - Export with Developer ID

## Testing

### Run Tests in Xcode

Press **⌘U** or select **Product > Test**

### Run Tests from Command Line

```bash
xcodebuild test \
  -project LaunchpadPlus.xcodeproj \
  -scheme LaunchpadPlus \
  -destination 'platform=macOS' \
  -parallel-testing-enabled NO
```

**Note:** Parallel testing is disabled due to shared singleton state.

### Writing Tests

- Place tests in the `Tests/` directory
- Use descriptive test names: `testFeatureName_whenCondition_shouldBehavior()`
- Test both success and failure cases
- Mock external dependencies
- Follow existing test patterns

Example test structure:
```swift
final class FeatureTests: XCTestCase {
    var sut: FeatureClass!
    
    override func setUp() {
        super.setUp()
        sut = FeatureClass()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func testFeature_whenCondition_shouldExpectedBehavior() {
        // Given
        let input = "test"
        
        // When
        let result = sut.process(input)
        
        // Then
        XCTAssertEqual(result, "expected")
    }
}
```

## Making Changes

### Branch Naming

- `feature/description` - New features
- `fix/description` - Bug fixes
- `docs/description` - Documentation updates
- `refactor/description` - Code refactoring

Example:
```bash
git checkout -b feature/add-dark-mode-toggle
```

### Coding Standards

#### Swift Style Guide

- **Indentation:** 4 spaces (no tabs)
- **Line length:** Max 120 characters (flexible)
- **Naming:** Use clear, descriptive names
- **Comments:** Explain "why", not "what"
- **SwiftUI:** Prefer `@StateObject` over `@ObservedObject` for ownership

#### Code Organization

```swift
// MARK: - Properties
// MARK: - Initialization
// MARK: - Lifecycle
// MARK: - Public Methods
// MARK: - Private Methods
// MARK: - Helper Methods
```

#### Example Code Style

```swift
import SwiftUI

/// Brief description of the struct/class
struct MyView: View {
    // MARK: - Properties
    
    @StateObject private var manager = AppManager.shared
    @State private var isShowing = false
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 16) {
            headerView
            contentView
        }
    }
    
    // MARK: - Subviews
    
    private var headerView: some View {
        Text("Header")
            .font(.headline)
    }
    
    private var contentView: some View {
        Text("Content")
            .font(.body)
    }
    
    // MARK: - Methods
    
    private func handleAction() {
        // Implementation
    }
}
```

### Commit Messages

Use clear, descriptive commit messages:

```
feat: Add dark mode toggle to settings
fix: Resolve crash when launching with empty grid
docs: Update README with installation instructions
refactor: Extract grid layout logic to separate class
test: Add tests for folder creation
```

Format:
- `feat:` - New feature
- `fix:` - Bug fix
- `docs:` - Documentation
- `refactor:` - Code restructuring
- `test:` - Adding tests
- `chore:` - Maintenance tasks

### Localization

If your changes include user-facing strings:

1. **Add to LocalizationHelper.swift:**
   ```swift
   static var myNewString: String { "my_new_string".localized }
   ```

2. **Add to en.lproj/Localizable.strings:**
   ```
   "my_new_string" = "My New String";
   ```

3. **Add to hu.lproj/Localizable.strings:**
   ```
   "my_new_string" = "Az Új Szövegem";
   ```

## Submitting Pull Requests

### Before Submitting

- [ ] Code builds without errors or warnings
- [ ] All tests pass
- [ ] New features have tests
- [ ] Code follows style guidelines
- [ ] Localization strings added (if applicable)
- [ ] Documentation updated (if needed)
- [ ] Commit messages are clear

### PR Process

1. **Push your branch:**
   ```bash
   git push origin feature/your-feature
   ```

2. **Create Pull Request** on GitHub

3. **Fill out the PR template:**
   - Description of changes
   - Related issues
   - Testing performed
   - Screenshots (for UI changes)

4. **Respond to feedback:**
   - Address review comments
   - Push additional commits
   - Mark conversations as resolved

5. **After approval:**
   - Maintainer will merge your PR
   - Your contribution will be in the next release!

### PR Title Format

```
feat: Add feature description
fix: Fix bug description
docs: Update documentation description
```

## Release Process

### For Maintainers

1. **Update version number** in project settings
2. **Update CHANGELOG.md** with release notes
3. **Create git tag:**
   ```bash
   git tag -a v3.1.0 -m "Release version 3.1.0"
   git push origin v3.1.0
   ```
4. **Build release binary:**
   ```bash
   xcodebuild archive -project LaunchpadPlus.xcodeproj \
     -scheme LaunchpadPlus -configuration Release \
     -archivePath ./build/LaunchpadPlus.xcarchive
   ```
5. **Export and zip** the .app bundle
6. **Create GitHub Release** with release notes
7. **Upload** the .zip file as a release asset
8. **Announce** on discussions and social media

### Version Numbering

We follow [Semantic Versioning](https://semver.org/):

- **Major (X.0.0):** Breaking changes, major new features
- **Minor (1.X.0):** New features, no breaking changes
- **Patch (1.0.X):** Bug fixes, minor improvements

## Need Help?

- **Questions:** Open a [GitHub Discussion](https://github.com/kristof12345/Launchpad/discussions)
- **Bug Reports:** Open an [Issue](https://github.com/kristof12345/Launchpad/issues)
- **Security Issues:** See [SECURITY.md](SECURITY.md)

## Recognition

Contributors are recognized in:
- Release notes
- GitHub contributors page
- Project documentation

Thank you for contributing to LaunchpadPlus! 🚀
