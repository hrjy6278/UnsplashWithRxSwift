//
//  ProfileViewModel.swift
//  Unsplash
//
//  Created by KimJaeYoun on 2022/02/04.
//

import RxSwift

final class ProfileViewModel: ViewModelType {
    private var page: Int = .initialPage
    private let networkService = UnsplashAPIManager()
    private let disposeBag = DisposeBag()
    
    struct Input {
        let loginButtonTaped: Observable<Void>
    }
    
    struct Output {
        let barButtonTitle: Observable<String>
        let isLogin: Observable<Bool>
        let loginProgress: Observable<Void>
    }
    
}

extension ProfileViewModel {
    func bind(input: Input) -> Output {
        let barButtonTitle = BehaviorSubject<String>(value: "")
        let isTokenSaved = TokenManager.shared.isTokenSaved.share(replay: 1)
        let loginProgress = input.loginButtonTaped.withLatestFrom(isTokenSaved)
        
        isTokenSaved
            .flatMap { $0 ? Observable.just("로그아웃") : Observable.just("로그인") }
            .bind(to: barButtonTitle)
            .disposed(by: disposeBag)
        
        let notLogin = loginProgress
            .filter { $0 == false }
            .distinctUntilChanged()
            .map { _ in }
        
        loginProgress
            .filter { $0 == true }
            .subscribe(onNext: { _ in TokenManager.shared.clearAccessToken() })
            .disposed(by: disposeBag)
        
        return Output(barButtonTitle: barButtonTitle,
                      isLogin: isTokenSaved,
                      loginProgress: notLogin)
    }
}
