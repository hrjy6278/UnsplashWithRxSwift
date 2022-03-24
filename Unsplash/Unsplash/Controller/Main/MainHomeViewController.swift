//
//  MainHomeViewController.swift
//  Unsplash
//
//  Created by KimJaeYoun on 2022/03/23.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class MainHomeViewController: UIViewController {
    //MARK: - Properties
    private let viewModel = MainHomeViewModel()
    private let disposeBag = DisposeBag()
    private var headerList = [String]()
    private let pageViewController = UIPageViewController(transitionStyle: .scroll,
                                                          navigationOrientation: .horizontal)
    
    private lazy var headerView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: .zero, left: 8, bottom: .zero, right: 8)
        layout.scrollDirection = .horizontal
    
        let collectionView = UICollectionView(frame: .zero,
                                              collectionViewLayout: layout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(MainHeaderViewCell.self,
                                forCellWithReuseIdentifier: MainHeaderViewCell.cellID)
        collectionView.delegate = self
        
        return collectionView
    }()
    
    //MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupController()
        bindViewModel()
        
        let initialIndexPath = IndexPath(item: .zero, section: .zero)
        headerView.selectItem(at: initialIndexPath,
                              animated: true,
                              scrollPosition: .centeredHorizontally)
    }
}

//MARK: - Configure Views And Layout
extension MainHomeViewController: HierarchySetupable {
    func setupController() {
        view.backgroundColor = .white
        navigationItem.title = "Home"
    }
    
    func setupViewHierarchy() {
        view.addSubview(headerView)
    }
    
    func setupLayout() {
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 44)
        ])
    }
}

//MARK: - Bind View Model
extension MainHomeViewController {
    func bindViewModel() {
        let viewWillAppear = rx.sentMessage(#selector(UIViewController.viewWillAppear(_:)))
            .map { _ in }
        
        let input = MainHomeViewModel.Input(viewWillAppear: viewWillAppear)
        
        let output = viewModel.bind(input: input)
        
        output.itemList.bind(to: headerView.rx.items) { (collectionView,row,element) -> UICollectionViewCell in
            let indexPath = IndexPath(item: row, section: 0)
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MainHeaderViewCell.cellID, for: indexPath) as! MainHeaderViewCell
            
            cell.configure(title: element)
            
            return cell
        }.disposed(by: disposeBag)
        
        output.itemList.subscribe(onNext: { [weak self] itemList in
            self?.headerList = itemList
        })
        .disposed(by: disposeBag)
        
        headerView.rx.itemSelected.subscribe(onNext: { [weak self] indexPath in
            self?.headerView.scrollToItem(at: indexPath,
                                    at: .centeredHorizontally,
                                    animated: true)
        })
        .disposed(by: disposeBag)
    }
}

//MARK: - Page View Controller Delegate
extension MainHomeViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        return nil
    }
}

//MARK: - CollectionView Delegate
extension MainHomeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: headerList[indexPath.item].size(withAttributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14)]).width + 20, height: 32)
        }
}
