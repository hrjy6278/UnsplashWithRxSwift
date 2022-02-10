//
//  ProfileViewModel.swift
//  Unsplash
//
//  Created by KimJaeYoun on 2022/02/08.
//

import Foundation
import RxSwift
import RxCocoa

final class ProfileEditViewModel: ViewModelType {
    private let profile: Profile
    private let networkService = UnsplashAPIManager()
    private let disposeBag = DisposeBag()
    
    private let _updatedProfile = PublishSubject<Profile>()
    
    var updatedProfile: Observable<Profile> {
        return _updatedProfile.asObservable()
    }
    
    struct Input {
        let userName: Observable<String>
        let firstName: Observable<String>
        let lastName: Observable<String>
        let location: Observable<String>
        let bio: Observable<String>
        let saveButtonTaped: Observable<Void>
    }
    
    struct Output {
        let userName: Driver<String>
        let firstName: Driver<String>
        let lastName: Driver<String>
        let location: Driver<String>
        let bio: Driver<String>
        let profileImageURL: Driver<URL?>
        let isSavedProfile: Observable<Bool>
    }
    
    init(profile: Profile) {
        self.profile = profile
    }
}

extension ProfileEditViewModel {
    func bind(input: Input) -> Output {
        let userNameRelay = BehaviorRelay<String>(value: profile.userName)
        let firstNameRelay = BehaviorRelay<String>(value: profile.firstName ?? "")
        let lastNameRelay = BehaviorRelay<String>(value: profile.lastName ?? "")
        let locationRelay = BehaviorRelay<String>(value: profile.location ?? "")
        let bioRelay = BehaviorRelay<String>(value: profile.bio ?? "")
        let profileImageURL = BehaviorRelay<URL?>(value: profile.profileImage?.mediumURL)
        
        let userNameDriver = userNameRelay.asDriver()
        let firstNameDriver = firstNameRelay.asDriver()
        let lastNameDriver = lastNameRelay.asDriver()
        let locationDriver = locationRelay.asDriver()
        let bioNameDriver = bioRelay.asDriver()
        let profileImageURLDriver = profileImageURL.asDriver()
        let isSavedProfile = PublishRelay<Bool>()
        
        input.userName
            .skip(1)
            .bind(to: userNameRelay)
            .disposed(by: disposeBag)
        
        input.firstName
            .skip(1)
            .bind(to: firstNameRelay)
            .disposed(by: disposeBag)
        
        input.lastName
            .skip(1)
            .bind(to: lastNameRelay)
            .disposed(by: disposeBag)
        
        input.location
            .skip(1)
            .bind(to: locationRelay)
            .disposed(by: disposeBag)
        
        input.bio
            .skip(1)
            .bind(to: bioRelay)
            .disposed(by: disposeBag)
        
        let profile = Observable.combineLatest(userNameRelay, firstNameRelay, lastNameRelay, locationRelay, bioRelay) { userName, firstName, lastName, location, bio in
            UpdateProfile(userName: userName,
                          firstName: firstName,
                          lastName: lastName,
                          location: location,
                          bio: bio)
        }
        
        input.saveButtonTaped
            .do(onNext: { _ in isSavedProfile.accept(false)})
            .withLatestFrom(profile)
            .withUnretained(self)
            .flatMap { viewModel, profile in
                viewModel.networkService.updateProfile(profile)
            }
            .do(onNext: { [weak self] profile in
                self?._updatedProfile.onNext(profile)
            })
            .delay(.seconds(1), scheduler: MainScheduler.instance)
            .subscribe(onNext: { _ in
                isSavedProfile.accept(true)
            })
            .disposed(by: disposeBag)
            
        return Output(userName: userNameDriver,
                      firstName: firstNameDriver,
                      lastName: lastNameDriver,
                      location: locationDriver,
                      bio: bioNameDriver,
                      profileImageURL: profileImageURLDriver,
                      isSavedProfile: isSavedProfile.asObservable())
    }
}
