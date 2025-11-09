# AI Prompts for Code Issues

**Author:** Kiro  
**Date:** November 9, 2025

This document contains optimized prompts for addressing the issues documented in CHANGES.md. These prompts can be used with AI coding assistants to efficiently resolve similar problems.

---

## Issue 1: Activation Prompt Removal

### Recommended Prompt

```
I have a macOS app with an activation/licensing system that prompts users 
every time they launch the app. I want to disable this activation feature 
completely and unlock all premium features.

Please:
1. Find where the activation check happens on app launch/activation
2. Locate the licensing validation logic (isActivated, isPro, isPremium)
3. Remove the activation prompt from appearing
4. Make all premium features always available
5. Remove or hide the activation settings tab

The app is written in Swift/SwiftUI. Please search for:
- "activation" or "isActivated" in the codebase
- Settings or preferences views
- App delegate or main app file for launch logic
```

### Key Search Terms
- `isActivated`
- `activation`
- `productKey`
- `handleAppActivation`
- `SettingsView`
- `isPremium`, `isPro`

---

## Issue 2: Page Transition Animation Improvements

### Recommended Prompt

```
The page transition animations in my app feel laggy and not smooth compared 
to Apple's native Launchpad. The transitions have too much bounce and feel 
slow.

Please:
1. Find the animation constants used for page transitions
2. Identify the spring animation parameters (stiffness and damping)
3. Adjust the values to create smoother, snappier transitions similar to 
   Apple's Launchpad
4. The animation should be quick and fluid without excessive bounce

Look for:
- Animation constants or configuration files
- Spring animation definitions
- Page transition or scroll animation code
```

### Key Search Terms
- `springAnimation`
- `Animation.spring`
- `stiffness`
- `damping`
- `LaunchpadConstants`
- Page transition animation

### Optimal Values
- **Stiffness:** 400 (higher = more responsive)
- **Damping:** 35 (lower = less bouncy)

---

## Issue 3: Multiple Page Skipping on Hard Swipes

### Recommended Prompt

```
In my app, when users swipe hard or fast between pages, it skips multiple 
pages instead of changing just one page per swipe. I need each swipe gesture 
to change exactly one page, regardless of swipe intensity.

Please:
1. Find the scroll event handling code for page navigation
2. Identify how scroll accumulation and page changes are tracked
3. Add logic to ensure only ONE page change per swipe gesture
4. The solution should:
   - Detect when a gesture starts and ends
   - Block additional page changes during the same gesture
   - Reset properly for the next gesture
   - Handle both soft and hard swipes consistently

Add debug logging first to understand:
- Scroll event phases
- Delta values
- Timing between events
- When page changes occur

The app uses trackpad swipe gestures for horizontal scrolling.
```

### Key Search Terms
- `handleScrollEvent`
- `scrollingDelta`
- `accumulatedScroll`
- `currentPage`
- Page navigation
- Gesture detection

### Solution Pattern
```swift
// Add state variable to track page changes in current gesture
@State private var hasChangedPageInCurrentGesture = false

// In scroll handler:
// 1. Detect new gesture (phase or timeout)
if event.phase == .began || timeSinceLastScroll > 0.8 {
    hasChangedPageInCurrentGesture = false
}

// 2. Block if already changed page
guard !hasChangedPageInCurrentGesture else { return event }

// 3. When threshold reached, set flag
if accumulatedScroll >= threshold {
    currentPage += 1
    hasChangedPageInCurrentGesture = true
}
```

### Critical Insight
Separate the timeout for resetting scroll accumulation (0.3s) from the timeout 
for resetting the page change flag (0.8s). This prevents mid-gesture resets 
during momentum scrolling.

---

## General Debugging Prompt

### For Any Scroll/Gesture Issue

```
I'm experiencing issues with scroll/gesture handling in my app. Please add 
comprehensive debug logging to help diagnose the problem.

Add logs for:
1. Every scroll event with:
   - Event phase (began, changed, ended, cancelled)
   - Delta values (X and Y)
   - Time since last event
   - Current accumulation values
2. When gestures are detected as starting/ending
3. When page changes occur
4. When events are blocked or ignored

Use clear emoji prefixes for easy scanning:
- 📊 for scroll events
- 🔄 for gesture resets
- ➡️⬅️ for page changes
- 🚫 for blocked events

Format numbers with 2-3 decimal places for readability.
```

---

## Best Practices for AI-Assisted Debugging

1. **Start with logging** - Always add debug output before making changes
2. **Search broadly** - Use multiple related keywords to find all relevant code
3. **Test incrementally** - Make one change at a time and verify
4. **Understand root cause** - Don't just fix symptoms, understand why it happens
5. **Document findings** - Keep track of what you discover for future reference
6. **Compare with reference** - When possible, compare behavior with native implementations (like Apple's Launchpad)

---

## Prompt Template for Similar Issues

```
I have an issue with [FEATURE] in my [PLATFORM] app where [PROBLEM DESCRIPTION].

Current behavior:
- [What happens now]

Expected behavior:
- [What should happen]

Please:
1. [Specific action 1]
2. [Specific action 2]
3. [Specific action 3]

Technical context:
- Language/Framework: [e.g., Swift/SwiftUI]
- Relevant files: [if known]
- Search terms: [keywords to look for]

If needed, add debug logging first to understand the issue better.
```
