//
//  UnsplashTabbarController.swift
//  Unsplash
//
//  Created by KimJaeYoun on 2021/12/17.
//

import UIKit

final class UnsplashTabbarController: UITabBarController {
    //MARK: Properties
    private lazy var loginButton: UIBarButtonItem = {
        let button = UIBarButtonItem()
        button.target = self
        button.action = #selector(didTapLoginButton(_:))
        
        return button
    }()
    
    private let searchViewController = SearchViewController()
    private let profileViewController = ProfileViewController()
    private let loginViewController = LoginViewController()
    
    private var isTokenSaved: Bool {
        TokenManager.shared.isTokenSaved ? true : false
    }
    
    //MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTabBarController()
        setupTabBarItem(for: searchViewController)
        setupTabBarItem(for: profileViewController)
        setupTabBarItem(for: loginViewController)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigation()
        configureTabBarViewControllers()
    }
}

//MARK: - Method
extension UnsplashTabbarController {
    private func configureTabBarController() {
        delegate = self
    }
    
    private func configureTabBarViewControllers() {
        if isTokenSaved {
            viewControllers = [searchViewController, profileViewController]
        } else {
            viewControllers = [searchViewController, loginViewController]
        }
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
    
    private func configureNavigation() {
        navigationItem.title = "Unsplash"
        navigationItem.rightBarButtonItem = loginButton
        navigationItem.rightBarButtonItem?.title = isTokenSaved ? "로그아웃" : "로그인"
        navigationController?.navigationBar.backgroundColor = .gray
    }
    
    private func logout() {
        TokenManager.shared.clearAccessToken()
        navigationItem.rightBarButtonItem?.title = "로그인"
        
        let searchIndex = 0
        let profileIndex = 1
        setSelectedIndex(at: searchIndex)
        
        viewControllers?[profileIndex] = loginViewController
    }
    
    @objc func didTapLoginButton(_ sender: UIBarButtonItem) {
        if isTokenSaved {
            let logoutMessage = "로그아웃이 완료되었습니다."
            showAlert(message: logoutMessage) { [weak self] _ in
                self?.logout()
            }
        } else {
            navigationController?.pushViewController(Oauth2ViewController(), animated: true)
        }
    }
}

//MARK: - TabBarController Transition Animation
extension UnsplashTabbarController: UITabBarControllerDelegate {
    func setSelectedIndex(at index: Int) {
        guard let currentViewcontroller = viewControllers?[index] else { return }
        let _ = self.tabBarController(self, shouldSelect: currentViewcontroller)
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
