import Dependencies
#if canImport(MessageUI)
    import MessageUI
#endif

public struct BuildInfoClient {
    public var getBuildNumber: () -> String
    public var getVersion: () -> String
    public var canSendEmail: () -> Bool
}

extension BuildInfoClient: DependencyKey {
    public static let liveValue: BuildInfoClient = .init(
        getBuildNumber: {
            Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""
        }, getVersion: {
            Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        }, canSendEmail: {
            MFMailComposeViewController.canSendMail()
        }
    )
    
    public static let testValue: BuildInfoClient = .init(
        getBuildNumber: { "42" },
        getVersion: { "69" },
        canSendEmail: { true }
    )
}

extension DependencyValues {
    public var buildInfo: BuildInfoClient {
        get { self[BuildInfoClient.self] }
        set { self[BuildInfoClient.self] = newValue }
    }
}
