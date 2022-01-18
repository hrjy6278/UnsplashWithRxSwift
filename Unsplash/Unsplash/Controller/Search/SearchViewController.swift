//
//  ViewController.swift
//  Unsplash
//
//  Created by KimJaeYoun on 2021/12/17.
//

import UIKit
import RxSwift
import RxCocoa

final class SearchViewController: UIViewController {
    //MARK: - Properties
    private let viewModel = SearchViewModel()
    
    private let tableViewDataSource = ImageListDataSource()

    
    private let searchBar: UISearchBar = {
        let search = UISearchBar()
        search.searchBarStyle = .prominent
        search.translatesAutoresizingMaskIntoConstraints = false
        search.placeholder = "검색어를 입력해주세요."
        search.autocapitalizationType = .none
        return search
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.keyboardDismissMode = .onDrag
        tableView.register(ImageListTableViewCell.self,
                           forCellReuseIdentifier: ImageListTableViewCell.cellID)
        
        return tableView
    }()
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupView()
        configureTableView()
        configureTapGesture()
    }
}

//MARK: - Configure Views And Layout
extension SearchViewController: HierarchySetupable {
    func setupViewHierarchy() {
        view.addSubview(tableView)
        view.addSubview(searchBar)
    }
    
    func setupLayout() {
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func configureTableView() {
        tableView.dataSource = tableViewDataSource
        tableView.delegate = tableViewDataSource
        tableView.rowHeight = view.frame.size.height / 4
    }
    
//    private func configureImageListDataSource() {
//        tableViewDataSource.delegate = self
//    }
    
    private func configureTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self,
                                                action: #selector(dissmissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func dissmissKeyboard() {
        view.endEditing(true)
    }
}

extension SearchViewController {
    func bindViewModel() {
        let searchObservable = searchBar.rx
            .searchButtonClicked
            .withLatestFrom(searchBar.rx.text.orEmpty)
        
        let input = SearchViewModel.Input(searchAction: searchObservable)
        
        //아웃풋에 뭐가 나와야될까요? 테이블뷰를 그릴 수 있는 모델이 필요해.
        let output = viewModel.bind(input: input)
        
    }
}

//MARK: - NetworkService
//extension SearchViewController {
//    private func reloadPhotos() {
//        guard photos.isEmpty == false,
//              query != "",
//              TokenManager.shared.isTokenSaved else { return }
//        photos = []
//        page = .initialPage
//        searchPhotos()
//    }
//
//    private func searchPhotos() {
//        networkService.searchPhotos(type: SearchPhoto.self,
//                                    query: query,
//                                    page: page) { [weak self] result in
//            guard let self = self else { return }
//
//            switch result {
//            case .success(let photoResult):
//                photoResult.photos.forEach { self.photos.append($0) }
//                self.tableViewDataSource.configure(self.photos)
//                self.tableView.reloadData()
//                self.page.addPage()
//
//            case .failure(let error):
//                let errorMessage = "이미지를 가져오는데 실패하였습니다. 다시한번 시도해주세요."
//                self.showAlert(message: errorMessage)
//                debugPrint(error.localizedDescription)
//            }
//        }
//    }
//
//    private func fetchLikePhoto(photoId: String) {
//        guard let index = photos.firstIndex(where: { $0.id == photoId }) else { return }
//
//        if photos[index].isUserLike {
//            networkService.photoUnlike(id: photoId, completion: judgeLikeResult(_:))
//        } else {
//            networkService.photoLike(id: photoId, completion: judgeLikeResult(_:))
//        }
//    }
//
//    private func judgeLikeResult(_ result: Result<PhotoLike, Error>) {
//        switch result {
//        case .success(let photoResult):
//            photos.firstIndex { $0.id == photoResult.photo.id }
//            .map { Int($0) }
//            .flatMap {
//                photos[$0].isUserLike = photoResult.photo.isUserLike
//                photos[$0].likes = photoResult.photo.likes
//            }
//            self.tableViewDataSource.configure(self.photos)
//            self.tableView.reloadData()
//
//        case .failure:
//            print("좋아요를 실패하였습니다.")
//        }
//    }
//}
//
////MARK: - UISearchBarDelegate
//extension SearchViewController: UISearchBarDelegate {
//    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//        guard let query = searchBar.text else { return }
//        self.query = query
//        self.photos = []
//        self.page = .initialPage
//        searchPhotos()
//        searchBar.text = ""
//        searchBar.resignFirstResponder()
//    }
//}
//
////MARK: - Image List DataSource Delegate
//extension SearchViewController: ImageListDataSourceDelegate {
//    func morePhotos() {
//        searchPhotos()
//    }
//
//    func didTapedLikeButton(photoId: String) {
//        guard TokenManager.shared.isTokenSaved else {
//            let message = "로그인 후 이용해주세요."
//            showAlert(message: message)
//            return
//        }
//
//        fetchLikePhoto(photoId: photoId)
//    }
//}

//MARK: - TabBar Image Info Protocol
extension SearchViewController: TabBarImageInfo {
    var nomal: String {
        return "magnifyingglass.circle"
    }
    
    var selected: String {
        return "magnifyingglass.circle.fill"
    }
    
    var barTitle: String {
        return "Search"
    }
}
