//
//  UnsplashParameter.swift
//  Unsplash
//
//  Created by KimJaeYoun on 2021/12/20.
//

import Foundation

enum UnsplashParameter {
    enum Scope: String, CaseIterable {
        case pub = "public"
        case readUser = "read_user"
        case writeLikes = "write_likes"
        case readPhotos = "read_photos"
    }
    
    static let clientID = "UUGSJm9EzJM5tw1ngfNkKSn_OGW26g-O-z5FgLJEPPk"
    static let clientSecret = "zXsRvwnvw_55_XssA86y3ow-zqF0PIkOgzobdN5zewA"
    static let redirectURL = "jissCallback://"
    static let responseType = "code"
    static let scope = Scope.allCases
    static let grandType = "authorization_code"
}
