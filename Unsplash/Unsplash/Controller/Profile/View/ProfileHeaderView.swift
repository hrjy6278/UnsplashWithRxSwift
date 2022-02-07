//
//  ProfileHeaderView.swift
//  Unsplash
//
//  Created by KimJaeYoun on 2022/02/07.
//

import UIKit

class ProfileHeaderView: UICollectionReusableView {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .generateFont(font: .SDGothichBold, size: 24)
        label.textColor = .darkText
        
        return label
    }()
    
    private let separator: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .black
        
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("스토리보드는 지원하지 않습니다.")
    }
}

extension ProfileHeaderView: HierarchySetupable {
    func setupViewHierarchy() {
        addSubview(separator)
        addSubview(titleLabel)
    }
    
    func setupLayout() {
        NSLayoutConstraint.activate([
            separator.heightAnchor.constraint(equalToConstant: 1),

            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            
            separator.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            separator.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    func configureCell(title: String) {
        titleLabel.text = title
    }
}
