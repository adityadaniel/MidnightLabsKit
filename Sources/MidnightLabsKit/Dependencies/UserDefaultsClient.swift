import Dependencies
import DependenciesMacros
import Foundation

extension DependencyValues {
    public var userDefaults: UserDefaultsClient {
        get { self[UserDefaultsClient.self] }
        set { self[UserDefaultsClient.self] = newValue }
    }
}

public struct UserDefaultsClient {
    public var boolForKey: @Sendable (String) -> Bool = { _ in false }
    public var dataForKey: @Sendable (String) -> Data?
    public var doubleForKey: @Sendable (String) async -> Double = { _ in 0 }
    public var integerForKey: @Sendable (String) async -> Int = { _ in 0 }
    public var remove: @Sendable (String) async -> Void
    public var setBool: @Sendable (Bool, String) async -> Void
    public var setData: @Sendable (Data?, String) async -> Void
    public var setDouble: @Sendable (Double, String) async -> Void
    public var setInteger: @Sendable (Int, String) async -> Void
    
    public init(
        boolForKey: @escaping (String) -> Bool,
        dataForKey: @escaping (String) -> Data?,
        doubleForKey: @escaping (String) -> Double,
        integerForKey: @escaping (String) -> Int,
        remove: @escaping (String) -> Void,
        setBool: @escaping (Bool, String) -> Void,
        setData: @escaping (Data?, String) -> Void,
        setDouble: @escaping (Double, String) -> Void,
        setInteger: @escaping (Int, String) -> Void
    ) {
        self.boolForKey = boolForKey
        self.dataForKey = dataForKey
        self.doubleForKey = doubleForKey
        self.integerForKey = integerForKey
        self.remove = remove
        self.setBool = setBool
        self.setData = setData
        self.setDouble = setDouble
        self.setInteger = setInteger
    }
}

extension UserDefaultsClient: TestDependencyKey {
    public static let previewValue = Self.noop
    public static let testValue = Self.noop
}

extension UserDefaultsClient {
    public static let noop = Self(
        boolForKey: { _ in false },
        dataForKey: { _ in nil },
        doubleForKey: { _ in 0 },
        integerForKey: { _ in 0 },
        remove: { _ in },
        setBool: { _, _ in },
        setData: { _, _ in },
        setDouble: { _, _ in },
        setInteger: { _, _ in }
    )
}
