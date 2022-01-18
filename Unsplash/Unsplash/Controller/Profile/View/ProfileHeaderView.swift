//
//  ProfileHeaderView.swift
//  Unsplash
//
//  Created by KimJaeYoun on 2021/12/22.
//

import UIKit
import Kingfisher

final class ProfileHeaderView: UIView {
    //MARK: Properties
    private var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        
        return imageView
    }()
    
    private var nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.preferredFont(forTextStyle: .title2)
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        return label
    }()
    
    private var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fillProportionally
        stackView.spacing = 8
        
        return stackView
    }()
    
    //MARK: - View Life Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("스토리보드는 지원하지 않습니다.")
    }
}

//MARK: - Setup View And Layout
extension ProfileHeaderView: HierarchySetupable {
    func setupViewHierarchy() {
        stackView.addArrangedSubview(profileImageView)
        stackView.addArrangedSubview(nameLabel)
      
        addSubview(stackView)
    }
    
    func setupLayout() {
        let stackViewLeadingConstant: CGFloat = 16
        
        NSLayoutConstraint.activate([
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor,
                                               constant: stackViewLeadingConstant)
        ])
    }
}

//MARK: - Configure Method
extension ProfileHeaderView {
    func configure(selfieURL: URL?, name: String?) {
        self.nameLabel.text = name
        
        let processor = RoundCornerImageProcessor(cornerRadius: 50)
        profileImageView.kf.setImage(with: selfieURL, options: [.processor(processor)])
    }
}
