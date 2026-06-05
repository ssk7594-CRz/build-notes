import Foundation
import SwiftUI

@MainActor
final class AppStore: ObservableObject {
    @Published var apps: [ManagedApp] = []
    @Published var selectedAppID: UUID?
    @Published var selectedFeatureID: UUID?
    @Published var searchText = ""
    @Published var focusQuickCapture = false
    @Published var focusSearch = false
    @Published var widgetAppLimit = 3

    private let persistenceURL: URL

    init() {
        let support = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? FileManager.default.homeDirectoryForCurrentUser
        let directory = support.appendingPathComponent("BuildNotes", isDirectory: true)
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        persistenceURL = directory.appendingPathComponent("data.json")
        load()
    }

    var selectedApp: ManagedApp? {
        guard let selectedAppID else { return apps.first }
        return apps.first { $0.id == selectedAppID } ?? apps.first
    }

    var selectedFeature: FeatureItem? {
        guard let selectedFeatureID, let app = selectedApp else { return nil }
        return app.features.first { $0.id == selectedFeatureID }
    }

    var widgetApps: [ManagedApp] {
        Array(apps.prefix(widgetAppLimit))
    }

    func setWidgetAppLimit(_ limit: Int) {
        widgetAppLimit = min(max(limit, 1), 5)
        save()
    }

