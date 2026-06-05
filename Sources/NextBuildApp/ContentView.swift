import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @EnvironmentObject private var store: AppStore
    @State private var newAppName = ""
    @State private var showingImporter = false
    @FocusState private var searchFocused: Bool

    var body: some View {
        NavigationSplitView {
            sidebar
        } detail: {
            board
            .background(AppTheme.canvas)
            .onChange(of: store.focusSearch) {
                searchFocused = true
            }
        }
    }

    private var sidebar: some View {
        VStack(spacing: 16) {
            HStack {
                Text("B")
                    .font(.headline.weight(.black))
                    .foregroundStyle(.white)
                    .frame(width: 38, height: 38)
                    .background(AppTheme.accent, in: RoundedRectangle(cornerRadius: 9))
                VStack(alignment: .leading, spacing: 2) {
                    Text("NextBuild")
                        .font(.headline.weight(.semibold))
                }
                Spacer()
            }

            HStack {
                TextField("앱 이름 추가", text: $newAppName)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit(addApp)
                Button(action: addApp) {
                    Image(systemName: "plus")
                }
                .buttonStyle(.borderedProminent)
                .tint(AppTheme.accent)
            }

            List(selection: $store.selectedAppID) {
                ForEach(store.apps) { app in
                    AppRow(app: app)
                        .tag(app.id as UUID?)
                }
            }
            .listStyle(.sidebar)

            sidebarTools

            Button(role: .destructive) {
                store.deleteSelectedApp()
            } label: {
                Label("선택한 앱 삭제", systemImage: "trash")
            }
            .buttonStyle(.bordered)
            .disabled(store.apps.count <= 1)
        }
        .padding()
        .background(AppTheme.sidebar)
        .navigationSplitViewColumnWidth(min: 250, ideal: 280, max: 340)
    }

    private var sidebarTools: some View {
        VStack(spacing: 8) {
            TextField("기능 검색", text: $store.searchText)
                .textFieldStyle(.roundedBorder)
                .focused($searchFocused)

            HStack(spacing: 8) {
                Text("위젯")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(AppTheme.secondaryText)
                Spacer()
                Picker("위젯 앱 수", selection: Binding(
                    get: { store.widgetAppLimit },
                    set: { store.setWidgetAppLimit($0) }
                )) {
                    ForEach(1...5, id: \.self) { count in
                        Text("\(count)개").tag(count)
                    }
                }
                .labelsHidden()
                .frame(width: 72)
            }

            Button {
                WidgetPanelController.shared.show(store: store)
            } label: {
                Label("위젯 보기", systemImage: "rectangle.on.rectangle")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)

            HStack(spacing: 8) {
                Button {
                    if let url = store.exportJSON() {
                        NSWorkspace.shared.activateFileViewerSelecting([url])
                    }
                } label: {
                    Image(systemName: "folder")
                        .frame(maxWidth: .infinity)
                }
                .help("JSON 위치 열기")
                .buttonStyle(.bordered)

                Button {
                    showingImporter = true
                } label: {
                    Image(systemName: "square.and.arrow.down")
                        .frame(maxWidth: .infinity)
                }
                .help("JSON 가져오기")
                .buttonStyle(.bordered)
            }
        }
        .padding(10)
        .quietCard(cornerRadius: 10)
        .fileImporter(isPresented: $showingImporter, allowedContentTypes: [.json]) { result in
            if case let .success(url) = result {
                store.importJSON(from: url)
            }
        }
    }

    private var board: some View {
        ScrollView([.horizontal, .vertical]) {
            HStack(alignment: .top, spacing: 12) {
                ForEach(store.apps) { app in
                    AppFeatureCard(app: app)
                        .frame(width: 330)
                }
            }
            .padding(24)
        }
    }

    private func addApp() {
        store.addApp(named: newAppName)
        newAppName = ""
    }
}

private struct AppRow: View {
    let app: ManagedApp

    var body: some View {
        let done = app.features.filter { $0.status == .done }.count

        HStack(spacing: 10) {
            Text(String(app.name.prefix(1)))
                .font(.headline.weight(.bold))
                .foregroundStyle(AppTheme.accent)
                .frame(width: 32, height: 32)
                .background(AppTheme.accentSoft, in: RoundedRectangle(cornerRadius: 8))
            VStack(alignment: .leading, spacing: 2) {
                Text(app.name)
                    .font(.subheadline.weight(.semibold))
                Text("\(done)/\(app.features.count) 구현됨")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}
