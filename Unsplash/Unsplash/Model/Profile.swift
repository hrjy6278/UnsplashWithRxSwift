//
//  Profile.swift
//  Unsplash
//
//  Created by KimJaeYoun on 2021/12/22.
//

import Foundation

struct Profile: Decodable {
    let id: String
    let userName: String
    let name: String
    let profileImage: SelfieImage?
    let totalLikes: Int
    let totalPhotos: Int
    let totalCollections: Int
    
    enum CodingKeys: String, CodingKey {
        case id,name
        case profileImage = "profile_image"
        case userName = "username"
        case totalLikes = "total_likes"
        case totalPhotos = "total_photos"
        case totalCollections = "total_collections"
    }
}

struct SelfieImage: Codable {
    let small, medium, large: String
    
    var mediumURL: URL? {
        URL(string: medium)
    }
}
