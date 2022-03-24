//
//  TokenManager.swift
//  Unsplash
//
//  Created by KimJaeYoun on 2021/12/20.
//

import Foundation
import RxSwift

final class TokenManager {
    enum TokenManagerError: Error {
        case saveError(message: String)
        case fetchError(message: String)
    }
    
    //MARK: Properties
    private let userAccount = "accessToken"
    private let keyChaineStore = KeyChainStore(queryable: TokenQuery())
    private let disposeBag = DisposeBag()
    
    var isTokenSaved = BehaviorSubject<Bool>(value: false)
    
    static let shared = TokenManager()
    
    //MARK: init
    private init() {
        let isTokenSaved = self.keyChaineStore.isValueSaved(for: self.userAccount)
        self.isTokenSaved.onNext(isTokenSaved)
    }
}

//MARK: - Method
extension TokenManager {
    func saveAccessToken(unsplashToken: UnsplashAccessToken) throws {
        do {
            try keyChaineStore.setValue(unsplashToken.accessToken, for: userAccount)
            let isTokenSaved = self.keyChaineStore.isValueSaved(for: self.userAccount)
            self.isTokenSaved.onNext(isTokenSaved)
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
        let isTokenSaved = self.keyChaineStore.isValueSaved(for: userAccount)
        self.isTokenSaved.onNext(isTokenSaved)
    }
}
