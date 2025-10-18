import AppKit

final class ResponsiveWindow: NSWindow {
   init(contentRect: NSRect, styleMask style: NSWindow.StyleMask) {
      super.init(contentRect: contentRect, styleMask: style, backing: .buffered, defer: false)
      configureWindow()
   }

   private func configureWindow() {
      titleVisibility = .hidden
      styleMask.remove([.resizable, .titled])
      styleMask.insert(.fullSizeContentView)
      level = .floating

      if let screen = NSScreen.main {
         setFrame(screen.frame, display: true)
      }

      collectionBehavior = [.fullScreenPrimary, .canJoinAllSpaces]
   }

   override var canBecomeKey: Bool { true }
   override var canBecomeMain: Bool { true }
   override var acceptsFirstResponder: Bool { true }
}
