//
//  KeyChainStore.swift
//  Unsplash
//
//  Created by KimJaeYoun on 2021/12/20.
//

import Foundation
import Security
import RxSwift

struct KeyChainStore {
    enum KeyChainError: Error {
        case stringToDataConversionError
        case error(message: String)
    }
    
    //MARK: Properties
    private var queryable: KeyChainQueryable
    private(set) var isDeleteValue = BehaviorSubject<Bool>(value: false)
    
    //MARK: init
    init(queryable: KeyChainQueryable) {
        self.queryable = queryable
    }
}

//MARK: - Method
extension KeyChainStore {
    func setValue(_ value: String, for userAccount: String) throws {
        guard let encodedPassword = value.data(using: .utf8) else {
            throw KeyChainError.stringToDataConversionError
        }
        
        var query = self.queryable.query
        
        query[String(kSecAttrAccount)] = userAccount
        
        var status = SecItemCopyMatching(query as CFDictionary, nil)
        
        switch status {
        case errSecSuccess:
            var attributesToUpdate = [String: Any]()
            attributesToUpdate[String(kSecValueData)] = encodedPassword
            status = SecItemUpdate(query as CFDictionary, attributesToUpdate as CFDictionary)
            
        case errSecItemNotFound:
            query[String(kSecValueData)] = encodedPassword
            status = SecItemAdd(query as CFDictionary, nil)
        default:
            throw error(status: status)
        }
    }
    
    func getValue(for userAccount: String) throws -> String? {
        var query = self.queryable.query
        query[String(kSecMatchLimit)] = kSecMatchLimitOne
        query[String(kSecReturnAttributes)] = kCFBooleanTrue
        query[String(kSecReturnData)] = kCFBooleanTrue
        query[String(kSecAttrAccount)] = userAccount
        
        var queryResult: AnyObject?
        let status = withUnsafeMutablePointer(to: &queryResult) {
            SecItemCopyMatching(query as CFDictionary, $0)
        }
        
        switch status {
        case errSecSuccess:
            guard let queriedItem = queryResult as? [String: Any],
                  let passwordData = queriedItem[String(kSecValueData)] as? Data,
                  let password = String(data: passwordData, encoding: .utf8) else {
                      return nil
                  }
            return password
        case errSecItemNotFound:
            return nil
        default:
            throw error(status: status)
        }
    }
    
    func removeValue(for userAccount: String) {
        var query = queryable.query
        query[String(kSecAttrAccount)] = userAccount
        
        SecItemDelete(query as CFDictionary)
        isDeleteValue.onNext(true)
        isDeleteValue.onCompleted()
    }
    
    func removeAll() {
        let query = queryable.query
        
        SecItemDelete(query as CFDictionary)
        isDeleteValue.onNext(true)
        isDeleteValue.onCompleted()
    }
    
    func isKeySaved(for userAccount: String) -> Observable<Bool> {
        return Observable.create { observer in
            if let _ = try? getValue(for: userAccount) {
                observer.onNext(true)
            } else {
                observer.onNext(false)
            }
            observer.onCompleted()
            
            return Disposables.create()
        }
    }
    
    private func error(status: OSStatus) -> KeyChainError {
        let errorMessage = SecCopyErrorMessageString(status, nil) as String? ?? ""
        
        return KeyChainError.error(message: errorMessage)
    }
}
