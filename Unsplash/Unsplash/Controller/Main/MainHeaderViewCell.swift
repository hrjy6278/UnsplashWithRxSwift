//
//  MainHeaderView.swift
//  Unsplash
//
//  Created by KimJaeYoun on 2022/03/23.
//

import UIKit
import RxSwift

final class MainHeaderViewCell: UICollectionViewCell {
    var disposeBag = DisposeBag()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .generateFont(font: .SDGothichRegular, size: 14)
        label.textColor = .gray
        return label
    }()
    
    private let seperatorView: UIView = {
        let view = UIView(frame: CGRect(x: .zero, y: .zero, width: .zero, height: 1))
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .black
        view.isHidden = true
        return view
    }()
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                titleLabel.textColor = .black
                seperatorView.isHidden = false
            }
            else {
                titleLabel.textColor = .secondaryLabel
                seperatorView.isHidden = true
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViewHierarchy()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MainHeaderViewCell {
    func setupViewHierarchy() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(seperatorView)
    }
    
    func setupLayout() {
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            seperatorView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor,
                                               constant: 4),
            seperatorView.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            seperatorView.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            seperatorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    func configure(title: String) {
        titleLabel.text = title
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        seperatorView.backgroundColor = .black
        disposeBag = DisposeBag()
    }
}
