//
//  SearchTableViewCell.swift
//  Unsplash
//
//  Created by KimJaeYoun on 2021/12/19.
//

import UIKit
import Kingfisher
import RxCocoa
import RxSwift

class ImageListViewCell: UICollectionViewCell {
    //MARK: - Properties
    private let photoId = PublishSubject<String>()
    private let imageButtonSubject = PublishSubject<String>()
    var disposeBag = DisposeBag()
    
    var imageButtonObservable: Observable<String> {
        return imageButtonSubject.asObservable()
    }
    
    private var likeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        
        return button
    }()
    
    private var unsplashImagesView: UnsplashImagesView = {
        let unsplashImagesView = UnsplashImagesView()
        unsplashImagesView.translatesAutoresizingMaskIntoConstraints = false
        
        return unsplashImagesView
    }()
    
    //MARK: - init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupLayer()
    }
    
    required init?(coder: NSCoder) {
        fatalError("스토리보드는 지원하지 않습니다.")
    }
}

//MARK: - Method
extension ImageListViewCell: HierarchySetupable {
    func setupViewHierarchy() {
        contentView.addSubview(unsplashImagesView)
        contentView.addSubview(likeButton)
    }
    
    func setupLayout() {
        let likeButtonImage = unsplashImagesView.likeImageView
        
        NSLayoutConstraint.activate([
            unsplashImagesView.topAnchor.constraint(equalTo: topAnchor),
            unsplashImagesView.leadingAnchor.constraint(equalTo: leadingAnchor),
            unsplashImagesView.trailingAnchor.constraint(equalTo: trailingAnchor),
            unsplashImagesView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            likeButton.topAnchor.constraint(equalTo: likeButtonImage.topAnchor),
            likeButton.leadingAnchor.constraint(equalTo: likeButtonImage.leadingAnchor),
            likeButton.trailingAnchor.constraint(equalTo: likeButtonImage.trailingAnchor),
            likeButton.bottomAnchor.constraint(equalTo: likeButtonImage.bottomAnchor)
        ])
    }
    
    func configure(id: String, photographerName: String?, likeCount: String?, isUserLike: Bool, imageUrl: URL?) {
        unsplashImagesView.configure(photographer: photographerName,
                                     likeCount: likeCount,
                                     isUserLike: isUserLike,
                                     imageUrl: imageUrl)
        bind()
        photoId.onNext(id)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        unsplashImagesView.clearItems()
        disposeBag = DisposeBag()
    }
    
    private func setupLayer() {
        unsplashImagesView.didFinishedImageLoaded.subscribe(onNext: { [weak self] _ in
            guard let self = self else { return }
            
            let shadowRadius: CGFloat = 3
            let shadowOpacity: Float = 0.40
            let shadowOffsetHeight: CGFloat = 5
            
            self.layer.configurationShadow(color: .black,
                                      radius: shadowRadius,
                                      opacity: shadowOpacity,
                                      offset: CGSize(width: .zero, height: shadowOffsetHeight))
            self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds,
                                            cornerRadius: shadowRadius).cgPath
            
            self.contentView.layer.cornerRadius = 5
            self.contentView.layer.masksToBounds = true
        })
            .disposed(by: disposeBag)

    }
    
    private func bind() {
        likeButton.rx.tap
            .withLatestFrom(photoId)
            .bind(to: imageButtonSubject)
            .disposed(by: disposeBag)
    }
}
