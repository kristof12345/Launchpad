import SwiftUI

struct GridItemView: View {
  let item: AppGridItem
  let layout: LayoutMetrics
  let isDragged: Bool

  var body: some View {
    switch item {
    case .app(let app):
      AppIconView(app: app, layout: layout)
    case .folder(let folder):
      FolderIconView(folder: folder, layout: layout)
    }
  }
}
