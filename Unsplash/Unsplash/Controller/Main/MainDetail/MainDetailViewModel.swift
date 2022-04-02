//
//  MainDetailViewModel.swift
//  Unsplash
//
//  Created by KimJaeYoun on 2022/04/01.
//

import Foundation
import RxSwift

final class MainDetailViewModel<Element: ListModelType> {
    private var itemList = BehaviorSubject<[Element]>(value: [])
    private let itemListType: UnsplashListRouter
    private let networkManager = UnsplashAPIManager()
    private let disposeBag = DisposeBag()
    
    struct Input {
        let viewLoded: Observable<Void>
    }
    
    struct Output {
        let list: Observable<[Element]>
    }
    
    init(itemListType: UnsplashListRouter) {
        self.itemListType = itemListType
    }
}

extension MainDetailViewModel {
    func bind(input: Input) -> Output {
        input.viewLoded
            .withUnretained(self)
            .flatMap { viewModel, _ in
                viewModel.networkManager.fetchList(type: [Element].self,
                                                   kind: viewModel.itemListType)
            }
            .subscribe(on: ConcurrentDispatchQueueScheduler.init(qos: .default))
            .bind(to: itemList)
            .disposed(by: disposeBag)
            
        return Output(list: itemList.skip(1))
    }
}
