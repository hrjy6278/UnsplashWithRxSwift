//
//  ProfileViewModel.swift
//  Unsplash
//
//  Created by KimJaeYoun on 2022/02/04.
//

import RxSwift
import RxDataSources
import Foundation

final class ProfileViewModel: ViewModelType {
    //MARK: Properties
    private let networkService = UnsplashAPIManager()
    private let disposeBag = DisposeBag()
    private var profile: Profile?
    
    //MARK: - Input
    enum InputAction {
        case profileEditButtonTaped
    }
    
    func inputAction(_ action: InputAction) {
        switch action {
        case .profileEditButtonTaped:
            guard let profile = profile else { return }
            let profileViewModel = ProfileEditViewModel(profile: profile)
            profileEditPresent.onNext(profileViewModel)
        }
    }
    struct Input {
        let loginButtonTaped: Observable<Void>
        let viewWillAppear: Observable<Void>
        let likePhotoItemIndexPath: Observable<IndexPath>
    }
    
    //MARK: - Output
    struct Output {
        let barButtonTitle: Observable<String>
        let isLogin: Observable<Bool>
        let loginProgress: Observable<Void>
        let profileModel: Observable<[ProfileSectionModel]>
    }
    let profileEditPresent = PublishSubject<ProfileEditViewModel>()
    
}

//MARK: - Bind
extension ProfileViewModel {
    func bind(input: Input) -> Output {
        let barButtonTitle = BehaviorSubject<String>(value: "")
        let isTokenSaved = TokenManager.shared.isTokenSaved.share(replay: 1)
        let loginProgress = PublishSubject<Void>()
        let profileName = PublishSubject<String>()
        let likePhotos = BehaviorSubject<[Photo]>(value: [])
        
        var userName = ""
        var currentPage: Int = .initialPage
        var totalPage: Int = .zero
        
        let viewWillAppear = input.viewWillAppear.withLatestFrom(isTokenSaved)
            .share(replay: 1)
        
        let profileSectionModel = viewWillAppear
            .filter { $0 == true }
            .withUnretained(self)
            .flatMap { `self`, _ in `self`.networkService.fetchUserProfile() }
            .do(onNext: { [weak self] profile in
                self?.profile = profile
                likePhotos.onNext([])
                currentPage = .initialPage
                totalPage = .zero
                profileName.onNext(profile.userName)
            })
            .map { profile in
                [ProfileSectionModel.profile(items: [.profile(profile)])]
            }
        
        let firstPhtoLikeRequest = profileName
            .withUnretained(self)
            .do(onNext: {(_, name) in
                userName = name
            })
            .flatMap { viewModel, _ in
                return viewModel.networkService.fetchUserLikePhotos(userName: userName,
                                                                    page: currentPage)
            }
            .do(onNext: { (_, pageCount) in
                currentPage.addPage()
                totalPage = pageCount
            })
        
        let photoLikeNextRequest = input.likePhotoItemIndexPath
            .distinctUntilChanged()
            .map { indexPath -> Bool in
                guard let photoItems = try? likePhotos.value() else { return false }
                let prefetchingCount = photoItems.count - 3
                
                if currentPage <= totalPage,
                   indexPath.row == prefetchingCount {
                    return true
                }
                return false
            }
            .filter { $0 == true }
            .withUnretained(self)
            .flatMap { viewModel, _ -> Observable<([Photo], Int)> in
                viewModel.networkService.fetchUserLikePhotos(userName: userName,
                                                             page: currentPage)
            }
            .do(onNext: { _ in
                currentPage.addPage()
            })
                    
            Observable.merge(firstPhtoLikeRequest, photoLikeNextRequest)
            .map { $0.0 }
            .subscribe(onNext: { newPhotos in
                guard let photos = try? likePhotos.value() else { return }
                likePhotos.onNext(photos + newPhotos)
            })
            .disposed(by: disposeBag)
        
        let photoSectionModel = likePhotos
            .map { photos -> [ProfileSectionModel] in
                let photoItems = photos.map { ProfileItem.photo($0) }
                return [ProfileSectionModel.photos(items: photoItems)]
            }
        
        let profileModel = Observable.combineLatest(profileSectionModel,
                                                    photoSectionModel) { profile, likePhotos in
            profile + likePhotos
        }
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
