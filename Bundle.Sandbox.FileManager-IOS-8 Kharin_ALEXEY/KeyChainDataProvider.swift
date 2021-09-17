import Foundation
import KeychainAccess

protocol DataProvider {
    
    func save(account: String, password: String)
    
    func obtains() -> [String]
    
    func obtain(account: String) -> String
    
    func remove(object: String)
    
}


class KeyChainDataProvider: DataProvider {
    let keychain = Keychain(service: KeychainConfiguration.serviceName)
    
    func obtain(account: String) -> String {
        guard let value = keychain[account] else { return " "}
        return value
    }
   
    func obtains() -> [String] {
        return keychain.allKeys()
    }
    
    func remove(object: String) {
        do {
            try keychain.remove(object)
        } catch {
            fatalError("Error updating keychain - \(error)")
        }
    }
    
    func save(account: String, password: String) {
        keychain[account] = password
    }
}
