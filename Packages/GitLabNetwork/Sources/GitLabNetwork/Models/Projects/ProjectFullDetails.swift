/// Full project model with all details
public struct ProjectFullDetails: Sendable, Codable, Identifiable, Equatable {
    public let preview: ProjectPreview
    public let readme: String?
    public let languages: [ProjectLanguage]
    public let openIssuesCount: Int
    public let openMergeRequestsCount: Int
    public let licenseInfo: LicenseInfo?
    public let statistics: ProjectStatistics?
    
    public init(
        preview: ProjectPreview,
        readme: String?,
        languages: [ProjectLanguage],
        openIssuesCount: Int,
        openMergeRequestsCount: Int,
        licenseInfo: LicenseInfo?,
        statistics: ProjectStatistics?
    ) {
        self.preview = preview
        self.readme = readme
        self.languages = languages
        self.openIssuesCount = openIssuesCount
        self.openMergeRequestsCount = openMergeRequestsCount
        self.licenseInfo = licenseInfo
        self.statistics = statistics
    }
    
    public var id: String { preview.id }
}
