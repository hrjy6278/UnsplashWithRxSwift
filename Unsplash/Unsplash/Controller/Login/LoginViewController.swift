//
//  LoginViewController.swift
//  Unsplash
//
//  Created by KimJaeYoun on 2021/12/23.
//

import UIKit

final class LoginViewController: UIViewController {
    //MARK: Properties
    private var descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.preferredFont(forTextStyle: .callout)
        label.text = "로그인이 필요합니다."
        
        return label
    }()
    
    private var loginButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Login", for: .normal)
        button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .body)
        button.addTarget(self, action: #selector(didTapLoginButton(_:)), for: .touchUpInside)
        button.layer.cornerRadius = 5
        button.backgroundColor = .gray
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupView()
    }
}

//MARK: - Setup View And Layout
extension LoginViewController: HierarchySetupable {
    func setupViewHierarchy() {
        view.addSubview(descriptionLabel)
        view.addSubview(loginButton)
    }
    
    func setupLayout() {
        let descriptionLabelConstrant: CGFloat = -40
        NSLayoutConstraint.activate([
            descriptionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            descriptionLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor,
                                                      constant: descriptionLabelConstrant),
            
            loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loginButton.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}

//MARK: - Login Button Action
extension LoginViewController {
    @objc func didTapLoginButton(_ sender: UIButton) {
        navigationController?.pushViewController(OAuth2ViewController(), animated: true)
    }
}
