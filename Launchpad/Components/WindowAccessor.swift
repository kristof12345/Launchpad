import SwiftUI

struct WindowAccessor: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            guard let window = view.window else { return }
            
            // Configure window appearance
            window.titleVisibility = .hidden
            window.titlebarAppearsTransparent = true
            window.standardWindowButton(.zoomButton)?.isHidden = true
            window.standardWindowButton(.miniaturizeButton)?.isHidden = true
            window.standardWindowButton(.closeButton)?.isHidden = true
            
            // Configure window style for full-screen like behavior
            window.styleMask.remove([.resizable, .miniaturizable])
            window.styleMask.insert([.fullSizeContentView, .borderless])
            
            // Set collection behavior for proper full-screen support
            window.collectionBehavior = [.fullScreenPrimary, .stationary, .ignoresCycle]
            
            // Set window level to be above normal windows but not blocking modals
            window.level = .statusBar
            
            // Make window span the entire screen
            if let screen = NSScreen.main {
                window.setFrame(screen.frame, display: true)
            }
            
            // Ensure window can become key to receive events
            window.makeKeyAndOrderFront(nil)
            window.acceptsMouseMovedEvents = true
            window.isMovableByWindowBackground = false
            
            // Store window reference in coordinator for later access
            context.coordinator.window = window
        }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        // Restore window as key window if it lost focus
        DispatchQueue.main.async {
            guard let window = nsView.window else { return }
            if !window.isKeyWindow && NSApp.windows.first(where: { $0.isKeyWindow && $0.level == .modalPanel }) == nil {
                // Only restore if there's no modal dialog open
                window.makeKeyAndOrderFront(nil)
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject {
        weak var window: NSWindow?
    }
}
