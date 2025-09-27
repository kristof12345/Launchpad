import AppKit
import SwiftUI

struct FolderIconView: View {
    let folder: Folder
    let layout: LayoutMetrics
    let isDragged: Bool
    @Environment(\.colorScheme) private var colorScheme
    @State private var isHovered = false
    @State private var animationOffset: CGFloat = 0
    
    var body: some View {
        let gridSpacing: CGFloat = 1.5
        
        VStack(spacing: 8) {
            ZStack {
                // Enhanced liquid glass background
                RoundedRectangle(cornerRadius: layout.iconSize * 0.22, style: .continuous)
                    .fill(.thickMaterial)
                    .overlay {
                        RoundedRectangle(cornerRadius: layout.iconSize * 0.22, style: .continuous)
                            .fill(.white.opacity(isHovered ? 0.15 : 0.08))
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: layout.iconSize * 0.22, style: .continuous)
                            .stroke(.white.opacity(isHovered ? 0.3 : 0.15), lineWidth: 1)
                    }
                    .frame(width: layout.iconSize * 0.85, height: layout.iconSize * 0.85)
                
                // App icons grid with enhanced animations
                LazyVGrid(columns: GridLayoutUtility.createFlexibleGridColumns(count: 3, spacing: gridSpacing), spacing: gridSpacing) {
                    ForEach(folder.previewApps.indices, id: \.self) { index in
                        let app = folder.previewApps[index]
                        Image(nsImage: app.icon)
                            .interpolation(.high)
                            .resizable()
                            .frame(width: layout.iconSize * 0.22, height: layout.iconSize * 0.22)
                            .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                            .scaleEffect(isHovered ? 1.05 : 1.0)
                            .offset(x: isHovered ? sin(Double(index) * 0.5 + animationOffset) * 1 : 0,
                                   y: isHovered ? cos(Double(index) * 0.7 + animationOffset) * 1 : 0)
                            .animation(.spring(response: 0.4, dampingFraction: 0.6).delay(Double(index) * 0.02), value: isHovered)
                    }
                    
                    ForEach(folder.previewApps.count..<9, id: \.self) { index in
                        RoundedRectangle(cornerRadius: 4, style: .continuous)
                            .fill(.clear)
                            .frame(width: layout.iconSize * 0.22, height: layout.iconSize * 0.22)
                    }
                }
                .frame(width: layout.iconSize * 0.65, height: layout.iconSize * 0.65)
            }
            .frame(width: layout.iconSize, height: layout.iconSize)
            .clipShape(RoundedRectangle(cornerRadius: layout.iconSize * 0.18, style: .continuous))
            .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
            .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 2)
            
            Text(folder.name)
                .font(.system(size: layout.fontSize))
                .multilineTextAlignment(.center)
                .frame(width: layout.cellWidth)
                .foregroundStyle(.primary)
                .scaleEffect(isHovered ? 1.02 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isHovered)
        }
        .scaleEffect(isDragged ? 0.85 : (isHovered ? 1.05 : 1.0))
        .opacity(isDragged ? 0.6 : 1.0)
        .blur(radius: isDragged ? 1 : 0)
        .animation(.spring(response: 0.4, dampingFraction: 0.7, blendDuration: 0.1), value: isDragged)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isHovered)
        .onHover { hovering in
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isHovered = hovering
            }
            
            if hovering {
                // Start subtle animation for app icons
                withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                    animationOffset = .pi * 2
                }
            } else {
                // Stop animation
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    animationOffset = 0
                }
            }
        }
    }
}
