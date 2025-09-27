import AppKit
import SwiftUI

struct VisualEffectView: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode
    let emphasized: Bool
    
    init(
        material: NSVisualEffectView.Material = .fullScreenUI,
        blendingMode: NSVisualEffectView.BlendingMode = .behindWindow,
        emphasized: Bool = false
    ) {
        self.material = material
        self.blendingMode = blendingMode
        self.emphasized = emphasized
    }
    
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = .active
        view.isEmphasized = emphasized
        
        // Enhanced liquid glass properties
        view.wantsLayer = true
        view.layer?.cornerRadius = 0
        view.layer?.masksToBounds = false
        
        return view
    }
    
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
        nsView.isEmphasized = emphasized
    }
}

// Additional liquid glass materials for different contexts
extension VisualEffectView {
    static func liquidGlass(
        material: NSVisualEffectView.Material = .hudWindow,
        emphasized: Bool = true
    ) -> VisualEffectView {
        VisualEffectView(
            material: material,
            blendingMode: .withinWindow,
            emphasized: emphasized
        )
    }
    
    static func backdrop(
        material: NSVisualEffectView.Material = .fullScreenUI,
        emphasized: Bool = false
    ) -> VisualEffectView {
        VisualEffectView(
            material: material,
            blendingMode: .behindWindow,
            emphasized: emphasized
        )
    }
    
    static func panel(
        material: NSVisualEffectView.Material = .windowBackground,
        emphasized: Bool = true
    ) -> VisualEffectView {
        VisualEffectView(
            material: material,
            blendingMode: .withinWindow,
            emphasized: emphasized
        )
    }
}
