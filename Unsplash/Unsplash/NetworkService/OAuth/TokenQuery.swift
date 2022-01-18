//
//  TokenQuery.swift
//  Unsplash
//
//  Created by KimJaeYoun on 2021/12/20.
//

import Foundation

struct TokenQuery: KeyChainQueryable {
    var query: [String : Any] = [
        String(kSecClass): kSecClassGenericPassword,
        String(kSecAttrService): "UnsplashService"
    ]
}
