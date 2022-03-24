//
//  UnsplashParameter.swift
//  Unsplash
//
//  Created by KimJaeYoun on 2021/12/20.
//

import Foundation

enum OAuthParameter {
    enum Scope: String, CaseIterable {
        case pub = "public"
        case readUser = "read_user"
        case writeLikes = "write_likes"
        case readPhotos = "read_photos"
        case wirteUser = "write_user"
    }
    
    static let clientID = Bundle.main.infoDictionary?["UNSPLASH_CLIENT_KEY"] as? String ?? ""
    static let clientSecret = Bundle.main.infoDictionary?["UNSPLASH_SECERET_KEY"] as? String ?? ""
    static let redirectURL = "jissCallback://"
    static let responseType = "code"
    static let scope = Scope.allCases
    static let grandType = "authorization_code"
}
