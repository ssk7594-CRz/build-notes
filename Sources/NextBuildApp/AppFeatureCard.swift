import SwiftUI

struct AppFeatureCard: View {
    @EnvironmentObject private var store: AppStore
    let app: ManagedApp
    @State private var showsCompleted = false

    private var plannedFeatures: [FeatureItem] {
        store.visibleFeatures(in: app, completed: false)
    }

    private var doneFeatures: [FeatureItem] {
        store.visibleFeatures(in: app, completed: true)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            header

            FeatureBucket(
                title: "구현 예정 기능",
                count: plannedFeatures.count,
                emptyText: "추가할 기능 없음",
                features: plannedFeatures,
                completed: false,
                appID: app.id,
                isExpanded: true,
                isPrimary: true
            )

            DisclosureGroup(isExpanded: $showsCompleted) {
                FeatureBucket(
                    title: "완료 흐름",
                    count: doneFeatures.count,
                    emptyText: "완료된 기능 없음",
                    features: doneFeatures,
                    completed: true,
                    appID: app.id,
                    isExpanded: showsCompleted,
                    isPrimary: false
                )
                .padding(.top, 8)
            } label: {
                HStack {
                    Text("구현 완료 기능")
                        .font(.subheadline.weight(.bold))
                    Spacer()
                    Text("\(doneFeatures.count)")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.white)
                        .frame(minWidth: 24, minHeight: 24)
                        .background(Color.green, in: Capsule())
                }
                .padding(12)
                .background(AppTheme.elevated, in: RoundedRectangle(cornerRadius: 12))
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(AppTheme.stroke, lineWidth: 1)
                }
            }
            .disclosureGroupStyle(.automatic)
        }
        .padding(14)
        .frame(minHeight: 560, alignment: .top)
        .quietCard(cornerRadius: 14)
        .onTapGesture {
            store.selectedAppID = app.id
        }
    }

    private var header: some View {
        HStack(spacing: 12) {
            Text(String(app.name.prefix(1)))
                .font(.title3.weight(.black))
                .foregroundStyle(.white)
                .frame(width: 44, height: 44)
                .background(AppTheme.accent, in: RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 3) {
                Text(app.name)
                    .font(.headline.weight(.bold))
                    .lineLimit(1)
                Text("\(doneFeatures.count)/\(app.features.count) 구현됨")
                    .font(.caption)
                    .foregroundStyle(AppTheme.secondaryText)
            }

            Spacer()
        }
        .padding(.bottom, 2)
    }
}

private struct FeatureBucket: View {
    @EnvironmentObject private var store: AppStore
    @State private var newTitle = ""

    let title: String
    let count: Int
    let emptyText: String
    let features: [FeatureItem]
    let completed: Bool
    let appID: UUID
    let isExpanded: Bool
    let isPrimary: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if isPrimary || isExpanded {
                HStack {
                    Text(title)
                        .font(isPrimary ? .headline.weight(.bold) : .subheadline.weight(.bold))
                    Spacer()
                    Text("\(count)")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.white)
                        .frame(minWidth: 24, minHeight: 24)
                        .background(completed ? Color.green : AppTheme.accent, in: Capsule())
                }
            }

            if isPrimary && !completed {
                HStack(spacing: 8) {
                    TextField("새 구현 예정 기능", text: $newTitle)
                        .textFieldStyle(.roundedBorder)
                        .onSubmit(addInlineFeature)
                    Button {
                        addInlineFeature()
                    } label: {
                        Image(systemName: "return")
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(AppTheme.accent)
                    .disabled(newTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }

            if features.isEmpty {
                Text(emptyText)
                    .font(.callout)
                    .foregroundStyle(AppTheme.secondaryText)
                    .frame(maxWidth: .infinity, minHeight: isPrimary ? 240 : 72)
            } else {
                VStack(spacing: 8) {
                    ForEach(features) { feature in
                        FeatureMoveRow(appID: appID, feature: feature, completed: completed)
                    }
                }
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, minHeight: isPrimary ? 330 : nil, alignment: .topLeading)
        .background(AppTheme.elevated, in: RoundedRectangle(cornerRadius: 12))
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(AppTheme.stroke, lineWidth: 1)
        }
    }

    private func addInlineFeature() {
        let trimmed = newTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        store.addFeature(to: appID, title: trimmed, status: .planned, priority: .medium, targetVersion: "")
        newTitle = ""
    }
}

private struct FeatureMoveRow: View {
    @EnvironmentObject private var store: AppStore
    let appID: UUID
    let feature: FeatureItem
    let completed: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Button {
                store.toggleFeatureCompletion(appID: appID, featureID: feature.id)
            } label: {
                Image(systemName: completed ? "arrow.uturn.left" : "checkmark")
                    .font(.caption.weight(.bold))
                    .frame(width: 20, height: 20)
            }
            .buttonStyle(.borderless)
            .foregroundStyle(completed ? AppTheme.secondaryText : AppTheme.accent)
            .help(completed ? "구현 예정으로 이동" : "구현 완료로 이동")

            VStack(alignment: .leading, spacing: 3) {
                Text(feature.title)
                    .font(.callout.weight(.semibold))
                    .lineLimit(2)
                    .strikethrough(completed, color: AppTheme.secondaryText)

                HStack(spacing: 6) {
                    if !feature.targetVersion.isEmpty {
                        Text(feature.targetVersion)
                    }
                    Text(feature.priority.title)
                    if feature.status != .planned && feature.status != .done {
                        Text(feature.status.title)
                    }
                }
                .font(.caption2)
                .foregroundStyle(AppTheme.secondaryText)
            }

            Spacer(minLength: 0)
        }
        .padding(8)
        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 8))
    }
}
