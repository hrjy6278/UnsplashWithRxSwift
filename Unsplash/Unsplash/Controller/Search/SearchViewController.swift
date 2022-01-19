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
    private let disposeBag = DisposeBag()
    
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
        configureNavigationBar()
        bindViewModel()
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
        tableView.rowHeight = view.frame.size.height / 4
    }
    
    private func configureNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "로그인",
                                                                 style: .plain,
                                                                 target: nil,
                                                                 action: nil)
    }
    
    private func configureTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self,
                                                action: #selector(dissmissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func dissmissKeyboard() {
        view.endEditing(true)
    }
    
    private func loadNextPageTrigger() -> ControlEvent<Bool> {
        let source = self.tableView.rx.contentOffset.map { contentOffset -> Bool in
                let visibleHeight = self.tableView.frame.height - self.tableView.contentInset.top - self.tableView.contentInset.bottom
                let y = contentOffset.y + self.tableView.contentInset.top + self.tableView.contentInset.bottom
                let threshold = max(30, self.tableView.contentSize.height - visibleHeight - 30)
                return y >= threshold
        }.distinctUntilChanged()
        
        return ControlEvent(events: source)
    }
}

//MARK: - Method
extension SearchViewController {
    func bindViewModel() {
        let searchObservable = searchBar.rx
            .searchButtonClicked
            .do(onNext: {_ in self.view.endEditing(true) })
            .withLatestFrom(searchBar.rx.text.orEmpty)
        
        let input = SearchViewModel.Input(searchAction: searchObservable,
                                          loadMore: loadNextPageTrigger())
        
        let output = viewModel.bind(input: input)
        
        output
            .navigationTitle
            .drive(navigationItem.rx.title)
            .disposed(by: disposeBag)
        
        output.searchPhotos
            .drive(tableView.rx.items(cellIdentifier: ImageListTableViewCell.cellID,
                                      cellType: ImageListTableViewCell.self)) { indexPath, photo, cell in
                cell.configure(id: photo.id,
                               photographerName: photo.profile.userName,
                               likeCount: String(photo.likes),
                               isUserLike: photo.isUserLike,
                               imageUrl: photo.urls.regularURL)
            }
            .disposed(by: disposeBag)
    }
}

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
