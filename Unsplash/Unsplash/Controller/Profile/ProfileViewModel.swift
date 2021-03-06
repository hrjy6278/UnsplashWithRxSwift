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
        
        // ???????????? ???????????? ?????? ?????? ???????????? ???????????? Observable
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
        
        //?????? ???????????? ??? ??? ??? ????????? ????????? Observable
        input.viewWillDisappear
            .subscribe(onNext: {
                likePhotos.onNext([])
                currentPage = .initialPage
                totalPage = .zero
            })
            .disposed(by: disposeBag)

        
        // ???????????? RxDataSource ????????? ??????????????? ????????? ?????? Observable
        let profileSectionModel = profileRelay
            .compactMap { $0 }
            .map { profile in
                [ProfileSectionModel.profile(items: [.profile(profile)])] }
        
        // ???????????? ???????????? ?????? ????????? ???????????? ?????? ????????? ?????? Observable
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
        
        // ????????? ?????? ????????? Pagination ?????? ?????? ????????? ?????? Observable
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
        
        // ????????? ????????? ?????? ????????? ??? ???????????? Observable
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
        
        //????????? ?????? ????????? Merge?????? Observable
        Observable.merge(firstPhtoLikeRequest, photoLikeNextRequest)
                .map { $0.photo }
                .subscribe(onNext: { newPhotos in
                    guard let photos = try? likePhotos.value() else { return }
                    likePhotos.onNext(photos + newPhotos)
                })
                .disposed(by: disposeBag)
        
        // ????????? ?????? ????????? RxDataSource Model??? ?????? ??????????????? Observable
        let photoSectionModel = likePhotos
            .skip(1)
            .map { photos -> [ProfileSectionModel] in
                let photoItems = photos.map { ProfileItem.photo($0) }
                return [ProfileSectionModel.photos(items: photoItems)]
            }
        
        // ????????? ????????? ????????? ????????? ????????? Observable
        let profileModel = Observable.combineLatest(profileSectionModel,
                                                    photoSectionModel)
        { profile, likePhotos in
            profile + likePhotos
        }
        .observe(on: MainScheduler.instance)
        
        // ?????? ??????????????? ????????? ???????????? Observable
        isTokenSaved
            .flatMap { $0 ? Observable.just("????????????") : Observable.just("?????????") }
            .bind(to: barButtonTitle)
            .disposed(by: disposeBag)
        
        // ????????? or ???????????? ????????? ??????????????? ???????????? ??????
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
        
        // ?????? Photo??? ???????????? Observable
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
