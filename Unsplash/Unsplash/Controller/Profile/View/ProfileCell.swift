//
//  InformationCell.swift
//  Unsplash
//
//  Created by KimJaeYoun on 2022/02/06.
//

import UIKit
import Kingfisher
import RxSwift
import RxCocoa

class ProfileCell: UICollectionViewCell {
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
       
        return imageView
    }()
    
    private let namaLabel: UILabel = {
        let label = UILabel()
        label.font = .generateFont(font: .SDGothichBold, size: 26)
        label.textColor = .lightGray
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private let totalLikesCountLabel: UILabel = {
        let label = UILabel()
        label.font = .generateFont(font: .SDGothichBold, size: 26)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        
        return label
    }()
    
    private let totalPhotosCountLabel: UILabel = {
        let label = UILabel()
        label.font = .generateFont(font: .SDGothichBold, size: 26)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        
        return label
    }()
    
    private let totalCollectionsCountLabel: UILabel = {
        let label = UILabel()
        label.font = .generateFont(font: .SDGothichBold, size: 26)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        
        return label
    }()
    
    private let likesDescriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .generateFont(font: .SDGothichRegular, size: 18)
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.text = "좋아요"
        
        return label
    }()
    
    private let photosDescriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .generateFont(font: .SDGothichRegular, size: 18)
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.text = "내 사진"
        
        return label
    }()
    
    private let collectionsDescriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .generateFont(font: .SDGothichRegular, size: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .darkGray
        label.textAlignment = .center
        label.text = "내 콜렉션"
        
        return label
    }()
    
    private let likesStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.spacing = 8
        
        return stackView
    }()
    
    private let photosStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.spacing = 8
        
        return stackView
    }()
    
    private let collectionsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.spacing = 8
        
        return stackView
    }()
    
    private let containerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .equalCentering
        stackView.spacing = 8
        
        return stackView
    }()
    
    private let profileEditButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Profile Edit", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.titleLabel?.font = .generateFont(font: .SDGothichRegular, size: 14)
        
        return button
    }()
    
    var editButtonTap: Observable<Void> {
        profileEditButton.rx.tap.map { _ in }
    }
    
    let disposeBag = DisposeBag()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupLayer()
        contentView.backgroundColor = .white
        profileEditButton.animateWhenPressed(disposeBag: disposeBag)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("스토리보드는 지원하지 않습니다.")
    }
}

extension ProfileCell: HierarchySetupable {
    func setupViewHierarchy() {
        likesStackView.addArrangedSubview(totalLikesCountLabel)
        likesStackView.addArrangedSubview(likesDescriptionLabel)
        
        photosStackView.addArrangedSubview(totalPhotosCountLabel)
        photosStackView.addArrangedSubview(photosDescriptionLabel)
        
        collectionsStackView.addArrangedSubview(totalCollectionsCountLabel)
        collectionsStackView.addArrangedSubview(collectionsDescriptionLabel)
        
        containerStackView.addArrangedSubview(likesStackView)
        containerStackView.addArrangedSubview(photosStackView)
        containerStackView.addArrangedSubview(collectionsStackView)
        
        contentView.addSubview(containerStackView)
        contentView.addSubview(profileImageView)
        contentView.addSubview(namaLabel)
        contentView.addSubview(profileEditButton)
    }
    
    func setupLayout() {
        NSLayoutConstraint.activate([
            profileImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            profileImageView.topAnchor.constraint(equalTo: topAnchor, constant: -30),
            
            namaLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor,
                                           constant: 8),
            namaLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            containerStackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            containerStackView.leadingAnchor.constraint(equalTo: leadingAnchor,
                                                        constant: 16),
            containerStackView.trailingAnchor.constraint(equalTo: trailingAnchor,
                                                         constant: -16),
            containerStackView.bottomAnchor.constraint(equalTo: bottomAnchor,
                                                       constant: -8),
            
            profileEditButton.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            profileEditButton.trailingAnchor.constraint(equalTo: trailingAnchor,
                                                        constant: -8)
        ])
    }
    
    func configureCell(userName: String,
                       profileURL: URL?,
                       totalLikes: String,
                       totalPhotos: String,
                       totalCollections: String) {
        namaLabel.text = userName
        totalLikesCountLabel.text = totalLikes
        totalPhotosCountLabel.text = totalPhotos
        totalCollectionsCountLabel.text = totalCollections
        
        let processor = RoundCornerImageProcessor(cornerRadius: 25)
        profileImageView.kf.setImage(with: profileURL,options: [.processor(processor)])
    }
    
    private func setupLayer() {
        let shadowRadius: CGFloat = 5
        let shadowOpacity: Float = 0.2
        let shadowOffsetHeight: CGFloat = 1
        
        layer.configurationShadow(color: .darkGray,
                                  radius: shadowRadius,
                                  opacity: shadowOpacity,
                                  offset: CGSize(width: .zero, height: shadowOffsetHeight))
        layer.shadowPath = UIBezierPath(roundedRect: bounds,
                                        cornerRadius: shadowRadius).cgPath
        
        contentView.layer.cornerRadius = 5
        contentView.layer.masksToBounds = false
    }
}
