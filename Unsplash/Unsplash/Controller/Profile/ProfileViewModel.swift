//
//  ProfileViewModel.swift
//  Unsplash
//
//  Created by KimJaeYoun on 2022/02/04.
//

import RxSwift
import RxDataSources

final class ProfileViewModel: ViewModelType {
    private var page: Int = .initialPage
    private let networkService = UnsplashAPIManager()
    private let disposeBag = DisposeBag()
    
    struct Input {
        let loginButtonTaped: Observable<Void>
        let viewWillAppear: Observable<Void>
    }
    
    struct Output {
        let barButtonTitle: Observable<String>
        let isLogin: Observable<Bool>
        let loginProgress: Observable<Void>
        let profileModel: Observable<[ProfileSectionModel]>
    }
    
}

extension ProfileViewModel {
    func bind(input: Input) -> Output {
        let barButtonTitle = BehaviorSubject<String>(value: "")
        let isTokenSaved = TokenManager.shared.isTokenSaved.share(replay: 1)
        let loginProgress = PublishSubject<Void>()
        let profileName = PublishSubject<String>()
        
        let viewWillAppear = input.viewWillAppear.withLatestFrom(isTokenSaved)
            .share(replay: 1)
        
        let profile = viewWillAppear
            .filter { $0 == true }
            .withUnretained(self)
            .flatMap { `self`, _ in `self`.networkService.fetchUserProfile() }
            .do(onNext: { profile in
                profileName.onNext(profile.userName)
            })
                .map { profile in
                    [ProfileSectionModel.profile(items: [.profile(profile)])]
                }
           
        let likePhotos = profileName
            .withUnretained(self)
            .flatMap {`self`, userName in
                self.networkService.fetchUserLikePhotos(userName: userName, page: 1)
            }
            .map { photos -> [ProfileSectionModel] in
                let photoItem = photos.map { ProfileItem.photo($0) }
                return [ProfileSectionModel(original: .photo(items: photoItem),
                                            items: photoItem)]
            }
        
        let profileModel = Observable.combineLatest(profile, likePhotos, resultSelector: { profile, likePhotos in
            profile + likePhotos
        })
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
