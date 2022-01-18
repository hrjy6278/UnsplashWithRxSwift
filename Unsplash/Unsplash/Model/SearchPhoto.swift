//
//  SearchPhoto.swift
//  Unsplash
//
//  Created by KimJaeYoun on 2021/12/18.
//

import Foundation
import SwiftUI

struct SearchPhoto: Decodable {
    let total: Int
    let totalPages: Int
    let photos: [Photo]
    
    enum CodingKeys: String, CodingKey {
        case total
        case photos = "results"
        case totalPages = "total_pages"
    }
}

struct Photo: Decodable {
    let id: String
    let createdAt: String
    let description: String?
    let profile: Profile
    var likes: Int
    var isUserLike: Bool
    let urls: Urls
    let links: Link
    
    enum CodingKeys: String, CodingKey {
        case id, description, urls, links, likes
        case profile = "user"
        case createdAt = "created_at"
        case isUserLike = "liked_by_user"
    }
}

struct Link: Decodable {
    let linksSelf, html, download : String?
    
    enum CodingKeys: String, CodingKey {
        case html, download
        case linksSelf = "self"
    }
}

struct Urls: Decodable {
    let raw, full, regular, small, thumb: String
    
    var regularURL: URL? {
        URL(string: regular)
    }
}
