# Quick Fix for macOS Security Warning

If macOS says LaunchpadPlus is "malware" or won't open, follow these steps:

## ✅ Quick Solution (1 minute)

1. **Download** LaunchpadPlus from [GitHub Releases](https://github.com/kristof12345/Launchpad/releases)
2. **Move** LaunchpadPlus.app to your `/Applications` folder
3. **Open Terminal** (Applications > Utilities > Terminal)
4. **Paste this command** and press Enter:
   ```bash
   xattr -cr /Applications/LaunchpadPlus.app
   ```
5. **Launch** LaunchpadPlus from Applications

That's it! LaunchpadPlus will now open normally.

## 📖 What Does This Do?

The command removes the "quarantine" flag that macOS adds to downloaded apps. This is safe and only affects LaunchpadPlus—your Mac's security for other apps remains unchanged.

## 🛡️ Is This Safe?

**Yes!** LaunchpadPlus is open-source software. You can:
- View all source code on [GitHub](https://github.com/kristof12345/Launchpad)
- Build it yourself from source
- Review community feedback and security reports

The "malware" warning appears because the app isn't code-signed by Apple (which requires a $99/year developer account). Many open-source Mac apps face this issue.

## ❓ Still Having Issues?

See the full [Troubleshooting Guide](TROUBLESHOOTING.md) for:
- Alternative solutions
- Detailed explanations
- Other common issues
- How to verify downloads

## 💡 Why Not Just Sign It?

Code signing and notarization require:
- $99/year Apple Developer subscription
- Complex infrastructure
- Certificate maintenance

As a free, open-source project, we prioritize transparency over certificates. You can always verify the app by reviewing the source code.

---

**Need Help?** [Open an issue](https://github.com/kristof12345/Launchpad/issues) on GitHub
