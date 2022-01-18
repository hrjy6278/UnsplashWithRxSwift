//
//  UnsplashTabbarController.swift
//  Unsplash
//
//  Created by KimJaeYoun on 2021/12/17.
//

import UIKit

final class UnsplashTabbarController: UITabBarController {
    //MARK: Properties
    private let searchViewController = SearchViewController()
    private let profileViewController = ProfileViewController()
    private let loginViewController = LoginViewController()

    //MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTabBarController()
        setupTabBarItem(for: searchViewController)
        setupTabBarItem(for: profileViewController)
        setupTabBarItem(for: loginViewController)
        
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
    
    private func setupTabBarItem(for controller: UIViewController) {
        guard let info = controller as? TabBarImageInfo else { return }
        
        let tabBarNomalImage = UIImage(systemName: info.nomal)
        let tabBarSelectedImage = UIImage(systemName: info.selected)
        
        let tabBarItem = UITabBarItem(title: info.barTitle,
                                      image: tabBarNomalImage,
                                      selectedImage: tabBarSelectedImage)
        
        controller.tabBarItem = tabBarItem
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
