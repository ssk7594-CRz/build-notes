import SwiftUI

struct MenuBarQuickCaptureView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.openWindow) private var openWindow
    @State private var title = ""
    @State private var targetVersion = ""
    @State private var priority: FeaturePriority = .medium

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            header

            VStack(spacing: 8) {
                TextField("아 맞다, 이 기능...", text: $title)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit(addFeature)

                HStack {
                    TextField("v1.1", text: $targetVersion)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 86)

                    Picker("우선순위", selection: $priority) {
                        ForEach(FeaturePriority.allCases) { priority in
                            Text(priority.title).tag(priority)
                        }
                    }
                    .labelsHidden()

                    Button("추가", action: addFeature)
                        .buttonStyle(.borderedProminent)
                        .tint(AppTheme.accent)
                }
            }

            Divider()

            VStack(alignment: .leading, spacing: 8) {
                Text("구현할 기능")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(AppTheme.secondaryText)

                let planned = store.features(for: .planned).prefix(5)
                if planned.isEmpty {
                    Text("아직 적어둔 기능이 없습니다.")
                        .font(.callout)
                        .foregroundStyle(AppTheme.secondaryText)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 10)
                } else {
                    ForEach(Array(planned)) { feature in
                        HStack(alignment: .top, spacing: 8) {
                            Circle()
                                .fill(priorityColor(feature.priority))
                                .frame(width: 7, height: 7)
                                .padding(.top, 6)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(feature.title)
                                    .font(.callout.weight(.semibold))
                                    .lineLimit(2)
                                if !feature.targetVersion.isEmpty {
                                    Text(feature.targetVersion)
                                        .font(.caption2)
                                        .foregroundStyle(AppTheme.secondaryText)
                                }
                            }
                        }
                    }
                }
            }

            Divider()

            HStack {
                Button {
                    WidgetPanelController.shared.show(store: store)
                } label: {
                    Label("위젯 띄우기", systemImage: "rectangle.on.rectangle")
                }

                Spacer()

                Button {
                    openWindow(id: "quick-widget")
                } label: {
                    Label("창으로 열기", systemImage: "macwindow")
                }
            }
            .buttonStyle(.bordered)
        }
        .padding(16)
        .frame(width: 340)
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(store.selectedApp?.name ?? "Build Notes")
                    .font(.headline.weight(.bold))
                Text("빠른 메모")
                    .font(.caption)
                    .foregroundStyle(AppTheme.secondaryText)
            }
            Spacer()
            Text("\(store.selectedApp?.features.count ?? 0)")
                .font(.title3.weight(.bold))
                .foregroundStyle(AppTheme.accent)
        }
    }

    private func addFeature() {
        store.addFeature(title: title, status: .planned, priority: priority, targetVersion: targetVersion)
        title = ""
        targetVersion = ""
        priority = .medium
    }

    private func priorityColor(_ priority: FeaturePriority) -> Color {
        switch priority {
        case .high: Color(red: 0.70, green: 0.28, blue: 0.23)
        case .medium: AppTheme.accent
        case .low: AppTheme.secondaryText
        }
    }
}
