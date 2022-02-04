//
//  LoginView.swift
//  Unsplash
//
//  Created by KimJaeYoun on 2022/02/04.
//

import UIKit
import RxSwift
import RxCocoa

final class LoginView: UIView {
    //MARK: Properties
    private var descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.generateFont(font: .SDGothichBold, size: 20)
        label.text = "로그인후 이용해 주세요."
        
        return label
    }()
    
    private var loginButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Login", for: .normal)
        button.titleLabel?.font = UIFont.generateFont(font: .SDGothichRegular, size: 18)
        button.layer.cornerRadius = 10
        button.backgroundColor = .lightGray
        button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
        return button
    }()
    
    var loginButtonTaped: Observable<Void> {
        return loginButton.rx.tap.asObservable()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("스토리보드는 지원하지 않습니다.")
    }
}

//MARK: - Setup View And Layout
extension LoginView: HierarchySetupable {
    func setupViewHierarchy() {
        addSubview(descriptionLabel)
        addSubview(loginButton)
    }
    
    func setupLayout() {
        let descriptionLabelConstrant: CGFloat = -40
        NSLayoutConstraint.activate([
            descriptionLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            descriptionLabel.centerYAnchor.constraint(equalTo: centerYAnchor,
                                                      constant: descriptionLabelConstrant),
            
            loginButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            loginButton.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}
