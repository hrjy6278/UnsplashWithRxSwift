//
//  UnsplashInterceptor.swift
//  Unsplash
//
//  Created by KimJaeYoun on 2021/12/20.
//

import Foundation
import Alamofire

final class UnsplashInterceptor: RequestInterceptor {
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var request = urlRequest
        
        if let token = try? TokenManager.shared.fetchAcessToken() {
            request.setValue("Bearer \(token)",
                             forHTTPHeaderField: "Authorization")
        } else {
            request.setValue("Client-ID \(OAuthParameter.clientID)",
                             forHTTPHeaderField: "Authorization")
        }
        
        completion(.success(request))
    }
}
