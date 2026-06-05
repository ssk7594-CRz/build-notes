import AppKit
import SwiftUI

@MainActor
final class WidgetPanelController {
    static let shared = WidgetPanelController()

    private var panel: NSPanel?

    private init() {}

    func show(store: AppStore) {
        if let panel {
            panel.makeKeyAndOrderFront(nil)
            NSApp.activate()
            return
        }

        let size = widgetSize()
        let origin = widgetOrigin(size: size)

        let view = DesktopWidgetView()
            .environmentObject(store)
            .frame(width: size.width, height: size.height)

        let panel = NSPanel(
            contentRect: NSRect(x: origin.x, y: origin.y, width: size.width, height: size.height),
            styleMask: [.titled, .closable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        panel.title = "Build Notes Widget"
        panel.titleVisibility = .hidden
        panel.titlebarAppearsTransparent = true
        panel.isMovableByWindowBackground = true
        panel.level = .floating
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.contentView = NSHostingView(rootView: view)
        panel.isReleasedWhenClosed = false
        panel.makeKeyAndOrderFront(nil)
        NSApp.activate()

        self.panel = panel
    }

    func close() {
        panel?.close()
        panel = nil
    }

    private func widgetSize() -> CGSize {
        let frame = NSScreen.main?.visibleFrame ?? NSRect(x: 0, y: 0, width: 1440, height: 900)
        return CGSize(width: max(560, frame.width * 0.5), height: max(420, frame.height * 0.5))
    }

    private func widgetOrigin(size: CGSize) -> CGPoint {
        let frame = NSScreen.main?.visibleFrame ?? NSRect(x: 0, y: 0, width: 1440, height: 900)
        return CGPoint(x: frame.maxX - size.width - 24, y: frame.maxY - size.height - 48)
    }
}
