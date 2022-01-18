//
//  PasingManager.swift
//  Unsplash
//
//  Created by KimJaeYoun on 2021/12/17.
//

import Foundation

struct PasingManager {
    enum PasingError: Error {
        case decodeError
    }
    
    static func decode<T: Decodable>(type: T.Type, data: Data) throws -> T {
        let decoder = JSONDecoder()
        
        do {
            let decodedData = try decoder.decode(type, from: data)
            return decodedData
        } catch {
            throw PasingError.decodeError
        }
    }
}
