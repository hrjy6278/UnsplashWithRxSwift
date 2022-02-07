//
//  InformationCell.swift
//  Unsplash
//
//  Created by KimJaeYoun on 2022/02/06.
//

import UIKit
import Kingfisher

class InformationCell: UICollectionViewCell {
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
    
    private let followerCount: UILabel = {
        let label = UILabel()
        label.font = .generateFont(font: .SDGothichBold, size: 26)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        
        return label
    }()
    
    private let followingCount: UILabel = {
        let label = UILabel()
        label.font = .generateFont(font: .SDGothichBold, size: 26)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        
        return label
    }()
    
    private let postCount: UILabel = {
        let label = UILabel()
        label.font = .generateFont(font: .SDGothichBold, size: 26)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        
        return label
    }()
    
    private let followingDescriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .generateFont(font: .SDGothichBold, size: 20)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.text = "팔로잉"
        
        return label
    }()
    
    private let followerDescriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .generateFont(font: .SDGothichBold, size: 20)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.text = "팔로워"
        
        return label
    }()
    
    private let postDescriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .generateFont(font: .SDGothichBold, size: 20)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.text = "게시물"
        
        return label
    }()
    
    private let followerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.spacing = 8
        
        return stackView
    }()
    
    private let followingStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.spacing = 8
        
        return stackView
    }()
    
    private let postStackView: UIStackView = {
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupLayer()
        contentView.backgroundColor = .white
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("스토리보드는 지원하지 않습니다.")
    }
}

extension InformationCell: HierarchySetupable {
    func setupViewHierarchy() {
        followerStackView.addArrangedSubview(followerCount)
        followerStackView.addArrangedSubview(followerDescriptionLabel)
        followingStackView.addArrangedSubview(followingCount)
        followingStackView.addArrangedSubview(followingDescriptionLabel)
        postStackView.addArrangedSubview(postCount)
        postStackView.addArrangedSubview(postDescriptionLabel)
        containerStackView.addArrangedSubview(followerStackView)
        containerStackView.addArrangedSubview(followingStackView)
        containerStackView.addArrangedSubview(postStackView)
        contentView.addSubview(containerStackView)
        contentView.addSubview(profileImageView)
        contentView.addSubview(namaLabel)
    }
    
    func setupLayout() {
        NSLayoutConstraint.activate([
            profileImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            profileImageView.topAnchor.constraint(equalTo: topAnchor,constant: -30),
            namaLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor,constant: 8),
            namaLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            containerStackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            containerStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])
    }
    
    func configureCell(name: String, profileURL: URL?, follower: String, follwing: String, post: String) {
        namaLabel.text = name
        followerCount.text = follower
        followingCount.text = follwing
        postCount.text = post
        
        let processor = RoundCornerImageProcessor(cornerRadius: 25)
        profileImageView.kf.setImage(with: profileURL,options: [.processor(processor)])
    }
    
    private func setupLayer() {
        let shadowRadius: CGFloat = 5
        let shadowOpacity: Float = 0.2
        let shadowOffsetHeight: CGFloat = 1
        
        layer.shadowColor = UIColor.darkGray.cgColor
        layer.shadowRadius = shadowRadius
        layer.shadowOpacity = shadowOpacity
        layer.shadowOffset = CGSize(width: .zero, height: shadowOffsetHeight)
        layer.shadowPath = UIBezierPath(roundedRect: bounds,
                                        cornerRadius: shadowRadius).cgPath
        
        contentView.layer.cornerRadius = 5
        contentView.layer.masksToBounds = false
    }
}
