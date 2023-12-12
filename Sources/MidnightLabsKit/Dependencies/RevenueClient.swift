import RevenueCat
import StoreKit
import Dependencies
import DependenciesMacros

@DependencyClient
public struct RevenueClient {
    public var initialize: () -> Void
    public var getOfferings: () async throws -> Offerings
    public var purchase: (Package) async throws -> StoreTransaction
    public var restorePurchase: () async throws -> CustomerInfo
}

extension RevenueClient: DependencyKey {
  public static let liveValue: RevenueClient = RevenueClient(
    initialize: {
      Purchases.logLevel = .debug
      Purchases.configure(withAPIKey: "appl_JrZtHWUrBMlHyOtBdXCoKFIbiDE")
    },
    getOfferings: {
      try await Purchases.shared.offerings()
    },
    purchase: { package in
      let (transaction, userInfo, isCancelled) = try await Purchases.shared.purchase(package: package)
      
      if isCancelled {
        throw RevenueError.userCancelled
      }
      
      guard let t = transaction else {
        throw RevenueError.nilTransaction
      }
      return t
    },
    restorePurchase: {
      try await Purchases.shared.restorePurchases()
    }
  )
}

public enum RevenueError: Error {
  case userCancelled
  case nilTransaction
}

extension DependencyValues {
  public var revenueClient: RevenueClient {
    get { self[RevenueClient.self] }
    set { self[RevenueClient.self] = newValue }
  }
}
