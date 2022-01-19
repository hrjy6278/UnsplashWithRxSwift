//
//  SearchViewModel.swift
//  Unsplash
//
//  Created by KimJaeYoun on 2022/01/18.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources

protocol ViewModelType {
    associatedtype Input
    associatedtype Output
    
    func bind(input: Input) -> Output
}

typealias SearchSection = SectionModel<String, Photo>

final class SearchViewModel: ViewModelType {
    private let networkService = UnsplashAPIManager()
    private let disposeBag = DisposeBag()
    private var pageCounter: Int = .initialPage
    private var totalPage: Int = .zero
    
    struct Input {
        let searchAction: Observable<String>
        let loadMore: Observable<Bool>
        let login: Observable<Void>
    }
    
    struct Output {
        let navigationTitle: Driver<String>
        let tavleViewModel: Observable<[SearchSection]>
        let loginPresenting: Observable<Void>
        let barbuttonTitle: Observable<String>
    }
    
    func bind(input: Input) -> Output {
        let searchBehaviorSubject = BehaviorSubject<[Photo]>(value: [])
        let navigationTitle = BehaviorSubject<String>(value: "검색")
        let barButtonTitle = BehaviorSubject<String>(value: "로그인")
        
        var searchQuery = ""
        
        //검색결과 가져오는 옵저버블
        let searchFirstResult = input.searchAction
            .flatMap { query -> Observable<SearchPhoto> in
                searchQuery = query
                self.pageCounter = .initialPage
                return self.networkService.searchPhotos(type: SearchPhoto.self,
                                                        query: query,
                                                        page: self.pageCounter)
            }
            .do(onNext: {
                searchBehaviorSubject.onNext([])
                self.totalPage = $0.totalPages
                navigationTitle.onNext("\(searchQuery) 검색결과")
            })
        
        let requestFirst = searchFirstResult.map { $0.photos }
        
        //검색결과를 더 가져오는 옵저버블
        let requestNext = input.loadMore
            .filter { _ in self.totalPage != .zero }
            .take(while: { _ in self.pageCounter != self.totalPage ? true : false })
            .flatMap { isLoadMore -> Observable<[Photo]> in
                guard isLoadMore else { return .never() }
                self.pageCounter.addPage()
                return self.networkService.searchPhotos(type: SearchPhoto.self,
                                                        query: searchQuery,
                                                        page: self.pageCounter)
                    .map{ $0.photos }
            }
        
        //검색결과를 머지한 뒤 Emit하는 옵저버블
        Observable.merge(requestFirst, requestNext)
            .subscribe(onNext: { newPhotos in
                if let originalPhotos = try? searchBehaviorSubject.value() {
                    searchBehaviorSubject.onNext(originalPhotos + newPhotos)
                }
            })
            .disposed(by: disposeBag)
        
        //검색결과를 테이블뷰 모델에 맞게 변환하는 로직이 담긴 옵저버블
        let tableViewModel = searchBehaviorSubject.map { photos in
            [SearchSection(model: "Photo", items: photos)]
        }
        
        //네비게이션 타이틀을 방출하는 드라이버
        let outputNavigationTitle = navigationTitle.asDriver(onErrorJustReturn: "")
        
        
        TokenManager.shared.isTokenSaved.subscribe(onNext: { isSavedToken in
            isSavedToken ? barButtonTitle.onNext("로그아웃") : barButtonTitle.onNext("로그인")
        })
            .disposed(by: disposeBag)
        
        let loginPresenting = input.login.withLatestFrom(TokenManager.shared.isTokenSaved)
            .filter { $0 == false }
            .map { _ in }
        
        let output = Output(navigationTitle: outputNavigationTitle,
                            tavleViewModel: tableViewModel,
                            loginPresenting: loginPresenting,
                            barbuttonTitle: barButtonTitle)
        return output
    }
}
