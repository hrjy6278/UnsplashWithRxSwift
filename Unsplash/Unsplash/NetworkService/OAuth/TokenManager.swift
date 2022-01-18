//
//  TokenManager.swift
//  Unsplash
//
//  Created by KimJaeYoun on 2021/12/20.
//

import Foundation

final class TokenManager {
    enum TokenManagerError: Error {
        case saveError(message: String)
        case fetchError(message: String)
    }
    
    //MARK: Properties
    private let userAccount = "accessToken"
    private var keyChaineStore = KeyChainStore(queryable: TokenQuery())
    
    var isTokenSaved: Bool {
        return keyChaineStore.isKeySaved(for: userAccount) ? true : false
    }
    
    static let shared = TokenManager()
    
    //MARK: init
    private init() {
        keyChaineStore.delegate = self
    }
}

//MARK: - Method
extension TokenManager {
    func saveAccessToken(unsplashToken: UnsplashAccessToken) throws {
        do {
            try keyChaineStore.setValue(unsplashToken.accessToken, for: userAccount)
        } catch let error {
            throw TokenManagerError.saveError(message: error.localizedDescription)
        }
    }
    
    func fetchAcessToken() throws -> String? {
        do {
            let token = try keyChaineStore.getValue(for: userAccount)
            return token
        } catch let error {
            throw TokenManagerError.fetchError(message: error.localizedDescription)
        }
    }
    
    func clearAccessToken() {
        keyChaineStore.removeValue(for: userAccount)
    }
}

//MARK: - KeyChain Store Delegate
extension TokenManager: KeyChainStoreDelegate {
    func didFinishedDeleteValue() {
        NotificationCenter.default.post(name: .didFinishedDeleteKeyChainValue, object: nil)
    }
}
