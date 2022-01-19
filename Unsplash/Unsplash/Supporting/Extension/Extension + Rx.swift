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
        let defaultOffset: CGFloat = 30
        let source = self.base.rx.contentOffset.map { contentOffset -> Bool in
            let visibleHeight = self.base.frame.height - self.base.contentInset.top - self.base.contentInset.bottom
            let y = contentOffset.y + self.base.contentInset.top + self.base.contentInset.bottom
            let threshold = max(defaultOffset, self.base.contentSize.height - visibleHeight - defaultOffset)
            return y >= threshold
        }.distinctUntilChanged()
        
        return source
    }
}
