//
//  MainHomeViewModel.swift
//  Unsplash
//
//  Created by KimJaeYoun on 2022/03/23.
//

import Foundation
import RxSwift

final class MainHomeViewModel: ViewModelType {
    struct Input {
        let viewWillAppear: Observable<Void>
    }
    
    struct Output {
        let itemList: Observable<[String]>
    }
}

//MARK: Bind
extension MainHomeViewModel {
    func bind(input: Input) -> Output {
        
        let itemList = Observable.just(["콜렉션", "사진들", "토픽", "test1", "test1", "test1", "test1","test1","test1","test1","test1","test1"])
            .share()
        
        let output = Output(itemList: itemList)
        return output
    }
}
