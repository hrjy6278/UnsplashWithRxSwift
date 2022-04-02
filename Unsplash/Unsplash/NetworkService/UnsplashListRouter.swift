//
//  UnsplashListRouter.swift
//  Unsplash
//
//  Created by KimJaeYoun on 2022/04/01.
//

import Foundation
import Alamofire

enum UnsplashListRouter: CaseIterable {
    case listCollections
    case listPhotos
    case listTopic
    
    var baseURL: String {
        return "https://api.unsplash.com"
    }
    
    var path: String {
        switch self {
        case .listPhotos:
            return "/photos"
        case .listCollections:
            return "/collections"
        case .listTopic:
            return "/topics"
        }
    }
    
    var method: HTTPMethod {
        .get
    }
    
    var parameters: [String: String]? {
        return [:]
    }
}

extension UnsplashListRouter: URLRequestConvertible {
    func asURLRequest() throws -> URLRequest {
        guard let url = try baseURL.asURL()
            .appendingPathComponent(path)
            .appendingQueryParameters(parameters) else {
            throw URLError.invalidURL
        }
        return URLRequest(url: url)
    }
}
