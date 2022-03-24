//
//  UnsplashRouter.swift
//  Unsplash
//
//  Created by KimJaeYoun on 2021/12/20.
//

import Foundation
import Alamofire

enum UnsplashRouter {
    case searchPhotos(query: String, page: Int)
    case photoLike(id: String)
    case photoUnlike(id: String)
    case myProfile
    case userLikePhotos(userName: String, page: Int)
    case updateProfile(UpdateProfile)
    case randomPhoto
    
    var baseURL: String {
        return "https://api.unsplash.com"
    }
    
    var path: String {
        switch self {
        case .searchPhotos:
            return "/search/photos"
        case .photoLike (let id), .photoUnlike(let id):
            return "/photos/\(id)/like"
        case .userLikePhotos(let userName, _):
            return "/users/\(userName)/likes"
        case .myProfile, .updateProfile:
            return "/me"
        case .randomPhoto:
            return "/photos/random"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .searchPhotos,.myProfile, .userLikePhotos, .randomPhoto:
            return .get
        case .photoLike:
            return .post
        case .photoUnlike:
            return .delete
        case .updateProfile:
            return .put
        }
    }
    
    var parameters: [String: String]? {
        switch self {
        case .searchPhotos(let query, let page):
            return [
                "page": String(page),
                "query": query
            ]
        case .userLikePhotos(_, let page):
            return [
                "page": String(page)
            ]
        case .updateProfile(let profile):
            return [
                "username": profile.userName,
                "first_name": profile.firstName,
                "last_name": profile.lastName,
                "location": profile.location,
                "bio": profile.bio
            ]
        case .randomPhoto:
            return [
                "count": "1",
                "query": "universe"
            ]
        default:
            return [:]
        }
    }
}

enum URLError: Error {
    case invalidURL
}

//MARK: - Method
extension UnsplashRouter: URLRequestConvertible {
    func asURLRequest() throws -> URLRequest {
        guard let url = try baseURL.asURL()
            .appendingPathComponent(path)
            .appendingQueryParameters(parameters) else {
            throw URLError.invalidURL
        }
        return URLRequest(url: url)
    }
}
