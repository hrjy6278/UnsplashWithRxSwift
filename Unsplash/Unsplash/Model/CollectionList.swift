//
//  Collections.swift
//  Unsplash
//
//  Created by KimJaeYoun on 2022/04/01.
//

import Foundation

protocol ListModelType: Decodable {
    var id: String? { get }
    var title: String? { get }
    var description: String? { get }
    var publishedAt: String? { get }
    var lastCollectedAt: String? { get }
    var updatedAt: String? { get }
    var totalPhotos: Int? { get }
    var collectionPrivate: Bool? { get }
    var shareKey: String? { get }
    var coverPhoto: Photo? { get }
    var user: Profile? { get }
    var URL: Urls? { get }
}

struct CollectionList: ListModelType {
    let id: String?
    let title: String?
    let description: String?
    let publishedAt: String?
    let lastCollectedAt: String?
    let updatedAt: String?
    let totalPhotos: Int?
    let collectionPrivate: Bool?
    let shareKey: String?
    let coverPhoto: Photo?
    let user: Profile?
    let URL: Urls?
    
    
    enum CodingKeys: String, CodingKey {
        case id, title, description, user
        case publishedAt = "published_at"
        case lastCollectedAt = "last_collected_at"
        case updatedAt = "updated_at"
        case totalPhotos = "total_photos"
        case collectionPrivate = "private"
        case shareKey = "share_key"
        case coverPhoto = "cover_photo"
        case URL = "urls"
    }
}
