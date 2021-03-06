//
//  ProfileViewController.swift
//  Unsplash
//
//  Created by KimJaeYoun on 2021/12/22.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

final class ProfileViewController: UIViewController {
    //MARK: Properties
    private let viewModel = ProfileViewModel()
    private let disposeBag = DisposeBag()
    private let loginView = LoginView()
    
    private var collectionView: UICollectionView = {
        let collectionView = UICollectionView.init(frame: .zero,
                                                   collectionViewLayout: .createCompositinalLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(ProfileCell.self,
                                forCellWithReuseIdentifier: ProfileCell.cellID)
        collectionView.register(ProfileHeaderView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: ProfileHeaderView.cellID)
        collectionView.register(ImageListViewCell.self,
                                forCellWithReuseIdentifier: ImageListViewCell.cellID)
        collectionView.clipsToBounds = false
        collectionView.backgroundColor = .clear
       
        return collectionView
    }()
    
    private let backgroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .darkGray
        view.layer.masksToBounds = true
        view.isHidden = true
        
        return view
    }()
    
    private var dataSource: RxCollectionViewSectionedReloadDataSource<ProfileSectionModel>?
    
    //MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupView()
        setupNavigationItem()
        configureDataSource()
        bindViewModel()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backgroundView.layer.cornerRadius = backgroundView.bounds.height / 5
        backgroundView.layer.maskedCorners = CACornerMask(arrayLiteral: .layerMinXMaxYCorner, .layerMaxXMaxYCorner)
    }
}

//MARK: - Setup View And Layout
extension ProfileViewController: HierarchySetupable {
    func setupViewHierarchy() {
        view.addSubview(backgroundView)
        view.addSubview(collectionView)
        view.addSubview(loginView)
    }
    
    func setupLayout() {
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                                                constant: view.bounds.height / 20),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            loginView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            loginView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loginView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            loginView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: collectionView.topAnchor,
                                                   constant: view.bounds.height / 8)
        ])
    }
    
    private func setupNavigationItem() {
        navigationItem.title = "?????????"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: nil,
                                                            style: .plain,
                                                            target: nil,
                                                            action: nil)
    }
    
    private func isLoginProgress(_ isLogin: Bool) {
        var alpha: CGFloat
        var isHiddeen: Bool
        
        let _ =  isLogin ? (alpha = 1, isHiddeen = false) : (alpha = 0, isHiddeen = true)
        
        UIView.animate(withDuration: 0.4) {
            self.collectionView.alpha = alpha
            self.backgroundView.alpha = alpha
        } completion: { _ in
            self.collectionView.isHidden = isHiddeen
            self.backgroundView.isHidden = isHiddeen
        }
    }
    
    private func configureDataSource() {
        dataSource = RxCollectionViewSectionedReloadDataSource { dataSource, collectionView, indexPath, model in
            switch dataSource[indexPath] {
            case .profile(let profile):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProfileCell.cellID, for: indexPath) as! ProfileCell
                
                cell.configureCell(userName: profile.userName,
                                   profileURL: profile.profileImage?.smallURL,
                                   totalLikes: String(profile.totalLikes),
                                   totalPhotos: String(profile.totalPhotos),
                                   totalCollections: String(profile.totalCollections))
                cell.editButtonTap
                    .subscribe(onNext: { [weak self] _ in
                        self?.viewModel.inputAction(.profileEditButtonTaped)
                    })
                    .disposed(by: cell.disposeBag)
                
                return cell
            case .photo(let photo):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageListViewCell.cellID, for: indexPath) as! ImageListViewCell
                
                cell.configure(id: photo.id,
                               photographerName: photo.profile.userName,
                               likeCount: String(photo.likes),
                               isUserLike: photo.isUserLike,
                               imageUrl: photo.urls.smallURL)
                
                return cell
            }
        }
        
        dataSource?.configureSupplementaryView = { _, collectionView, kind, indexPath in
            
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: ProfileHeaderView.cellID, for: indexPath) as! ProfileHeaderView
            headerView.configureCell(title: "Likes")
            
            return headerView
        }
    }
}

//MARK: - Bind
extension ProfileViewController {
    private func bindViewModel() {
        let loginButtonTaped = Observable.merge(loginView.loginButtonTaped,
                                                navigationItem.rightBarButtonItem?.rx.tap.asObservable() ?? .empty())

        let viewWillAppear = rx.sentMessage(#selector(UIViewController.viewWillAppear(_:)))
            .map { _ in }
        let viewWillDisappear = rx.sentMessage(#selector(UIViewController.viewWillDisappear(_:)))
            .map { _ in }
        
        let intput = ProfileViewModel.Input(loginButtonTaped: loginButtonTaped,
                                            viewWillAppear: viewWillAppear,
                                            viewWillDisappear: viewWillDisappear,
                                            likePhotoItemIndexPath: UICollectionViewLayout.visibleItemIndexPath)
        
        let output = viewModel.bind(input: intput)
        
        navigationItem.rightBarButtonItem
            .flatMap { rightBarButton in output.barButtonTitle.bind(to: rightBarButton.rx.title) }?
            .disposed(by: disposeBag)
        
        output.isLogin
            .bind(to: loginView.rx.isHidden)
            .disposed(by: disposeBag)
        
        output.isLogin
            .subscribe(onNext: { [weak self] isLogin in
                self?.isLoginProgress(isLogin)
            })
            .disposed(by: disposeBag)
    
        output.loginProgress
            .withUnretained(self)
            .subscribe(onNext: { `self`, _ in
                `self`.present(OAuth2ViewController(), animated: true)
            })
            .disposed(by: disposeBag)
        
        output.randomPhoto
            .map { $0.urls.regularURL }
            .subscribe(onNext: { [weak self] URL in
                self?.loginView.configureBackgroundImage(URL)
            })
            .disposed(by: disposeBag)
        
        dataSource.flatMap { dataSource in
            output.profileModel.bind(to: collectionView.rx.items(dataSource: dataSource))
                .disposed(by: disposeBag)
        }
        
        collectionView.rx.willDisplayCell
            .map { _ in false }
            .distinctUntilChanged()
            .bind(to: backgroundView.rx.isHidden)
            .disposed(by: disposeBag)
        
        viewModel.profileEditPresent
            .subscribe(onNext: { [weak self] viewModel in
                let editViewController = ProfileEditViewController(viewModel: viewModel)
                
                self?.present(editViewController, animated: true)
            })
            .disposed(by: disposeBag)
    }
}
