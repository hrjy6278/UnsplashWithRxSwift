//
//  SearchViewModel.swift
//  Unsplash
//
//  Created by KimJaeYoun on 2022/01/18.
//

import Foundation
import RxSwift
import RxCocoa

protocol ViewModelType {
    associatedtype Input
    associatedtype Output
    
    func bind(input: Input) -> Output
}

final class SearchViewModel: ViewModelType {
    private let networkService = UnsplashAPIManager()
    private let disposeBag = DisposeBag()
    private var pageCounter: Int = .initialPage
    private var totalPage: Int = .zero
    
    
    struct Input {
        let searchAction: Observable<String>
        let loadMore: ControlEvent<Bool>
    }
    
    struct Output {
        let navigationTitle: Driver<String>
        let searchPhotos: Driver<[Photo]>
    }
    
    func bind(input: Input) -> Output {
        let searchBehaviorSubject = BehaviorSubject<[Photo]>(value: [])
        let navigationTitle = BehaviorSubject<String>(value: "검색")
        var searchQuery = ""
        
        let searchFirstResult = input.searchAction
            .flatMap { query -> Observable<SearchPhoto> in
                searchQuery = query
                return self.networkService.searchPhotos(type: SearchPhoto.self,
                                                        query: query,
                                                        page: self.pageCounter)
            }
            .do(onNext: {
                searchBehaviorSubject.onNext([])
                self.pageCounter = .initialPage
                self.totalPage = $0.totalPages
                navigationTitle.onNext("\(searchQuery) 검색결과")
            })
        
        let requestFirst = searchFirstResult.map { $0.photos }
        
        let requestNext = input.loadMore
            .filter { _ in self.totalPage != .zero }
            .take(while: { _ in self.pageCounter != self.totalPage ? true : false })
            .flatMap { isLoadMore -> Observable<[Photo]> in
                guard isLoadMore else { return .empty() }
                self.pageCounter += 1
                return self.networkService.searchPhotos(type: SearchPhoto.self,
                                                        query: searchQuery,
                                                        page: self.pageCounter)
                    .map{ $0.photos }
            }
        
        
        Observable.merge(requestFirst, requestNext)
            .subscribe(onNext: { newPhotos in
                if let originalPhotos = try? searchBehaviorSubject.value() {
                    searchBehaviorSubject.onNext(originalPhotos + newPhotos)
                }
            })
            .disposed(by: disposeBag)
        
        
        let output = Output(navigationTitle: navigationTitle.asDriver(onErrorJustReturn: ""),
                            searchPhotos: searchBehaviorSubject.asDriver(onErrorJustReturn: []))
        return output
    }
}
