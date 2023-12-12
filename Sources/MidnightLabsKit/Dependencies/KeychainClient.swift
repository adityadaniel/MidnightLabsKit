import Foundation
import OSLog
import Dependencies

public struct KeychainClient {
  public var add: (String) -> Void
  public var get: (String) -> String?
  public var delete: (String) -> Void
  
  internal static let service = "iAP"
  internal static let account = "Snapped"
  
  public enum Keys {
    public static let subscriptions = "subs"
  }
  
  static let logger = Logger(subsystem: "Keychain", category: "KeychainClient")
}

extension KeychainClient: DependencyKey {
    public static let liveValue: KeychainClient = KeychainClient(
    add: { key in
      guard let data = try? JSONEncoder().encode(key) else {
        KeychainClient.logger.log(level: .debug, "Cannot encode")
        return
      }
      let query = [
        kSecClass: kSecClassGenericPassword,
        kSecAttrAccount: KeychainClient.account,
        kSecAttrService: KeychainClient.service,
        kSecValueData: data
      ] as CFDictionary
      
      let status = SecItemAdd(query, nil)
      
      if status == errSecDuplicateItem {
        // Item already exist, thus update it.
        let query = [
          kSecAttrService: KeychainClient.service,
          kSecAttrAccount: KeychainClient.account,
          kSecClass: kSecClassGenericPassword,
        ] as CFDictionary
        
        let attributesToUpdate = [kSecValueData: data] as CFDictionary
        
        // Update existing item
        SecItemUpdate(query, attributesToUpdate)
      }
    },
    get: { key in
      let query = [
        kSecClass: kSecClassGenericPassword,
        kSecAttrAccount: KeychainClient.account,
        kSecAttrService: KeychainClient.service,
        kSecReturnData: true
      ] as CFDictionary
      
      var result: AnyObject?
      let status = SecItemCopyMatching(query, &result)
      
      guard status == errSecSuccess else { return nil }
      guard let data = result as? Data else { return nil }
      return try? JSONDecoder().decode(String.self, from: data)
    },
    delete: { key in
      let query = [
        kSecClass: kSecClassGenericPassword,
        kSecAttrAccount: KeychainClient.account,
        kSecAttrService: KeychainClient.service,
        kSecReturnData: true
      ] as CFDictionary
      
      SecItemDelete(query)
    }
  )
}


extension DependencyValues {
  public var keychainClient: KeychainClient {
    get { self[KeychainClient.self] }
    set { self[KeychainClient.self] = newValue }
  }
}
