//
//  Extension + Rx.swift
//  Unsplash
//
//  Created by KimJaeYoun on 2022/01/19.
//

import UIKit
import RxSwift
import RxCocoa

extension Reactive where Base: UIScrollView {
    func loadNextPageTrigger(offset: CGPoint) -> Observable<Bool> {
        return Observable.just(self.base.contentOffset.y + self.base.frame.size.height + 20 > self.base.contentSize.height)
    }
}
