import SwiftUI

struct FolderNameView: View {
   @Binding var folder: Folder
   @Binding var editingName: Bool
   
   let opacity: Double
   let offset: CGFloat
   
   @FocusState private var nameFieldFocused: Bool
   
   var body: some View {
      VStack(spacing: 16) {
         HStack {
            Spacer()
            if editingName {
               TextField("", text: $folder.name)
                  .textFieldStyle(.plain)
                  .font(.title2.weight(.medium))
                  .multilineTextAlignment(.center)
                  .padding(.horizontal, 20)
                  .padding(.vertical, 8)
                  .background(
                     RoundedRectangle(cornerRadius: 8)
                        .fill(Color.primary.opacity(0.08))
                        .overlay(
                           RoundedRectangle(cornerRadius: 8)
                              .stroke(Color.primary.opacity(0.2), lineWidth: 1)
                        )
                  )
                  .focused($nameFieldFocused)
                  .onAppear {
                     DispatchQueue.main.async { nameFieldFocused = true }
                  }
                  .onSubmit {
                     withAnimation(LaunchPadConstants.quickFadeAnimation) { editingName = false }
                     nameFieldFocused = false
                  }
                  .transition(.scale.combined(with: .opacity))
            } else {
               Text(folder.name.isEmpty ? L10n.untitledFolder : folder.name )
                  .font(.title2.weight(.medium))
                  .foregroundStyle(.primary)
                  .padding(.horizontal, 16)
                  .padding(.vertical, 8)
                  .onTapGesture {
                     withAnimation(LaunchPadConstants.quickFadeAnimation) { editingName = true}
                  }
                  .transition(.scale.combined(with: .opacity))
            }
            Spacer()
         }
         
         .padding(.horizontal, 32)
      }
      .offset(y: offset)
      .opacity(opacity)
      .padding(.vertical, 20)
   }
}
