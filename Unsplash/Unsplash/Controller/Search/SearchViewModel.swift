//
//  SearchViewModel.swift
//  Unsplash
//
//  Created by KimJaeYoun on 2022/01/18.
//

import Foundation
import RxSwift

protocol ViewModelType {
    associatedtype Input
    associatedtype Output
    
    func bind(input: Input) -> Output
}

final class SearchViewModel: ViewModelType {
    private let networkService = UnsplashAPIManager()
    private var page: Int = .initialPage
    private var query: String = ""
    private var photos: [Photo] = []
    
    struct Input {
        let searchAction: Observable<String>
    }
    
    struct Output {
        
    }
    
    func bind(input: Input) -> Output {
        
        
        return Output()
    }
}

