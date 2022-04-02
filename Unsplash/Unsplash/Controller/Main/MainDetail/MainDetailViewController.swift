//
//  MainListViewController.swift
//  Unsplash
//
//  Created by KimJaeYoun on 2022/04/01.
//

import UIKit
import RxSwift

final class MainDetailViewController<T: ListModelType>: UIViewController {
    //MARK: Properties
    private let viewModel: MainDetailViewModel<T>
    private let disposeBag = DisposeBag()
    private let imageListCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero,
                                              collectionViewLayout: ColumnFlowLayout())
        collectionView.register(ImageListViewCell.self,
                                forCellWithReuseIdentifier: ImageListViewCell.cellID)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.keyboardDismissMode = .onDrag
        
        return collectionView
    }()

    //MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        bindViewModel()
    }
    
    init(viewModel: MainDetailViewModel<T>) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("스토리보드는 지원하지 않습니다..")
    }
}

//MARK: Setup Layout
extension MainDetailViewController: HierarchySetupable {
    func setupViewHierarchy() {
        view.addSubview(imageListCollectionView)
    }
    
    func setupLayout() {
        NSLayoutConstraint.activate([
            imageListCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            imageListCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageListCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageListCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func bindViewModel() {
        let viewWillAppear = rx.sentMessage(#selector(UIViewController.viewWillAppear(_:)))
            .take(1)
            .map { _ in }
        let input = MainDetailViewModel<T>.Input(viewLoded: viewWillAppear)
        let output = viewModel.bind(input: input)
        
        output.list.bind(to: imageListCollectionView.rx.items) { collectionView,indexItem,source in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageListViewCell.cellID,
                                                          for: IndexPath(item: indexItem,
                                                                         section: 0)) as! ImageListViewCell
            cell.configure(id: source.id ?? "",
                           photographerName: nil,
                           likeCount: nil,
                           isUserLike: false,
                           imageUrl: source.coverPhoto?.urls.regularURL ?? source.URL?.regularURL)
            return cell
        }
        .disposed(by: disposeBag)
    }
}
