//
//  UnsplashAccessToken.swift
//  Unsplash
//
//  Created by KimJaeYoun on 2021/12/20.
//

import Foundation

struct UnsplashAccessToken: Decodable {
    let accessToken: String
    let tokenType: String
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
    }
}
