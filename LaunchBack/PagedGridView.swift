//
//  PagedGridView.swift
//  LaunchBack
//
//  Created by Thomas Aldridge II on 6/22/25.
//

import SwiftUI
import AppKit

// MARK: - AutoFocusSearchField
struct AutoFocusSearchField: NSViewRepresentable {
    @Binding var text: String
    class Coordinator: NSObject, NSSearchFieldDelegate {
        var parent: AutoFocusSearchField
        init(_ parent: AutoFocusSearchField) {
            self.parent = parent
        }
        func controlTextDidChange(_ obj: Notification) {
                if let field = obj.object as? NSSearchField {
                    parent.text = field.stringValue
                }
            }
        }
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    func makeNSView(context: Context) -> NSSearchField {
        let searchField = NSSearchField(string: "")
        searchField.delegate = context.coordinator
        searchField.focusRingType = .none
        DispatchQueue.main.async {
            searchField.becomeFirstResponder()
        }
        return searchField
    }
    func updateNSView(_ nsView: NSSearchField, context: Context) {
        if nsView.stringValue != text {
            nsView.stringValue = text
        }
    }
}

// MARK: - Main View
struct PagedGridView: View {
    let pages: [[AppInfo]]
    let columns = 7
    let rows = 5
    @State private var currentPage = 0
    @GestureState private var dragOffset: CGFloat = 0
    @State private var isDragging = false

    // Scroll wheel handling
    @State private var lastScrollTime = Date.distantPast
    let scrollDebounceInterval: TimeInterval = 0.8
    @State private var accumulatedScrollX: CGFloat = 0
    let scrollActivationThreshold: CGFloat = 80 // require a meaningful horizontal scroll
    @State private var eventMonitor: Any?

    @State private var searchText = ""

    var body: some View {
        ZStack {
            Color.clear
                .background(VisualEffectView(material: .underWindowBackground, blendingMode: .behindWindow))
                .ignoresSafeArea()
                .contentShape(Rectangle())
                .onTapGesture {
                    NSApp.terminate(nil)
                }

            VStack(spacing: 0) {
                // 🔍 Search bar
                HStack {
                    Spacer()
                    AutoFocusSearchField(text: $searchText)
                        .background()
                        .frame(width: 250, height: 30)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 5)
         
                        .shadow(color: Color.black.opacity(0.4), radius: 5, x: 0, y: 2)
                    Spacer()
                }
                .padding(.top, 40)
                .padding(.bottom, 20)

                if searchText.isEmpty {
                    GeometryReader { geo in
                        HStack(spacing: 0) {
                            ForEach(0..<pages.count, id: \.self) { pageIndex in
                                ContentView(apps: pages[pageIndex], columns: columns)
                                    .frame(width: geo.size.width, height: geo.size.height)
                            }
                        }
                        .offset(x: -CGFloat(currentPage) * geo.size.width)
                        .offset(x: dragOffset)
                        .animation(.interpolatingSpring(stiffness: 300, damping: 100), value: currentPage)
                        .onAppear {
                            // Monitor scroll wheel only when not dragging, and only horizontal intent
                            eventMonitor = NSEvent.addLocalMonitorForEvents(matching: .scrollWheel) { event in
                                // Prefer horizontal paging only when horizontal dominates
                                let absX = abs(event.scrollingDeltaX)
                                let absY = abs(event.scrollingDeltaY)
                                guard absX > absY, absX > 0 else {
                                    return event
                                }

                                // Debounce by time to limit to one page per gesture burst
                                let now = Date()
                                if now.timeIntervalSince(lastScrollTime) < scrollDebounceInterval {
                                    return event
                                }

                                // Accumulate horizontal delta; require a threshold
                                accumulatedScrollX += event.scrollingDeltaX

                                if accumulatedScrollX <= -scrollActivationThreshold {
                                    currentPage = min(currentPage + 1, pages.count-1)
                                    lastScrollTime = now
                                    accumulatedScrollX = 0
                                    return nil
                                } else if accumulatedScrollX >= scrollActivationThreshold {
                                    currentPage = max(currentPage - 1, 0)
                                    lastScrollTime = now
                                    accumulatedScrollX = 0
                                    return nil
                                }

                                return event
                            }

                            NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
                                if event.keyCode == 53 { // ESC
                                    NSApp.terminate(nil)
                                    return nil
                                }
                                return event
                            }
                        }
                        .onDisappear {
                            if let monitor = eventMonitor {
                                NSEvent.removeMonitor(monitor)
                                eventMonitor = nil
                            }
                        }
                    }

                    // 🔘 Page indicator dots
                    HStack(spacing: 8) {
                        ForEach(0..<pages.count, id: \.self) { index in
                            Circle()
                                .fill(index == currentPage ? Color.white : Color.gray.opacity(0.5))
                                .frame(width: 8, height: 8)
                        }
                    }
                    .padding(.top, 15)
                    .padding(.bottom, 90)

                } else {
                    // 🔍 Search results — disable scrolling and hide scrollbars
                    GeometryReader { geo in
                        ScrollView(.vertical, showsIndicators: false) {
                            LazyVGrid(
                                columns: Array(repeating: GridItem(.flexible(), spacing: 30), count: columns),
                                spacing: 20
                            ) {
                                ForEach(filteredApps(), id: \.id) { app in
                                    AppIconView(app: app)
                                }
                            }
                            .padding(.horizontal, 50)
                            .padding(.vertical, 40)
                        }
                    }
                }
            }
        }
    }

    func filteredApps() -> [AppInfo] {
        pages.flatMap { $0 }.filter {
            $0.name.lowercased().contains(searchText.lowercased())
        }
    }
}

// MARK: - VisualEffectView (unchanged)
struct VisualEffectView: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = .active
        return view
    }
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {}
}

// MARK: - AppIconView
struct AppIconView: View {
    let app: AppInfo

    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 10) {
                Image(nsImage: app.icon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: geo.size.width * 0.6, height: geo.size.width * 0.6)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                Text(app.name)
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: geo.size.width)
            }
            .onTapGesture {
                NSWorkspace.shared.open(URL(fileURLWithPath: app.path))
                NSApp.terminate(nil)
            }
        }
        .frame(height: 110)
    }
}
