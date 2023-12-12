import StoreKit
import Dependencies

public struct AppStoreReviewClient {
    public var askForReview: () -> Void
    public var writeReview: (URL) async -> Bool
}

extension DependencyValues {
    public var storeReview: AppStoreReviewClient {
        get { self[AppStoreReviewClient.self] }
        set { self[AppStoreReviewClient.self] = newValue }
    }
}

extension AppStoreReviewClient: DependencyKey {
    public static let liveValue: AppStoreReviewClient = AppStoreReviewClient(
        askForReview: {
            guard let scene = UIApplication.shared.connectedScenes
                .first(where: { $0 is UIWindowScene }) as? UIWindowScene else { return }
            SKStoreReviewController.requestReview(in: scene)
        },
        writeReview: { url in
            await UIApplication.shared.open(url)
        }
    )
}
