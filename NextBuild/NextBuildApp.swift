import SwiftUI

@main
struct NextBuildApp: App {
    @StateObject private var store = AppStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .frame(minWidth: 1080, minHeight: 680)
        }
        .defaultSize(width: 1180, height: 760)

        MenuBarExtra("NextBuild", systemImage: "checklist") {
            MenuBarQuickCaptureView()
                .environmentObject(store)
        }
        .menuBarExtraStyle(.window)

        Window("NextBuild Widget", id: "quick-widget") {
            DesktopWidgetView()
                .environmentObject(store)
                .frame(width: 720, height: 460)
        }
        .defaultSize(width: 720, height: 460)
        .windowResizability(.contentSize)

        .commands {
            CommandMenu("NextBuild") {
                Button("새 기능") {
                    store.focusQuickCapture.toggle()
                }
                .keyboardShortcut("n", modifiers: [.command])

                Button("검색") {
                    store.focusSearch.toggle()
                }
                .keyboardShortcut("k", modifiers: [.command])
            }
        }
    }
}
