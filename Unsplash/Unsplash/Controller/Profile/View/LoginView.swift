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
    //MARK: - Properties
    private var descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.generateFont(font: .SDGothichBold, size: 20)
        label.textColor = .white
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
    
    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        
        return imageView
    }()
    
    var loginButtonTaped: Observable<Void> {
        return loginButton.rx.tap.asObservable()
    }
    
    //MARK: - initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        translatesAutoresizingMaskIntoConstraints = false
        clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("스토리보드는 지원하지 않습니다.")
    }
}

//MARK: - Setup View And Layout
extension LoginView: HierarchySetupable {
    func setupViewHierarchy() {
        addSubview(backgroundImageView)
        addSubview(descriptionLabel)
        addSubview(loginButton)
    }
    
    func setupLayout() {
        let descriptionLabelConstrant: CGFloat = -40
        NSLayoutConstraint.activate([
            backgroundImageView.widthAnchor.constraint(equalTo: widthAnchor),
            backgroundImageView.heightAnchor.constraint(equalTo: heightAnchor),
            
            descriptionLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            descriptionLabel.centerYAnchor.constraint(equalTo: centerYAnchor,
                                                      constant: descriptionLabelConstrant),
            
            loginButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            loginButton.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    func configureBackgroundImage(_ imageURL: URL?) {
        let animateDration: TimeInterval = 30
        let animateScaleX = 1.3
        let animateScaleY = 1.3
        backgroundImageView.kf.setImage(with: imageURL) { [weak self] _ in
            UIView.animate(withDuration: animateDration,
                           delay: .zero,
                           options: .curveLinear) {
                self?.backgroundImageView.transform = CGAffineTransform.identity.scaledBy(x: animateScaleX, y: animateScaleY)
            } completion: { _ in
                self?.backgroundImageView.transform = CGAffineTransform.identity
            }
        }
    }
}