    func addApp(named name: String) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let app = ManagedApp(name: trimmed)
        apps.append(app)
        selectedAppID = app.id
        selectedFeatureID = nil
        save()
    }

    func deleteSelectedApp() {
        guard let selectedAppID else { return }
        apps.removeAll { $0.id == selectedAppID }
        self.selectedAppID = apps.first?.id
        selectedFeatureID = nil
        save()
    }

    func updateSelectedAppName(_ name: String) {
        updateSelectedApp { app in
            app.name = name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? app.name : name
        }
    }

    func addFeature(title: String, status: FeatureStatus, priority: FeaturePriority, targetVersion: String) {
        guard let appID = selectedApp?.id else { return }
        addFeature(to: appID, title: title, status: status, priority: priority, targetVersion: targetVersion)
    }

    func addFeature(to appID: UUID, title: String, status: FeatureStatus, priority: FeaturePriority, targetVersion: String) {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        guard let appIndex = apps.firstIndex(where: { $0.id == appID }) else { return }

        let feature = FeatureItem(
            title: trimmed,
            status: status,
            priority: priority,
            targetVersion: targetVersion.trimmingCharacters(in: .whitespacesAndNewlines)
        )

        apps[appIndex].features.append(feature)
        selectedAppID = appID
        selectedFeatureID = feature.id
        save()
    }

    func addFeature(title: String, status: FeatureStatus, priority: FeaturePriority, targetVersion: String, note: String) {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        updateSelectedApp { app in
            let feature = FeatureItem(
                title: trimmed,
                status: status,
                priority: priority,
                targetVersion: targetVersion.trimmingCharacters(in: .whitespacesAndNewlines),
                note: note.trimmingCharacters(in: .whitespacesAndNewlines)
            )
            app.features.append(feature)
            selectedFeatureID = feature.id
        }
    }

    func updateFeature(_ featureID: UUID, mutate: (inout FeatureItem) -> Void) {
        guard let appIndex = selectedAppIndex,
              let featureIndex = apps[appIndex].features.firstIndex(where: { $0.id == featureID }) else {
            return
        }

        mutate(&apps[appIndex].features[featureIndex])
        apps[appIndex].features[featureIndex].updatedAt = Date()
        save()
    }

    func deleteFeature(_ featureID: UUID) {
        updateSelectedApp { app in
            app.features.removeAll { $0.id == featureID }
            if selectedFeatureID == featureID {
                selectedFeatureID = nil
            }
        }
    }

    func toggleFeatureCompletion(appID: UUID, featureID: UUID) {
        guard let appIndex = apps.firstIndex(where: { $0.id == appID }),
              let featureIndex = apps[appIndex].features.firstIndex(where: { $0.id == featureID }) else {
            return
        }

        apps[appIndex].features[featureIndex].status = apps[appIndex].features[featureIndex].status == .done ? .planned : .done
        apps[appIndex].features[featureIndex].updatedAt = Date()
        save()
    }

    func visibleFeatures(in app: ManagedApp, completed: Bool) -> [FeatureItem] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        return app.features
            .filter { completed ? $0.status == .done : $0.status != .done }
            .filter { feature in
                guard !query.isEmpty else { return true }
                return [
                    feature.title,
                    feature.note,
                    feature.targetVersion,
                    feature.status.title,
                    feature.priority.title,
                    app.name,
                ]
                .joined(separator: " ")
                .lowercased()
                .contains(query)
            }
            .sorted { lhs, rhs in
                if lhs.priority.sortWeight != rhs.priority.sortWeight {
                    return lhs.priority.sortWeight > rhs.priority.sortWeight
                }
                return lhs.updatedAt > rhs.updatedAt
            }
    }

    func features(for status: FeatureStatus) -> [FeatureItem] {
        guard let selectedApp else { return [] }
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        return selectedApp.features
            .filter { $0.status == status }
            .filter { feature in
                guard !query.isEmpty else { return true }
                return [
                    feature.title,
                    feature.note,
                    feature.targetVersion,
                    feature.status.title,
                    feature.priority.title,
                ]
                .joined(separator: " ")
                .lowercased()
                .contains(query)
            }
            .sorted { lhs, rhs in
                if lhs.priority.sortWeight != rhs.priority.sortWeight {
                    return lhs.priority.sortWeight > rhs.priority.sortWeight
                }
                return lhs.updatedAt > rhs.updatedAt
            }
    }

    func exportJSON() -> URL? {
        save()
        return persistenceURL
    }

    func importJSON(from url: URL) {
        let didAccess = url.startAccessingSecurityScopedResource()
        defer {
            if didAccess {
                url.stopAccessingSecurityScopedResource()
            }
        }

        guard let data = try? Data(contentsOf: url),
              let imported = try? JSONDecoder.buildNotes.decode(AppState.self, from: data) else {
            return
        }

        apps = imported.apps
        selectedAppID = imported.selectedAppID ?? apps.first?.id
        selectedFeatureID = nil
        save()
    }

    private var selectedAppIndex: Int? {
        guard let selectedAppID else { return apps.indices.first }
        return apps.firstIndex { $0.id == selectedAppID } ?? apps.indices.first
    }

    private func updateSelectedApp(_ mutate: (inout ManagedApp) -> Void) {
        guard let index = selectedAppIndex else { return }
        mutate(&apps[index])
        save()
    }

    private func load() {
        if let data = try? Data(contentsOf: persistenceURL),
           let state = try? JSONDecoder.buildNotes.decode(AppState.self, from: data),
           !state.apps.isEmpty {
            apps = state.apps
            selectedAppID = state.selectedAppID ?? state.apps.first?.id
            widgetAppLimit = min(max(state.widgetAppLimit ?? 3, 1), 5)
            return
        }

        let sample = ManagedApp(
            name: "샘플 앱",
            features: [
                FeatureItem(
                    title: "배포 후 떠오른 기능을 빠르게 적는 인박스",
                    status: .planned,
                    priority: .high,
                    targetVersion: "v1.0",
                    note: "생각나는 즉시 적는 흐름이 핵심."
                ),
                FeatureItem(
                    title: "구현된 기능과 구현할 기능을 한눈에 구분",
                    status: .done,
                    priority: .medium,
                    targetVersion: "v1.0"
                ),
                FeatureItem(
                    title: "완료 기능 접어두고 흐름 확인하기",
                    status: .review,
                    priority: .medium,
                    targetVersion: "v1.2",
                    note: "필요할 때만 펼쳐 히스토리처럼 보기."
                ),
            ]
        )
        apps = [sample]
        selectedAppID = sample.id
        save()
    }

    private func save() {
        let state = AppState(selectedAppID: selectedAppID, widgetAppLimit: widgetAppLimit, apps: apps)
        guard let data = try? JSONEncoder.buildNotes.encode(state) else { return }
        try? data.write(to: persistenceURL, options: [.atomic])
    }
}

private extension JSONEncoder {
    static var buildNotes: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }
}

private extension JSONDecoder {
    static var buildNotes: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
}
