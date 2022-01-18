//
//  Extension + Int.swift
//  Unsplash
//
//  Created by KimJaeYoun on 2021/12/24.
//

import Foundation

extension Int {
    static let initialPage = 1
    
    mutating func addPage() {
        self += 1
    }
}
