import Foundation

enum FeatureStatus: String, Codable, CaseIterable, Identifiable {
    case planned
    case review
    case doing
    case done
    case hold

    var id: String { rawValue }

    var title: String {
        switch self {
        case .planned: "구현할 기능"
        case .review: "검토 중"
        case .doing: "진행 중"
        case .done: "구현됨"
        case .hold: "보류"
        }
    }
}

enum FeaturePriority: String, Codable, CaseIterable, Identifiable {
    case high
    case medium
    case low

    var id: String { rawValue }

    var title: String {
        switch self {
        case .high: "높음"
        case .medium: "보통"
        case .low: "낮음"
        }
    }

    var sortWeight: Int {
        switch self {
        case .high: 3
        case .medium: 2
        case .low: 1
        }
    }
}

struct ManagedApp: Identifiable, Codable, Equatable {
    var id: UUID
    var name: String
    var features: [FeatureItem]

    init(id: UUID = UUID(), name: String, features: [FeatureItem] = []) {
        self.id = id
        self.name = name
        self.features = features
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case features
    }
}

struct FeatureItem: Identifiable, Codable, Equatable {
    var id: UUID
    var title: String
    var status: FeatureStatus
    var priority: FeaturePriority
    var targetVersion: String
    var note: String
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        title: String,
        status: FeatureStatus = .planned,
        priority: FeaturePriority = .medium,
        targetVersion: String = "",
        note: String = "",
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.status = status
        self.priority = priority
        self.targetVersion = targetVersion
        self.note = note
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

struct AppState: Codable {
    var selectedAppID: UUID?
    var widgetAppLimit: Int?
    var apps: [ManagedApp]
}
