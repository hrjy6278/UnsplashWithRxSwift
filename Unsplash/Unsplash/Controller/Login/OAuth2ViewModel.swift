//
//  OAuth2ViewModel.swift
//  Unsplash
//
//  Created by KimJaeYoun on 2022/01/19.
//

import Foundation
import RxSwift
import AuthenticationServices

final class OAuth2ViewModel: NSObject, ViewModelType {
    private var authSession: ASWebAuthenticationSession?
    private let networkService = UnsplashAPIManager()
    private let disposeBag = DisposeBag()
    
    private var isLogin = PublishSubject<Bool>()

    struct Input {
        let viewDidAppear: Observable<Void>
    }
    
    struct Output {
        let tryLoginResult: Observable<Bool>
    }
    
}

extension OAuth2ViewModel {
    func bind(input: Input) -> Output {
        input.viewDidAppear
            .withUnretained(self)
            .subscribe(onNext: { `self`, _ in `self`.authenticate() })
            .disposed(by: disposeBag)
            
        return Output(tryLoginResult: isLogin.asObservable())
    }
    
    private func authenticate() {
        guard let URL = try? UnsplashRouter.userAuthorize.asURLRequest().url else { return }
        let callbackURLScheme = "jissCallback"
        
        authSession = ASWebAuthenticationSession(
            url: URL,
            callbackURLScheme: callbackURLScheme,
            completionHandler: { [weak self] callbackURL, error in
                guard let callbackURL = callbackURL else { return }
                let accessCode = callbackURL.getValue(for: "code")
                self?.rediection(accessCode: accessCode)
            })
        
        authSession?.presentationContextProvider = self
        authSession?.start()
    }
    
    private func rediection(accessCode: String?) {
        guard let accessCode = accessCode else { return }
        
        networkService.fetchAccessToken(accessCode: accessCode)
            .bind(to: isLogin)
            .disposed(by: disposeBag)
    }
}

extension OAuth2ViewModel: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return ASPresentationAnchor()
    }
}
