//
//  ProfileViewController.swift
//  Unsplash
//
//  Created by KimJaeYoun on 2021/12/22.
//

import UIKit

final class ProfileViewController: UIViewController {
    //MARK: Properties
    private var page: Int = .initialPage
    private var photos = [Photo]()
    
    private let networkService = UnsplashAPIManager()
    private let tableViewDataSource = ImageListDataSource()
    private let tableViewHeaderView = ProfileHeaderView()
    
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
//        setupView()
//        configureTableView()
//        fetchUserProfile()
    }
}
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        reloadUserLikePhotos()
//    }
//}
//
////MARK: - Setup View And Layout
//extension ProfileViewController: HierarchySetupable {
//    func setupViewHierarchy() {
//        view.addSubview(tableView)
//    }
//
//    func setupLayout() {
//        NSLayoutConstraint.activate([
//            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
//            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
//        ])
//    }
//}
//
////MARK: - Configure Views
//extension ProfileViewController {
//    func configureTableView() {
//        tableViewHeaderView.frame.size.height = view.frame.size.height / 8
//        tableView.rowHeight = view.frame.size.height / 4
//        tableView.tableHeaderView = tableViewHeaderView
//        tableViewDataSource.delegate = self
//        tableView.dataSource = tableViewDataSource
//        tableView.delegate = tableViewDataSource
//    }
//}
//
////MARK: - NetworkService
//extension ProfileViewController {
//    private func fetchUserProfile() {
//        networkService.fetchUserProfile { [weak self] result in
//            guard let self = self else { return }
//
//            switch result {
//            case .success(let profile):
//                self.tableViewHeaderView.configure(selfieURL: profile.profileImage?.mediumURL,
//                                                   name: profile.userName)
//                self.userName = profile.userName
//            case .failure:
//                let message = "사용자 정보를 가져오는데 실패하였습니다. 다시 시도해주세요."
//                self.showAlert(message: message)
//            }
//        }
//    }
//
//    private func fetchUserLikePhotos(userName: String) {
//        networkService.fetchUserLikePhotos(userName: userName,
//                                           page: self.page) { [weak self] result in
//            guard let self = self else { return }
//
//            switch result {
//            case .success(let photos):
//                photos.forEach { self.photos.append($0) }
//                self.tableViewDataSource.configure(self.photos)
//                self.tableView.reloadData()
//                self.page.addPage()
//            case .failure(let error):
//                let message = "리스트를 불러오는데 실패하였습니다. 다시 시도해주세요."
//                self.showAlert(message: message)
//                debugPrint(error)
//            }
//        }
//    }
//
//    private func reloadUserLikePhotos() {
//        guard userName != "" else { return }
//
//        photos = []
//        page = .initialPage
//        fetchUserLikePhotos(userName: userName)
//    }
//}
//
////MARK: - ImageList DataSource Delegate
//extension ProfileViewController: ImageListDataSourceDelegate {
//    func morePhotos() {
//        fetchUserLikePhotos(userName: userName)
//    }
//
//    func didTapedLikeButton(photoId: String) {
//        print("사용하지않는버튼입니다.")
//    }
//}

//MARK: - TabBar Image Info Protocol
extension ProfileViewController: TabBarImageInfo {
    var nomal: String {
        return "person"
    }
    
    var selected: String {
        return "person.fill"
    }
    
    var barTitle: String {
        return "Profile"
    }
}
