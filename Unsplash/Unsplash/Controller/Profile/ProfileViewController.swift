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
        collectionView.register(InformationCell.self,
                                forCellWithReuseIdentifier: InformationCell.cellID)
        collectionView.clipsToBounds = false

        return collectionView
    }()
    
    private var dataSource: RxCollectionViewSectionedReloadDataSource<SectionProfile>?
    
    //MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupView()
        setupNavigationItem()
        configureDataSource()
        bindViewModel()
    }
}

//MARK: - Setup View And Layout
extension ProfileViewController: HierarchySetupable {
    func setupViewHierarchy() {
        view.addSubview(collectionView)
        view.addSubview(loginView)
    }
    
    func setupLayout() {
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor ,constant: 80),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            loginView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            loginView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loginView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            loginView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    private func setupNavigationItem() {
        navigationItem.title = "프로필"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: nil,
                                                            style: .plain,
                                                            target: nil,
                                                            action: nil)
    }
    
    private func configureDataSource() {
        dataSource = RxCollectionViewSectionedReloadDataSource { _, collectionView, row, model in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: InformationCell.cellID, for: row) as! InformationCell
            
            cell.configureCell(name: model.name,
                               profileURL: model.profileImage?.mediumURL,
                               follower: String(100),
                               follwing: String(100),
                               post: String(100))
            return cell
        }
    }
}

//MARK: - Bind
extension ProfileViewController {
    private func bindViewModel() {
        let loginButtonTaped = Observable.merge(loginView.loginButtonTaped,
                                                navigationItem.rightBarButtonItem?.rx.tap.asObservable() ?? .empty())
        
        let intput = ProfileViewModel.Input(loginButtonTaped: loginButtonTaped)
        let output = viewModel.bind(input: intput)
        
        navigationItem.rightBarButtonItem
            .flatMap { rightBarButton in output.barButtonTitle.bind(to: rightBarButton.rx.title) }?
            .disposed(by: disposeBag)
        
        output.isLogin
            .bind(to: loginView.rx.isHidden)
            .disposed(by: disposeBag)
        
        output.isLogin
            .withUnretained(self)
            .subscribe(onNext: { `self`, isLogin in
                isLogin ? (self.collectionView.isHidden = false) : (self.collectionView.isHidden = true)
            })
            .disposed(by: disposeBag)
        
        output.loginProgress
            .withUnretained(self)
            .subscribe(onNext: { `self`, _ in
                self.present(OAuth2ViewController(), animated: true)
        })
            .disposed(by: disposeBag)
        
        dataSource.flatMap { dataSource in
            output.profileModel.bind(to: collectionView.rx.items(dataSource: dataSource))
                .disposed(by: disposeBag)
        }
    }
}
