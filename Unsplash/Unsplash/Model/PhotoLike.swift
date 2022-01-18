//
//  PhotoLike.swift
//  Unsplash
//
//  Created by KimJaeYoun on 2021/12/21.
//

import Foundation

struct PhotoLike: Decodable {
    let photo: Photo
    let user: Profile
}
