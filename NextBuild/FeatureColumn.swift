import SwiftUI

struct FeatureColumn: View {
    @EnvironmentObject private var store: AppStore
    let status: FeatureStatus

    var body: some View {
        let features = store.features(for: status)

        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(status.title)
                    .font(.headline.weight(.semibold))
                Spacer()
                Text("\(features.count)")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white)
                    .frame(minWidth: 24, minHeight: 24)
                    .background(AppTheme.accent, in: Capsule())
            }
            .padding(.horizontal, 12)
            .padding(.top, 12)

            Rectangle()
                .fill(AppTheme.stroke)
                .frame(height: 1)

            if features.isEmpty {
                Text("\(status.title) 없음")
                    .font(.callout)
                    .foregroundStyle(AppTheme.secondaryText)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 36)
            } else {
                ForEach(features) { feature in
                    FeatureCard(feature: feature)
                        .padding(.horizontal, 10)
                }
            }

            Spacer(minLength: 0)
        }
        .frame(minHeight: 470)
        .quietCard(cornerRadius: 12)
    }
}

private struct FeatureCard: View {
    @EnvironmentObject private var store: AppStore
    let feature: FeatureItem

    @State private var title: String
    @State private var targetVersion: String
    @State private var priority: FeaturePriority
    @State private var status: FeatureStatus
    @State private var note: String

    init(feature: FeatureItem) {
        self.feature = feature
        _title = State(initialValue: feature.title)
        _targetVersion = State(initialValue: feature.targetVersion)
        _priority = State(initialValue: feature.priority)
        _status = State(initialValue: feature.status)
        _note = State(initialValue: feature.note)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            TextField("기능 제목", text: $title, axis: .vertical)
                .font(.headline.weight(.semibold))
                .textFieldStyle(.plain)
                .onSubmit(commit)

            HStack {
                TextField("버전", text: $targetVersion)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 72)
                    .onSubmit(commit)

                Picker("우선순위", selection: $priority) {
                    ForEach(FeaturePriority.allCases) { priority in
                        Text(priority.title).tag(priority)
                    }
                }
                .labelsHidden()
            }

            TextEditor(text: $note)
                .font(.caption)
                .frame(height: 72)
                .scrollContentBackground(.hidden)
                .padding(6)
                .background(AppTheme.elevated, in: RoundedRectangle(cornerRadius: 7))
                .overlay {
                    RoundedRectangle(cornerRadius: 7)
                        .stroke(AppTheme.stroke, lineWidth: 1)
                }

            HStack {
                Picker("상태", selection: $status) {
                    ForEach(FeatureStatus.allCases) { status in
                        Text(status.title).tag(status)
                    }
                }
                .labelsHidden()

                Spacer()

                Button(role: .destructive) {
                    store.deleteFeature(feature.id)
                } label: {
                    Image(systemName: "trash")
                }
                .buttonStyle(.borderless)
            }

            Text("수정 \(feature.updatedAt.formatted(date: .abbreviated, time: .shortened))")
                .font(.caption2)
                .foregroundStyle(AppTheme.secondaryText)
        }
        .padding(12)
        .background(AppTheme.elevated, in: RoundedRectangle(cornerRadius: 10))
        .overlay {
            RoundedRectangle(cornerRadius: 10)
                .stroke(AppTheme.stroke, lineWidth: 1)
        }
        .overlay(alignment: .leading) {
            UnevenRoundedRectangle(topLeadingRadius: 10, bottomLeadingRadius: 10)
                .fill(statusColor)
                .frame(width: 4)
        }
        .onChange(of: priority) { commit() }
        .onChange(of: status) { commit() }
        .onChange(of: note) { commit() }
        .onDisappear(perform: commit)
    }

    private var statusColor: Color {
        switch status {
        case .planned: AppTheme.accent
        case .review: Color(red: 0.86, green: 0.52, blue: 0.12)
        case .doing: Color(red: 0.20, green: 0.43, blue: 0.78)
        case .done: Color(red: 0.26, green: 0.56, blue: 0.34)
        case .hold: Color(red: 0.70, green: 0.28, blue: 0.23)
        }
    }

    private func commit() {
        store.updateFeature(feature.id) { item in
            item.title = title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? item.title : title
            item.targetVersion = targetVersion.trimmingCharacters(in: .whitespacesAndNewlines)
            item.priority = priority
            item.status = status
            item.note = note.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
}
