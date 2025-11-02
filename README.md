# 🚀 LaunchpadPlus

[![Build](https://github.com/kristof12345/Launchpad/actions/workflows/build.yml/badge.svg)](https://github.com/kristof12345/Launchpad/actions/workflows/build.yml)
[![macOS](https://img.shields.io/badge/macOS-15.6+-blue.svg)](https://www.apple.com/macos/)
[![Swift](https://img.shields.io/badge/Swift-6.0-orange.svg)](https://swift.org)

A beautiful, modern macOS application launcher with glass morphism design, inspired by macOS Launchpad but with enhanced functionality and customization. As you might know, Apple removed Launchpad in macOS 26. This app offers a complete replacement with more features and a fully customizable, persistent grid.

If you like this project and want to support further development:

<a href="https://www.buymeacoffee.com/Waikiki.com" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" alt="Buy Me A Coffee" style="height: 60px !important;width: 217px !important;" ></a>

**[📥 Download Launchpad v2.7](https://github.com/kristof12345/Launchpad/releases/download/v2.7/Launchpad.app.zip)**

> ⚠️ **macOS Security Warning?** If macOS blocks the app, see our **[Quick Fix Guide](QUICKFIX.md)** (takes 1 minute) or the full [Troubleshooting Guide](TROUBLESHOOTING.md#-macos-security--gatekeeper-issues).

## ✨ Features

### 🎨 **Modern Design**
- Glass morphism UI with translucent, blurred backgrounds
- Smooth animations and fluid transitions throughout
- Justified grid layout – icons evenly distributed
- Responsive layout adapts to any screen size
- Consistent alignment across all views

![Launchpad Main Interface](docs/images/Launchpad-1.png)

### 🔍 **Smart Search**
- Real-time fuzzy search as you type
- Press Enter to launch the first result
- Vertical scrolling through results
- Search within folders automatically
- Clean empty state for no results

![Search Functionality](docs/images/Launchpad-2.png)

### 🗂️ **Folders & Organization**
- Drag one app onto another to create folders
- Click folder names to rename instantly
- Drag apps in/out of folders seamlessly
- Rearrange icons with drag & drop
- Visual feedback during interactions
- Auto-save all layout changes
- Smart overflow to new pages

![Folder](docs/images/Launchpad-4.png)
![Folders](docs/images/Launchpad-5.png)
![Folders](docs/images/Launchpad-3.png)

### 🎮 **Navigation Methods**

#### ⌨️ **Keyboard**
- `←/→` – Navigate pages
- `ENTER` – Launch first search result
- `CMD + ,` – Open settings
- `ESC` – Close app

#### 🖱️ **Mouse & Trackpad**
- Click page dots for direct navigation
- Scroll horizontally (trackpad swipe) or vertically (mouse wheel) to change pages
- Vertical scrolling in search mode
- Click inside folders without closing app

#### 📱 **Touch Support**
- Tap to launch applications
- Long press and drag to reorder
- Swipe for page navigation

## ⚙️ **Settings & Customization**

![Settings](docs/images/Launchpad-6.png)

### 🎛️ **Grid Layout**
- **Columns**: 2–20 per page
- **Rows**: 2–15 per page  
- **Folder Grid**: Separate 2–8 columns, 1–6 rows
- **Icon Size**: 50–200 px with fine control
- **Real-time Preview**: Changes apply instantly

### 🎨 **Animations & Behavior**
- **Drop Delay**: 0.0–3.0s for drag feedback
- **Scroll Sensitivity**: Configurable thresholds
- **Scroll Debounce**: 0.0–3.0s for smooth navigation
- **Start at Login**: Auto-launch on system startup
- **Show Dock**: Toggle dock visibility

### 💾 **Layout Management**
- **Auto-save**: All changes saved automatically
- **Export/Import**: Backup layouts as JSON
- **Reset Options**: Return to defaults
- **Cross-Device**: Share layouts between machines

## 🚀 Quick Start

### 📥 **Installation**

1. **Download** the latest release from [GitHub Releases](https://github.com/kristof12345/Launchpad/releases)
2. **Unzip** the downloaded file
3. **Move** LaunchpadPlus.app to your Applications folder
4. **Remove quarantine** (required for unsigned apps):
   ```bash
   xattr -cr /Applications/LaunchpadPlus.app
   ```
5. **Launch** LaunchpadPlus from Applications

> **Having trouble?** Check the [🛠️ Troubleshooting Guide](TROUBLESHOOTING.md#-macos-security--gatekeeper-issues) for detailed instructions.

### 📥 **First Launch**
1. App scans `/Applications` and `/System/Applications`
2. Apps sorted alphabetically by default
3. Drag & drop to customize layout
4. Create folders by dragging apps together
5. All changes auto-saved

### 💡 **Daily Usage**
- **Search**: Type to filter instantly, press Enter to launch first result
- **Navigate**: Arrow keys, dots, or scroll
- **Launch**: Click any app icon
- **Organize**: Drag to rearrange or create folders
- **Rename**: Click folder names
- **Exit**: Press ESC, activate another app, or click the Launchpad dock icon when already

## 🏗️ **Technical Overview**

### 🌍 **Localization**
- English and Hungarian translations
- Easy to add new languages
- Centralized string management

### 📦 **Requirements**
- macOS 15.6 or later
- Swift 6.0
- Universal binary (Apple Silicon + Intel)

## Hot corner support
Use this free app to assign any app to your macOS hot corners:
https://apps.apple.com/hu/app/hot-corners/id1672176975?l=hu&mt=12
<img width="727" height="501" alt="Képernyőfotó 2025-10-16 - 16 00 06" src="https://github.com/user-attachments/assets/cb0368f1-aadb-4f03-9107-d6398c2fa8e7" />

## Custom gesture support
Create a keyboard shortcut using BetterTouchTool or similar:
<img width="1512" height="456" alt="Képernyőfotó 2025-10-19 - 15 29 50" src="https://github.com/user-attachments/assets/79a83933-c7e9-4d05-a731-51477d6ea51b" />


## 🧪 **Testing**

To run the test suite:

```bash
xcodebuild test -scheme LaunchpadPlus -destination 'platform=macOS' -parallel-testing-enabled NO
```

**Note**: Parallel testing must be disabled due to shared singleton state in tests. The tests use `AppManager.shared` which creates race conditions when tests run concurrently. Future improvements could implement dependency injection to allow parallel test execution.

## 📚 Documentation

- **[⚡ Quick Fix](QUICKFIX.md)** - Fast solution for macOS security warnings (1 minute)
- **[🛠️ Troubleshooting Guide](TROUBLESHOOTING.md)** - Solutions for common issues and detailed explanations
- **[🔒 Security Policy](SECURITY.md)** - Code signing information and security best practices
- **[🤝 Contributing Guide](CONTRIBUTING.md)** - How to build, develop, and contribute to the project

## 🙏 Credits
- Inspired by macOS Launchpad
- Built with SwiftUI and modern macOS APIs
- Based on LaunchBack project
