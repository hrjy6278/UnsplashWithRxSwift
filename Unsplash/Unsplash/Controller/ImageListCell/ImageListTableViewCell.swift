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

class ImageListTableViewCell: UITableViewCell {
    //MARK: - Properties
    private var photoId: String = ""
    private let disposeBag = DisposeBag()
    private let imageButtonSubject = PublishSubject<String>()
    
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
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("스토리보드는 지원하지 않습니다.")
    }
}

//MARK: - Method
extension ImageListTableViewCell: HierarchySetupable {
    func setupViewHierarchy() {
        addSubview(unsplashImagesView)
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
        photoId = id
        unsplashImagesView.configure(photographer: photographerName,
                                     likeCount: likeCount,
                                     isUserLike: isUserLike,
                                     imageUrl: imageUrl)
    }
    
    override func prepareForReuse() {
        unsplashImagesView.clearItems()
    }
    
    private func bind() {
        likeButton.rx.tap
            .withUnretained(self)
            .debounce(.seconds(1), scheduler: MainScheduler.instance)
            .flatMap { `self`, _ in
                Observable.just(self.photoId)
            }
            .bind(to: imageButtonSubject)
            .disposed(by: disposeBag)
    }
}
