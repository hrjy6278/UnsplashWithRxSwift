//
//  ViewController.swift
//  Unsplash
//
//  Created by KimJaeYoun on 2021/12/17.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

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
    
    private var dataSource: RxTableViewSectionedReloadDataSource<SearchSection>?
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupView()
        configureTableView()
        configureTapGesture()
        configureNavigationBar()
        configureDataSource()
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
    
    private func configureDataSource() {
        dataSource = RxTableViewSectionedReloadDataSource<SearchSection> { _, tableView, indexPath, cellModel in
            let cell = tableView.dequeueReusableCell(withIdentifier: ImageListTableViewCell.cellID,
                                                     for: indexPath) as! ImageListTableViewCell
            
            cell.configure(id: cellModel.id,
                           photographerName: cellModel.profile.userName,
                           likeCount: String(cellModel.likes),
                           isUserLike: cellModel.isUserLike,
                           imageUrl: cellModel.urls.regularURL)
            
            return cell
        }
    }
    
    private func configureTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self,
                                                action: #selector(dissmissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func dissmissKeyboard() {
        view.endEditing(true)
    }
}

//MARK: - Method
extension SearchViewController {
    func bindViewModel() {
        let searchObservable = searchBar.rx
            .searchButtonClicked
            .do(onNext: {_ in self.view.endEditing(true) })
            .withLatestFrom(searchBar.rx.text.orEmpty)
         
        let loadMore = tableView.rx.contentOffset.flatMap { CGPoint in
            self.tableView.rx.loadNextPageTrigger(offset: CGPoint)
        }
        
        let input = SearchViewModel.Input(searchAction: searchObservable,
                                          loadMore: loadMore)
        
        let output = viewModel.bind(input: input)
        
        output
            .navigationTitle
            .drive(navigationItem.rx.title)
            .disposed(by: disposeBag)
        
        dataSource.flatMap { dataSource in
            output.tavleViewModel
                    .bind(to: tableView.rx.items(dataSource: dataSource))
                    .disposed(by: disposeBag)
        }
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
