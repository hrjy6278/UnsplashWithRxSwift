//
//  ProfileViewModel.swift
//  Unsplash
//
//  Created by KimJaeYoun on 2022/02/04.
//

import RxSwift
import RxDataSources
import RxCocoa
import Foundation

final class ProfileViewModel: ViewModelType {
    //MARK: Properties
    private let networkService = UnsplashAPIManager()
    private let disposeBag = DisposeBag()
    private var profileRelay = BehaviorRelay<Profile?>(value: nil)
    
    //MARK: - Input
    enum InputAction {
        case profileEditButtonTaped
    }
    
    func inputAction(_ action: InputAction) {
        switch action {
        case .profileEditButtonTaped:
            guard let profile = profileRelay.value else { return }
            let profileViewModel = ProfileEditViewModel(profile: profile)
            profileEditPresent.onNext(profileViewModel)
            
            profileViewModel.updatedProfile
                .bind(to: profileRelay)
                .disposed(by: disposeBag)
        }
    }
    struct Input {
        let loginButtonTaped: Observable<Void>
        let viewWillAppear: Observable<Void>
        let viewWillDisappear: Observable<Void>
        let likePhotoItemIndexPath: Observable<IndexPath>
    }
    
    //MARK: - Output
    struct Output {
        let barButtonTitle: Observable<String>
        let isLogin: Observable<Bool>
        let loginProgress: Observable<Void>
        let profileModel: Observable<[ProfileSectionModel]>
        let randomPhoto: Observable<Photo>
    }
    let profileEditPresent = PublishSubject<ProfileEditViewModel>()
    
}

//MARK: - Bind View
extension ProfileViewModel {
    func bind(input: Input) -> Output {
        let barButtonTitle = BehaviorSubject<String>(value: "")
        let isTokenSaved = TokenManager.shared.isTokenSaved.share(replay: 1)
        let loginProgress = PublishSubject<Void>()
        let likePhotos = BehaviorSubject<[Photo]>(value: [])
    
        var currentPage: Int = .initialPage
        var totalPage: Int = .zero

        let existsToken = isTokenSaved
            .filter {$0 == true }
            .map { _ in }
        
        let viewWillAppear = input.viewWillAppear.withLatestFrom(isTokenSaved)
            .filter { $0 == true }
            .map { _ in }
        
        // 로그인이 되어있는 경우 유저 프로필을 가져오는 Observable
        let fetchUserProfile = Observable.merge(viewWillAppear, existsToken)
       
        fetchUserProfile
            .withUnretained(self)
            .flatMap { viewModel, _ in viewModel.networkService.fetchUserProfile() }
            .bind(to: profileRelay)
            .disposed(by: disposeBag)
        
        isTokenSaved
            .filter { $0 == false }
            .map { _ in [Photo]() }
            .do(onNext:{ _ in
                currentPage = .initialPage
                totalPage = .zero
            })
            .bind(to: likePhotos)
            .disposed(by: disposeBag)
        
        //뷰가 사라지고 난 후 할 로직을 담아둔 Observable
        input.viewWillDisappear
            .subscribe(onNext: {
                likePhotos.onNext([])
                currentPage = .initialPage
                totalPage = .zero
            })
            .disposed(by: disposeBag)

        
        // 프로필을 RxDataSource 모델로 변환시키는 로직이 담긴 Observable
        let profileSectionModel = profileRelay
            .compactMap { $0 }
            .map { profile in
                [ProfileSectionModel.profile(items: [.profile(profile)])] }
        
        // 사용자가 좋아요를 누른 사진을 가져오기 위한 로직이 담긴 Observable
        let firstPhtoLikeRequest = profileRelay
            .compactMap { $0 }
            .withUnretained(self)
            .flatMap { viewModel, profile in
                viewModel.networkService.fetchUserLikePhotos(userName: profile.userName,
                                                             page: currentPage)
            }
            .do(onNext: { (_, pageCount) in
                currentPage.addPage()
                totalPage = pageCount
            })
        
        // 좋아요 누른 사진을 Pagination 하기 위한 로직을 담은 Observable
        let pagination = input.likePhotoItemIndexPath
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
        
        // 유저가 좋아요 누른 사진을 더 가져오는 Observable
        let photoLikeNextRequest = pagination
            .filter { $0 == true }
            .withLatestFrom(profileRelay)
            .compactMap { $0 }
            .withUnretained(self)
            .flatMap { viewModel, profile in
                viewModel.networkService.fetchUserLikePhotos(userName: profile.userName,
                                                             page: currentPage)
            }
            .do(onNext: { _ in
                currentPage.addPage()
            })
        
        //좋아요 누른 사진을 Merge하는 Observable
        Observable.merge(firstPhtoLikeRequest, photoLikeNextRequest)
                .map { $0.photo }
                .subscribe(onNext: { newPhotos in
                    guard let photos = try? likePhotos.value() else { return }
                    likePhotos.onNext(photos + newPhotos)
                })
                .disposed(by: disposeBag)
        
        // 좋아요 누른 사진을 RxDataSource Model에 맞게 변환시키는 Observable
        let photoSectionModel = likePhotos
            .skip(1)
            .map { photos -> [ProfileSectionModel] in
                let photoItems = photos.map { ProfileItem.photo($0) }
                return [ProfileSectionModel.photos(items: photoItems)]
            }
        
        // 프로필 모델과 좋아요 모델을 합치는 Observable
        let profileModel = Observable.combineLatest(profileSectionModel,
                                                    photoSectionModel)
        { profile, likePhotos in
            profile + likePhotos
        }
        .observe(on: MainScheduler.instance)
        
        // 현재 로그인인지 아닌지 확인하는 Observable
        isTokenSaved
            .flatMap { $0 ? Observable.just("로그아웃") : Observable.just("로그인") }
            .bind(to: barButtonTitle)
            .disposed(by: disposeBag)
        
        // 로그인 or 로그아웃 버튼을 눌렀을때의 비즈니스 로직
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
        
        // 랜덤 Photo를 가져오는 Observable
        let randomPhoto = isTokenSaved
            .distinctUntilChanged()
            .filter { $0 == false }
            .withUnretained(self)
            .flatMap { viewModel, _ in viewModel.networkService.searchRandomPhoto() }
        
        return Output(barButtonTitle: barButtonTitle,
                      isLogin: isTokenSaved,
                      loginProgress: loginProgress,
                      profileModel: profileModel,
                      randomPhoto: randomPhoto)
    }
}
