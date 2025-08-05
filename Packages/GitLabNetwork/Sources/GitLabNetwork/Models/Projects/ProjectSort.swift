public enum ProjectSort: String, Sendable, CaseIterable {
    case relevance = "relevance"
    case stars = "stars"
    case updated = "updated_at"
    case created = "created_at"
    case name = "name"
    case lastActivity = "last_activity_at"
}
