import SwiftUI

struct CategorySettings: View {
   @ObservedObject private var categoryManager = CategoryManager.shared
   @ObservedObject private var appManager = AppManager.shared
   
   @State private var newCategoryName = ""
   @State private var showDeleteAlert = false
   @State private var selectedCategory: Category?
   @State private var editedName: String = ""
   
   var body: some View {
      VStack(alignment: .leading, spacing: 20) {
         VStack(alignment: .leading, spacing: 12) {
            Text(L10n.categories)
               .font(.headline)
               .foregroundColor(.primary)
            
            Text(L10n.categoriesDescription)
               .font(.subheadline)
               .foregroundColor(.secondary)
            
            Text(L10n.createCategory)
               .font(.headline)
               .foregroundColor(.primary)
            
            HStack(spacing: 8) {
               TextField(L10n.categoryName, text: $newCategoryName)
                  .textFieldStyle(.roundedBorder)
               
               Button(action: addCategory) {
                  Image(systemName: "plus.circle.fill")
               }
               .buttonStyle(.borderedProminent)
               .disabled(newCategoryName.isEmpty)
            }
         }
         
         VStack(alignment: .leading, spacing: 12) {
            Text(L10n.manageCategories)
               .font(.headline)
               .foregroundColor(.primary)
            
            if categoryManager.categories.isEmpty {
               Text(L10n.noCategories)
                  .font(.subheadline)
                  .foregroundColor(.secondary)
                  .italic()
                  .padding(.vertical, 8)
            } else {
               ScrollView {
                  VStack(spacing: 8) {
                     ForEach(categoryManager.categories) { category in
                        HStack {
                           if let selected = selectedCategory, selected.id == category.id {
                              TextField(L10n.categoryName, text: $editedName)
                                 .textFieldStyle(RoundedBorderTextFieldStyle())
                                 .onSubmit {
                                    saveEdit()
                                 }
                              
                              Button(L10n.apply) {
                                 saveEdit()
                              }
                              .buttonStyle(.bordered)
                              
                              Button(L10n.cancel) {
                                 editedName = category.name
                                 selectedCategory = nil
                              }
                              .buttonStyle(.bordered)
                           } else {
                              Image(systemName: "tag.fill")
                                 .foregroundColor(.blue)
                              Text(category.name)
                                 .font(.body)
                              Text("(\(category.appPaths.count))")
                                 .font(.caption)
                                 .foregroundColor(.secondary)
                              Spacer()
                              Button(action: {
                                 selectedCategory = category
                                 editedName = category.name
                              }) {
                                 Image(systemName: "pencil")
                              }
                              .buttonStyle(.plain)
                              
                              Button(action: { onDelete(category: category) }) {
                                 Image(systemName: "trash")
                                    .foregroundColor(.red)
                              }
                              .buttonStyle(.plain)
                           }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                           RoundedRectangle(cornerRadius: 6)
                              .fill(Color.primary.opacity(0.05))
                        )
                        .glassEffect()
                        
                     }
                     .onMove { source, destination in
                        categoryManager.reorderCategories(from: source, to: destination)
                     }
                  }
               }
            }
         }
      }
      .padding(.horizontal, 8)
      .alert(L10n.deleteCategoryTitle, isPresented: $showDeleteAlert) {
         Button(L10n.cancel, role: .cancel) {
            selectedCategory = nil
         }
         Button(L10n.deleteCategory, role: .destructive) {
            if let category = selectedCategory {
               categoryManager.deleteCategory(category: category)
            }
            selectedCategory = nil
         }
      } message: {
         Text(L10n.deleteCategoryMessage)
      }
   }
   
   private func addCategory() {
      guard !newCategoryName.isEmpty else { return }
      categoryManager.createCategory(name: newCategoryName)
      newCategoryName = ""
   }
   
   private func onDelete(category: Category) {
      selectedCategory = category
      showDeleteAlert = true
   }
   
   private func saveEdit() {
      guard let category = selectedCategory else { return }
      if !editedName.isEmpty {
         categoryManager.renameCategory(category: category, newName: editedName)
      } else {
         editedName = category.name
      }
      selectedCategory = nil
   }
}
