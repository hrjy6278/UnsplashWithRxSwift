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
    
    struct Input {
        
    }
    
    struct Output {
        let userName: Driver<String>
        let firstName: Driver<String>
        let lastName: Driver<String>
        let location: Driver<String>
        let bio: Driver<String>
        let profileImageURL: Driver<URL?>
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
       
        
        return Output(userName: userNameDriver,
                      firstName: firstNameDriver,
                      lastName: lastNameDriver,
                      location: locationDriver,
                      bio: bioNameDriver,
                      profileImageURL: profileImageURLDriver)
    }
}
