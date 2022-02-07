//
//  Extention + UICollectionViewLayout.swift
//  Unsplash
//
//  Created by KimJaeYoun on 2022/02/06.
//

import UIKit

extension UICollectionViewLayout {
    static var createProfileSizeSection: NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                              heightDimension: .fractionalHeight(1))
        let layoutItem = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                               heightDimension: .fractionalHeight(0.3))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize,
                                                       subitems: [layoutItem])
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .none
        section.interGroupSpacing = 8
        section.contentInsets = NSDirectionalEdgeInsets(top: 16,
                                                        leading: 16,
                                                        bottom: 16,
                                                        trailing: 16)
        
        return section
    }
    
    static func createCompositinalLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, environment in
            return UICollectionViewLayout.createProfileSizeSection
        }
        
        return layout
    }
}
