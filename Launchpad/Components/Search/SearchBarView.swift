import SwiftUI

struct SearchBarView: View {
    @Binding var searchText: String
    @State private var isSearchFocused = false
    
    var body: some View {
        HStack {
            Spacer()
            SearchField(text: $searchText)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .frame(width: isSearchFocused ? 520 : 480, height: 40)
                .background {
                    // Multi-layer liquid glass effect for search bar
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(.thickMaterial)
                        .overlay {
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .fill(.white.opacity(isSearchFocused ? 0.15 : 0.08))
                        }
                        .overlay {
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .stroke(.white.opacity(isSearchFocused ? 0.3 : 0.15), lineWidth: 1)
                        }
                        .shadow(color: .black.opacity(0.1), radius: 12, x: 0, y: 4)
                        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                }
                .scaleEffect(isSearchFocused ? 1.02 : 1.0)
                .animation(.spring(response: 0.4, dampingFraction: 0.7, blendDuration: 0.1), value: isSearchFocused)
                .animation(.spring(response: 0.5, dampingFraction: 0.8, blendDuration: 0.2), value: searchText.isEmpty)
                .onReceive(NotificationCenter.default.publisher(for: NSTextField.textDidBeginEditingNotification)) { _ in
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        isSearchFocused = true
                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: NSTextField.textDidEndEditingNotification)) { _ in
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        isSearchFocused = false
                    }
                }
            Spacer()
        }
        .padding(.top, 44)
        .padding(.bottom, 28)
    }
}
