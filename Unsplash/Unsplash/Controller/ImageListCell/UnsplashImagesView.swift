//
//  UnsplashImagesView.swift
//  Unsplash
//
//  Created by KimJaeYoun on 2021/12/22.
//

import UIKit
import Kingfisher

class UnsplashImagesView: UIView {
    //MARK: - Properties
    private var thumbnailImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        return imageView
    }()
    
    private var photographerLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.generateFont(font: .SDGothichBold, size: 18)
        
        return label
    }()
    
    private var likeCountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.generateFont(font: .SDGothichBold, size: 16)
        
        return label
    }()
    
    lazy var likeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: "heart")
        imageView.contentMode = .scaleAspectFit
        
        return imageView
    }()
    
    private var contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .equalSpacing
        stackView.alignment = .leading
        stackView.spacing = 8
        
        return stackView
    }()
    
    //MARK: View Life Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("스토리보드는 지원하지 않습니다.")
    }
    
}

//MARK: - Method
extension UnsplashImagesView: HierarchySetupable {
    func setupViewHierarchy() {
        contentStackView.addArrangedSubview(photographerLabel)
        contentStackView.addArrangedSubview(likeCountLabel)
        contentStackView.addArrangedSubview(likeImageView)
        
        addSubview(thumbnailImageView)
        addSubview(contentStackView)
    }
    
    func setupLayout() {
        let stackViewTopConstant: CGFloat = 16
        let stackViewLeadingConstant: CGFloat = 16
        
        NSLayoutConstraint.activate([
            thumbnailImageView.topAnchor.constraint(equalTo: topAnchor),
            thumbnailImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            thumbnailImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            thumbnailImageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            contentStackView.topAnchor.constraint(equalTo: topAnchor,
                                                  constant: stackViewTopConstant),
            contentStackView.leadingAnchor.constraint(equalTo: leadingAnchor,
                                                      constant: stackViewLeadingConstant),
        ])
    }
    
    func configure(photographer: String?, likeCount: String?, isUserLike: Bool, imageUrl: URL?) {
        photographerLabel.text = photographer
        likeCountLabel.text = likeCount
        
        configureLikeImageView(isUserLike: isUserLike)
        configureThumbnailImageView(imageUrl)
    }
    
    func clearItems() {
        thumbnailImageView.image = nil
        photographerLabel.text = nil
        likeCountLabel.text = nil
        likeImageView.image = nil
    }
    
    private func configureThumbnailImageView(_ imageUrl: URL?) {
        thumbnailImageView.kf.indicatorType = .activity
        thumbnailImageView.kf.setImage(with: imageUrl,
                                       options: [.keepCurrentImageWhileLoading])
    }
    
    private func configureLikeImageView(isUserLike: Bool) {
        var image: UIImage?
        
        isUserLike ? (image = UIImage(systemName: "heart.fill")) : (image = UIImage(systemName: "heart"))
        
        likeImageView.image = image
    }
}



