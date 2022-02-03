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
    private let searchPhotosSubject = BehaviorSubject<[Photo]>(value: [])
    private let errorMessage = PublishSubject<String>()
    
    enum InputAction {
        case likeButtonTaped(photoID: String)
    }
    
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
        let errorMessage: Observable<String>
    }
    
    func inputAction(_ action: InputAction) {
        switch action {
        case .likeButtonTaped(let photoID):
            guard let isTokenSaved = try? TokenManager.shared.isTokenSaved.value(),
                  isTokenSaved == true else {
                      errorMessage.onNext("로그인 후 이용해주세요.")
                      return
                  }
            
            guard var photos = try? searchPhotosSubject.value(),
                  let index = photos.firstIndex(where: { $0.id == photoID }) else { return }
            
            var likeObservable = Observable<Photo>.empty()
            var unLikeObservable = Observable<Photo>.empty()
            
            if photos[index].isUserLike {
                unLikeObservable = networkService.photoUnlike(id: photoID).map { $0.photo }
            } else {
                likeObservable = networkService.photoLike(id: photoID).map { $0.photo }
            }
            
            Observable.merge(likeObservable, unLikeObservable)
                .withUnretained(self)
                .subscribe(onNext: { `self`, photoResult in
                    photos[index].isUserLike = photoResult.isUserLike
                    photos[index].likes = photoResult.likes
                    self.searchPhotosSubject.onNext(photos)
                })
                .disposed(by: disposeBag)
        }
    }
    
    func bind(input: Input) -> Output {
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
                self.searchPhotosSubject.onNext([])
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
            .withUnretained(self)
            .subscribe(onNext: { `self`, newPhotos in
                if let originalPhotos = try? self.searchPhotosSubject.value() {
                    self.searchPhotosSubject.onNext(originalPhotos + newPhotos)
                }
            })
            .disposed(by: disposeBag)
        
        //검색결과를 테이블뷰 모델에 맞게 변환하는 로직이 담긴 옵저버블
        let tableViewModel = searchPhotosSubject.map { photos in
            [SearchSection(model: "Photo", items: photos)]
        }
        
        //네비게이션 타이틀을 방출하는 드라이버
        let outputNavigationTitle = navigationTitle.asDriver(onErrorJustReturn: "")
        
        let output = Output(navigationTitle: outputNavigationTitle,
                            tavleViewModel: tableViewModel,
                            loginPresenting: loginButtonTaped,
                            barbuttonTitle: barButtonText,
                            errorMessage: errorMessage)
        return output
    }
}
