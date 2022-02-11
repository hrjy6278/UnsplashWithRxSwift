//
//  ColumnFlowLayout.swift
//  Unsplash
//
//  Created by KimJaeYoun on 2022/02/06.
//

import UIKit

class ColumnFlowLayout: UICollectionViewFlowLayout {
    override func prepare() {
        super.prepare()
        guard let collectionView = collectionView else { return }
        
        let inset: CGFloat = 8
        let lineSpacing: CGFloat = 8
        let itemWidth = collectionView.bounds.inset(by: collectionView.layoutMargins).width - inset
        let itemHeight = collectionView.frame.height / 3
        
        self.itemSize = CGSize(width: itemWidth, height: itemHeight)
        self.sectionInsetReference = .fromSafeArea
        self.sectionInset = UIEdgeInsets(top: inset, left: .zero, bottom: .zero, right: .zero)
        self.minimumLineSpacing = lineSpacing
    }
}
