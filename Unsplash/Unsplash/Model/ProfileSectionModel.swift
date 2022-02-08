//
//  ProfileCellModel.swift
//  Unsplash
//
//  Created by KimJaeYoun on 2022/02/07.
//

import Foundation
import RxDataSources

enum ProfileSectionModel {
    case profile(items: [ProfileItem])
    case photos(items: [ProfileItem])
}

enum ProfileItem {
    case profile(Profile)
    case photo(Photo)
}

extension ProfileSectionModel: SectionModelType {
    typealias Item = ProfileItem
    
    var items: [ProfileItem] {
        switch self {
        case .photos(let items):
            return items.map { $0 }
        case .profile(let items):
            return items.map { $0 }
        }
    }
    
    init(original: ProfileSectionModel, items: [Item]) {
        switch original {
        case .profile:
            self = .profile(items: items)
        case .photos:
            self = .photos(items: items)
        }
    }
}
