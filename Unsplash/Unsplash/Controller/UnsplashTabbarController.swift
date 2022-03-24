//
//  UnsplashTabbarController.swift
//  Unsplash
//
//  Created by KimJaeYoun on 2021/12/17.
//

import UIKit

enum TabBarType: CustomStringConvertible, CaseIterable {
    case search
    case profile
    case main
    
    var description: String {
        switch self {
        case .search:
            return "Search"
        case .profile:
            return "Profile"
        case .main:
            return "Home"
        }
    }
    
    var normalImage: UIImage? {
        switch self {
        case .search:
            return UIImage(systemName: "magnifyingglass.circle")
        case .main:
            return UIImage(systemName: "house")
        case .profile:
            return UIImage(systemName: "person")
        }
    }
    
    var selectedImage: UIImage? {
        switch self {
        case .main:
            return UIImage(systemName: "house.fill")
        case .search:
            return UIImage(systemName: "magnifyingglass.circle.fill")
        case .profile:
            return UIImage(systemName: "person.fill")
        }
    }
}

final class UnsplashTabbarController: UITabBarController {
    //MARK: Properties
    private let searchViewController = SearchViewController()
    private let profileViewController = ProfileViewController()
    private let mainHomeViewController = MainHomeViewController()

    //MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTabBarController()
    }
}

//MARK: - Method
extension UnsplashTabbarController {
    private func configureTabBarController() {
        delegate = self
        
        TabBarType.allCases.forEach { type in
            setupTabBarItem(for: type)
        }
        
        viewControllers = [
            UINavigationController(rootViewController: searchViewController),
            UINavigationController(rootViewController: mainHomeViewController),
            UINavigationController(rootViewController: profileViewController)
        ]
        
        let firstSelectedIndex = 1
        selectedIndex = firstSelectedIndex
    }
    
    private func setupTabBarItem(for type: TabBarType) {
        let tabBarItem = UITabBarItem(title: String(describing: type),
                                      image: type.normalImage,
                                      selectedImage: type.selectedImage)
        switch type {
        case .search:
            searchViewController.tabBarItem = tabBarItem
        case .profile:
            profileViewController.tabBarItem = tabBarItem
        case .main:
            mainHomeViewController.tabBarItem = tabBarItem
        }
    }
}

//MARK: - TabBarController Transition Animation
extension UnsplashTabbarController: UITabBarControllerDelegate {
    func setSelectedIndex(at index: Int) {
        guard let currentViewcontroller = viewControllers?[index] else { return }
        _ = self.tabBarController(self, shouldSelect: currentViewcontroller)
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        guard let fromView = selectedViewController?.view, let toView = viewController.view else {
            return false
        }
        
        if fromView != toView {
            UIView.transition(from: fromView,
                              to: toView,
                              duration: 0.3, options: [.transitionCrossDissolve])
            
            self.selectedViewController = viewController
        }
        
        return true
    }
}
