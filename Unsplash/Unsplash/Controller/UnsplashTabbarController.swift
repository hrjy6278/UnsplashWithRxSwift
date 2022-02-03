//
//  UnsplashTabbarController.swift
//  Unsplash
//
//  Created by KimJaeYoun on 2021/12/17.
//

import UIKit

enum TabBarType: CustomStringConvertible {
    case search
    case profile
    
    var description: String {
        switch self {
        case .search:
            return "Search"
        case .profile:
            return "Profile"
        }
    }
    
    var normalImage: UIImage? {
        switch self {
        case .search:
            return UIImage(systemName: "magnifyingglass.circle")
        case .profile:
            return UIImage(systemName: "person")
        }
    }
    
    var selectedImage: UIImage? {
        switch self {
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
    private let loginViewController = LoginViewController()

    //MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTabBarController()
        setupTabBarItem(for: .search)
        setupTabBarItem(for: .profile)
        
        viewControllers = [
            UINavigationController(rootViewController: searchViewController),
            UINavigationController(rootViewController: profileViewController)
        ]
    }
}

//MARK: - Method
extension UnsplashTabbarController {
    private func configureTabBarController() {
        delegate = self
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
