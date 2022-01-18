//
//  KeyChainQueryable.swift
//  Unsplash
//
//  Created by KimJaeYoun on 2021/12/20.
//

import Foundation

protocol KeyChainQueryable {
    var query: [String: Any] { get }
}
