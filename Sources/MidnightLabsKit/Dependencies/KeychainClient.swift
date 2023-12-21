import Foundation
import OSLog
import Dependencies

public struct KeychainClient {
    public typealias Account = String
    public typealias Service = String
    
    public struct Payload {
        let account: KeychainClient.Account
        let service: KeychainClient.Service
        let data: Data
        
        public init(account: KeychainClient.Account, service: KeychainClient.Service, data: Data) {
            self.account = account
            self.service = service
            self.data = data
        }
    }
    
    public var add: (KeychainClient.Payload) -> Void
    public var get: (KeychainClient.Payload) -> Data?
    public var delete: (KeychainClient.Payload) -> Void
    
    internal static let logger = Logger(subsystem: "Keychain", category: "KeychainClient")
    
    public static func decode<T: Decodable>(data: Data, as type: T.Type) -> T? {
        return try? JSONDecoder().decode(type, from: data)
    }
    
    public static func encode<T: Encodable>(type: T) -> Data? {
        return try? JSONEncoder().encode(type)
    }
}

extension KeychainClient: DependencyKey {
    public static let liveValue: KeychainClient = KeychainClient(
        add: { payload in
            let query = [
                kSecClass: kSecClassGenericPassword,
                kSecAttrAccount: payload.account,
                kSecAttrService: payload.service,
                kSecValueData: payload.data
            ] as CFDictionary
            
            let status = SecItemAdd(query, nil)
            
            if status == errSecDuplicateItem {
                // Item already exist, thus update it.
                let query = [
                    kSecAttrAccount: payload.account,
                    kSecAttrService: payload.service,
                    kSecClass: kSecClassGenericPassword,
                ] as CFDictionary
                
                let attributesToUpdate = [kSecValueData: payload.data] as CFDictionary
                
                // Update existing item
                SecItemUpdate(query, attributesToUpdate)
            }
        },
        get: { payload in
            let query = [
                kSecClass: kSecClassGenericPassword,
                kSecAttrAccount: payload.account,
                kSecAttrService: payload.service,
                kSecReturnData: true
            ] as CFDictionary
            
            var result: AnyObject?
            let status = SecItemCopyMatching(query, &result)
            
            guard status == errSecSuccess else { return nil }
            guard let data = result as? Data else { return nil }
            return data
        },
        delete: { payload in
            let query = [
                kSecClass: kSecClassGenericPassword,
                kSecAttrAccount: payload.account,
                kSecAttrService: payload.service,
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
