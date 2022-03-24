//
//  UnsplashOAuthManger.swift
//  Unsplash
//
//  Created by KimJaeYoun on 2022/03/24.
//

import Foundation
import RxSwift
import Alamofire

final class OAuthManager {
    private let sessionManager: Session = {
        let interceptor = UnsplashInterceptor()
        let session = Session(interceptor: interceptor)
        
        return session
    }()
    
    func fetchAccessToken(accessCode: String) -> Observable<Bool> {
        return Observable.create { observer in
            self.sessionManager.request(OAuthRouter.fetchAccessToken(accessCode: accessCode)).responseDecodable(of: UnsplashAccessToken.self) { reponseJson in
                guard let token = reponseJson.value else {
                    observer.onNext(false)
                    return
                }
                
                do {
                    try TokenManager.shared.saveAccessToken(unsplashToken: token)
                    observer.onNext(true)
                    observer.onCompleted()
                } catch (let saveError) {
                    observer.onError(saveError)
                }
            }
            
            return Disposables.create()
        }
    }
}
