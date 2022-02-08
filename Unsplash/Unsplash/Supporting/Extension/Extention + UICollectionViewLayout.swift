//
//  Extention + UICollectionViewLayout.swift
//  Unsplash
//
//  Created by KimJaeYoun on 2022/02/06.
//

import UIKit
import RxSwift

extension UICollectionViewLayout {
    static let visibleItemIndexPath = PublishSubject<IndexPath>()
    
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
    
    static var createPhotoListSizeSection: NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                              heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        item.contentInsets = NSDirectionalEdgeInsets(top: 8,
                                                     leading: 8,
                                                     bottom: 8,
                                                     trailing: 8)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                               heightDimension: .fractionalHeight(0.4))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                       subitems: [item])
        
        group.contentInsets = NSDirectionalEdgeInsets(top: .zero,
                                                      leading: 8,
                                                      bottom: .zero,
                                                      trailing: 8)
        
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.6),
                                                heightDimension: .estimated(20))
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize,
                                                                 elementKind: UICollectionView.elementKindSectionHeader, alignment: .topLeading)
        
        let section = NSCollectionLayoutSection(group: group)
        section.boundarySupplementaryItems = [header]
        section.orthogonalScrollingBehavior = .paging
        section.visibleItemsInvalidationHandler = { visibleItems, point, environment in
            guard let indexPath = visibleItems.last?.indexPath else { return }
            visibleItemIndexPath.onNext(indexPath)
        }
        
        return section
    }
    
    static func createCompositinalLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, environment in
            switch sectionIndex {
            case 0:
                return UICollectionViewLayout.createProfileSizeSection
            default:
                return UICollectionViewLayout.createPhotoListSizeSection
            }
        }
        
        return layout
    }
}
