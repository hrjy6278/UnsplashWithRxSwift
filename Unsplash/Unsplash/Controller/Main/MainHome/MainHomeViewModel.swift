//
//  MainHomeViewModel.swift
//  Unsplash
//
//  Created by KimJaeYoun on 2022/03/23.
//

import Foundation
import RxSwift
import RxCocoa

final class MainHomeViewModel: ViewModelType {
    private let networkManager = UnsplashAPIManager()
    private let disposeBag = DisposeBag()
    private let currentPage = BehaviorSubject<Int>(value: 0)
    
    struct Input {
        let viewWillAppear: Observable<Void>
    }
    
    func didTapCell(at page: Int) {
        currentPage.onNext(page)
    }
    
    struct Output {
        let itemList: Observable<[String]>
        let currentPage: Observable<Int>
    }
}

//MARK: Bind
extension MainHomeViewModel {
    func bind(input: Input) -> Output {
        let headerItemList = Observable.just(["콜렉션", "사진들", "토픽", "test1", "test1", "test1", "test1","test1","test1","test1","test1","test1"])
            .share()
        
        let output = Output(itemList: headerItemList, currentPage: currentPage)
        return output
    }
}
