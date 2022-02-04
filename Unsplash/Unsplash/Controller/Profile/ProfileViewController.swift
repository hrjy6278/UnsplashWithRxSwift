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
    private let tableViewHeaderView = ProfileHeaderView()
    private let loginView = LoginView()
    
    private var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(ImageListTableViewCell.self,
                           forCellReuseIdentifier: ImageListTableViewCell.cellID)
        
        return tableView
    }()
    
    //MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupView()
        configureTableView()
        setupNavigationItem()
        bindViewModel()
        
    }
}

//MARK: - Setup View And Layout
extension ProfileViewController: HierarchySetupable {
    func setupViewHierarchy() {
        view.addSubview(tableView)
        view.addSubview(loginView)
    }
    
    func setupLayout() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            loginView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            loginView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loginView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            loginView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func configureTableView() {
        tableViewHeaderView.frame.size.height = view.frame.size.height / 8
        tableView.rowHeight = view.frame.size.height / 4
        tableView.tableHeaderView = tableViewHeaderView
    }
    
    private func setupNavigationItem() {
        navigationItem.title = "프로필"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: nil,
                                                            style: .plain,
                                                            target: nil,
                                                            action: nil)
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
        
        output.loginProgress
            .withUnretained(self)
            .subscribe(onNext: { `self`, _ in
                self.present(OAuth2ViewController(), animated: true)
        })
            .disposed(by: disposeBag)
       
    }
}
