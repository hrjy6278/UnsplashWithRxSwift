//
//  ProfileViewModel.swift
//  Unsplash
//
//  Created by KimJaeYoun on 2022/02/04.
//

import RxSwift
import RxDataSources

typealias SectionProfile = SectionModel<String, Profile>

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
        let profileModel: Observable<[SectionProfile]>
    }
    
}

extension ProfileViewModel {
    func bind(input: Input) -> Output {
        let barButtonTitle = BehaviorSubject<String>(value: "")
        let isTokenSaved = TokenManager.shared.isTokenSaved.share(replay: 1)
        let loginProgress = PublishSubject<Void>()
        
        let profileModel = isTokenSaved
            .filter { $0 == true }
            .withUnretained(self)
            .flatMap { `self`, _ in  `self`.networkService.fetchUserProfile() }
            .map { profile in [SectionProfile(model: "Profile", items: [profile])] }
            .observe(on: MainScheduler.instance)
        
        isTokenSaved
            .flatMap { $0 ? Observable.just("로그아웃") : Observable.just("로그인") }
            .bind(to: barButtonTitle)
            .disposed(by: disposeBag)
        
        input.loginButtonTaped
            .subscribe(onNext: {
                guard let isToken = try? TokenManager.shared.isTokenSaved.value() else { return }
                
                if isToken {
                    TokenManager.shared.clearAccessToken()
                } else {
                    loginProgress.onNext(())
                }
            })
            .disposed(by: disposeBag)
        
        return Output(barButtonTitle: barButtonTitle,
                      isLogin: isTokenSaved,
                      loginProgress: loginProgress,
                      profileModel: profileModel)
    }
}
