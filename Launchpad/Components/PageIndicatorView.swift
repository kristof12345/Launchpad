import SwiftUI

struct PageIndicatorView: View {
    @Binding var currentPage: Int
    let pageCount: Int
    let isFolderOpen: Bool
    let searchText: String
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        HStack(spacing: 12) {
            ForEach(0..<pageCount, id: \.self) { index in
                ZStack {
                    // Background liquid glass effect
                    Circle()
                        .fill(.thinMaterial)
                        .frame(width: 20, height: 20)
                        .opacity(index == currentPage ? 1.0 : 0.6)
                    
                    // Inner indicator with enhanced styling
                    Circle()
                        .fill(
                            index == currentPage
                                ? .white.opacity(0.9)
                                : .white.opacity(0.3)
                        )
                        .frame(width: index == currentPage ? 10 : 6, height: index == currentPage ? 10 : 6)
                        .overlay {
                            Circle()
                                .stroke(.white.opacity(0.4), lineWidth: 0.5)
                        }
                        .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
                }
                .scaleEffect(index == currentPage ? 1.1 : 0.9)
                .animation(.spring(response: 0.4, dampingFraction: 0.7, blendDuration: 0.1), value: currentPage)
                .onTapGesture {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8, blendDuration: 0.2)) {
                        currentPage = index
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background {
            // Container with liquid glass background
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(.white.opacity(0.05))
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(.white.opacity(0.1), lineWidth: 0.5)
                }
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 3)
        }
        .padding(.top, 20)
        .padding(.bottom, 44)
        .opacity(searchText.isEmpty && !isFolderOpen ? 1 : 0)
        .scaleEffect(searchText.isEmpty && !isFolderOpen ? 1.0 : 0.8)
        .animation(.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0.2), value: searchText.isEmpty && !isFolderOpen)
    }
}
