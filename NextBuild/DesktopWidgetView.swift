import SwiftUI

struct DesktopWidgetView: View {
    @EnvironmentObject private var store: AppStore
    @State private var title = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            header

            HStack(spacing: 8) {
                TextField("선택한 앱에 빠른 추가", text: $title)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit(addFeature)
                Button {
                    addFeature()
                } label: {
                    Image(systemName: "plus")
                }
                .buttonStyle(.borderedProminent)
                .tint(AppTheme.accent)
                .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }

            HStack(spacing: 8) {
                MiniStat(value: store.apps.count, label: "앱")
                MiniStat(value: store.apps.flatMap(\.features).filter { $0.status != .done }.count, label: "예정")
                MiniStat(value: store.apps.flatMap(\.features).filter { $0.status == .done }.count, label: "완료")
            }

            ScrollView {
                LazyVStack(spacing: 10) {
                    ForEach(store.widgetApps) { app in
                        WidgetAppSummary(app: app)
                    }
                }
                .padding(.vertical, 2)
            }

            Spacer(minLength: 0)
        }
        .padding(16)
        .background(AppTheme.canvas)
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("NextBuild")
                    .font(.headline.weight(.bold))
                Text("위젯 표시 \(store.widgetApps.count)개")
                    .font(.caption)
                    .foregroundStyle(AppTheme.secondaryText)
            }
            Spacer()
            Button {
                WidgetPanelController.shared.close()
            } label: {
                Image(systemName: "xmark")
            }
            .buttonStyle(.borderless)
        }
    }

    private func addFeature() {
        store.addFeature(title: title, status: .planned, priority: .medium, targetVersion: "")
        title = ""
    }
}

private struct WidgetAppSummary: View {
    @EnvironmentObject private var store: AppStore
    let app: ManagedApp

    private var planned: [FeatureItem] {
        Array(store.visibleFeatures(in: app, completed: false).prefix(4))
    }

    private var doneCount: Int {
        app.features.filter { $0.status == .done }.count
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Text(String(app.name.prefix(1)))
                    .font(.headline.weight(.black))
                    .foregroundStyle(.white)
                    .frame(width: 34, height: 34)
                    .background(AppTheme.accent, in: RoundedRectangle(cornerRadius: 9))

                VStack(alignment: .leading, spacing: 2) {
                    Text(app.name)
                        .font(.subheadline.weight(.bold))
                        .lineLimit(1)
                    Text("\(doneCount)/\(app.features.count) 구현됨")
                        .font(.caption2)
                        .foregroundStyle(AppTheme.secondaryText)
                }

                Spacer()

                Text("\(planned.count)")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white)
                    .frame(minWidth: 22, minHeight: 22)
                    .background(AppTheme.accent, in: Capsule())
            }

            if planned.isEmpty {
                Text("예정 기능 없음")
                    .font(.callout)
                    .foregroundStyle(AppTheme.secondaryText)
                    .padding(.vertical, 6)
            } else {
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(planned) { feature in
                        HStack(alignment: .top, spacing: 8) {
                            Button {
                                store.toggleFeatureCompletion(appID: app.id, featureID: feature.id)
                            } label: {
                                Image(systemName: "checkmark")
                                    .font(.caption.weight(.bold))
                            }
                            .buttonStyle(.borderless)
                            .foregroundStyle(AppTheme.accent)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(feature.title)
                                    .font(.callout.weight(.semibold))
                                    .lineLimit(2)
                                HStack(spacing: 6) {
                                    if !feature.targetVersion.isEmpty {
                                        Text(feature.targetVersion)
                                    }
                                    Text(feature.priority.title)
                                }
                                .font(.caption2)
                                .foregroundStyle(AppTheme.secondaryText)
                            }
                            Spacer(minLength: 0)
                        }
                    }
                }
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.elevated, in: RoundedRectangle(cornerRadius: 12))
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(AppTheme.stroke, lineWidth: 1)
        }
    }
}

private struct MiniStat: View {
    let value: Int
    let label: String

    var body: some View {
        VStack(spacing: 2) {
            Text("\(value)")
                .font(.headline.weight(.bold))
            Text(label)
                .font(.caption2)
                .foregroundStyle(AppTheme.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .quietCard(cornerRadius: 8)
    }
}
