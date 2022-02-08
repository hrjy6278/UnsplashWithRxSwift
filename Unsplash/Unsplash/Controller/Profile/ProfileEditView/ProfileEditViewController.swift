//
//  ProfileEditViewController.swift
//  Unsplash
//
//  Created by KimJaeYoun on 2022/02/08.
//

import UIKit

class ProfileEditViewController: UIViewController {
    var viewModel: ProfileEditViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configureNavigationView()
    }
}

extension ProfileEditViewController {
    private func configureNavigationView() {
        navigationItem.largeTitleDisplayMode = .always
        navigationItem.title = "Profile Edit"
    }
}
