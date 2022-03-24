//
//  OAuthRouter.swift
//  Unsplash
//
//  Created by KimJaeYoun on 2022/03/24.
//

import Foundation
import Alamofire

enum OAuthRouter: URLRequestConvertible {
    case fetchAccessToken(accessCode: String)
    case userAuthorize
    
    var baseURL: String {
        return "https://unsplash.com"
    }
    
    var path: String {
        switch self {
        case .userAuthorize:
            return "/oauth/authorize"
        case .fetchAccessToken:
            return "/oauth/token"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .fetchAccessToken:
            return .post
        case .userAuthorize:
            return .get
        }
    }
    
    var parameters: [String: String] {
        switch self {
        case .userAuthorize:
            return [
                "client_id": OAuthParameter.clientID,
                "redirect_uri": OAuthParameter.redirectURL,
                "response_type": OAuthParameter.responseType,
                "scope": OAuthParameter.scope.map { $0.rawValue }.joined(separator: "+")
            ]
        case .fetchAccessToken(let code):
            return [
                "client_id": OAuthParameter.clientID,
                "client_secret": OAuthParameter.clientSecret,
                "redirect_uri": OAuthParameter.redirectURL,
                "code": code,
                "grant_type": OAuthParameter.grandType
            ]
        }
    }
    
    func asURLRequest() throws -> URLRequest {
        let url = try baseURL.asURL().appendingPathComponent(path)
        var request = URLRequest(url: url)
        request.method = method
        
        switch self {
        case .fetchAccessToken:
            request = try JSONParameterEncoder().encode(parameters,
                                                        into: request)
        default:
            let url = request.url?.appendingQueryParameters(parameters)
            request.url = url
        }
        
        return request
    }
}
