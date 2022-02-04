//
//  ProfileViewModel.swift
//  Unsplash
//
//  Created by KimJaeYoun on 2022/02/04.
//

import UIKit

final class ProfileViewModel: ViewModelType {
    private var page: Int = .initialPage
    private let networkService = UnsplashAPIManager()
    
    struct Input {
        
    }
    
    struct Output {
        
    }

}

extension ProfileViewModel {
    func bind(input: Input) -> Output {
        
        
        return Output()
    }
}
