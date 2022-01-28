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
        let loginButtonTaped: Observable<Void>
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
        let barButtonText = BehaviorSubject<String>(value: "로그인")
        let loginButtonTaped = PublishSubject<Void>()
        
        var searchQuery = ""
        
        //사용자가 로그인을 했는지 여부를 판단하는 옵저버블
        let isUserTokenSaved = TokenManager.shared.isTokenSaved
        
        isUserTokenSaved.subscribe(onNext: { state in
            state ? barButtonText.onNext("로그아웃") : barButtonText.onNext("로그인")
        })
            .disposed(by: disposeBag)
        
        input.loginButtonTaped.subscribe(onNext: { _ in
            guard let isTokenSaved = try? isUserTokenSaved.value() else { return }
            
            if isTokenSaved {
                TokenManager.shared.clearAccessToken()
            } else {
                loginButtonTaped.onNext(())
            }
        })
            .disposed(by: disposeBag)
        
        //검색결과 가져오는 옵저버블
        let photoSearchQuery = Observable.combineLatest(isUserTokenSaved,
                                                        input.searchAction) { _, searchQuery in
            return searchQuery
        }
        
        let firstSearchPhoto = photoSearchQuery
            .withUnretained(self)
            .flatMap { `self`, query -> Observable<SearchPhoto> in
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
            
        
        let requestFirst = firstSearchPhoto.map { $0.photos }
        
        //검색결과를 더 가져오는 옵저버블
        let requestNext = input.loadMore
            .withUnretained(self)
                .filter { `self`, _ in self.totalPage != .zero }
                .take(while: { `self`, _ in self.pageCounter != self.totalPage ? true : false })
                .flatMap { `self`, isLoadMore -> Observable<[Photo]> in
                    guard isLoadMore else { return .empty() }
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
        
        
        let output = Output(navigationTitle: outputNavigationTitle,
                            tavleViewModel: tableViewModel,
                            loginPresenting: loginButtonTaped,
                            barbuttonTitle: barButtonText)
        return output
    }
}
