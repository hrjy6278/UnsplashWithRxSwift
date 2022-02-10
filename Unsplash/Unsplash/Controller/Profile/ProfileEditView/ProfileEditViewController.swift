//
//  ProfileEditViewController.swift
//  Unsplash
//
//  Created by KimJaeYoun on 2022/02/08.
//

import UIKit
import RxSwift
import RxKeyboard
import Kingfisher

class ProfileEditViewController: UIViewController {
    //MARK: - Properties
    private let disposeBag = DisposeBag()
    private let viewModel: ProfileEditViewModel
    
    @IBOutlet weak var loadingActivitiyIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var bioTextView: UITextView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    
    //MARK: - View Life Cycle And initaililzer
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configureKeyboardHeight()
        configureButtons()
        configureTextField()
        bindViewModel()
    }
    
    init(viewModel: ProfileEditViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("스토리보드는 지원하지 않습니다.")
    }
}

//MARK: - BindViewModel
extension ProfileEditViewController {
    func bindViewModel() {
        let userName = userNameTextField.rx.text.orEmpty.asObservable()
        let firstName = firstNameTextField.rx.text.orEmpty.asObservable()
        let lastName = lastNameTextField.rx.text.orEmpty.asObservable()
        let location = locationTextField.rx.text.orEmpty.asObservable()
        let bio = bioTextView.rx.text.orEmpty.asObservable()
        let saveButtonTaped = saveButton.rx.tap.asObservable()
        
        let input = ProfileEditViewModel.Input(userName: userName,
                                               firstName: firstName,
                                               lastName: lastName,
                                               location: location,
                                               bio: bio,
                                               saveButtonTaped: saveButtonTaped)
        
        let output = viewModel.bind(input: input)
        
        output.userName
            .drive(userNameTextField.rx.text)
            .disposed(by: disposeBag)
        
        output.firstName
            .drive(firstNameTextField.rx.text)
            .disposed(by: disposeBag)
        
        output.lastName
            .drive(lastNameTextField.rx.text)
            .disposed(by: disposeBag)
        
        output.location
            .drive(locationTextField.rx.text)
            .disposed(by: disposeBag)
        
        output.bio
            .drive(bioTextView.rx.text)
            .disposed(by: disposeBag)
        
        output.isSavedProfile
            .subscribe(onNext: { [weak self] isSavedProfile in
                self?.isSaveProfile(isSavedProfile)
            })
            .disposed(by: disposeBag)
        
        output.profileImageURL
            .drive(onNext: { [weak self] profileImageURL in
                guard let self = self else { return }
                let cornerRadius = self.profileImageView.bounds.height / 2
                let processor = RoundCornerImageProcessor(cornerRadius: cornerRadius)
                
                self.profileImageView
                    .kf
                    .setImage(with: profileImageURL, options: [.processor(processor)])
            })
            .disposed(by: disposeBag)
        
        cancelButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                self?.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
    }
}

//MARK: - Configuration UI
extension ProfileEditViewController {
    private func configureKeyboardHeight() {
        RxKeyboard.instance.visibleHeight
            .drive(onNext: { [weak self] keyboardVisibleHeight in
                guard let self = self else { return }
                UIView.animate(withDuration: .zero) {
                    self.scrollView.contentInset.bottom = keyboardVisibleHeight
                    self.scrollView.verticalScrollIndicatorInsets.bottom = self.scrollView.contentInset.bottom
                }
            })
            .disposed(by: disposeBag)
        
        RxKeyboard.instance.willShowVisibleHeight
            .drive(onNext: { [weak self] keyboardVisibleHeight in
                guard let self = self else { return }
                self.scrollView.contentOffset.y += keyboardVisibleHeight
            })
            .disposed(by: disposeBag)
    }
    
    private func configureButtons() {
        saveButton.layer.cornerRadius = saveButton.bounds.height / 2
        saveButton.layer.masksToBounds = false
        
        cancelButton.layer.cornerRadius = cancelButton.bounds.height / 2
        cancelButton.layer.masksToBounds = false
        cancelButton.layer.borderColor = UIColor.systemBlue.cgColor
        cancelButton.layer.borderWidth = 1
    }
    
    private func configureTextField() {
        userNameTextField.delegate = self
        firstNameTextField.delegate = self
        lastNameTextField.delegate = self
        locationTextField.delegate = self
    }
    
    private func isSaveProfile(_ isSaved: Bool) {
        if isSaved {
            loadingActivitiyIndicatorView.isHidden = true
            dismiss(animated: true, completion: nil)
        } else {
            loadingActivitiyIndicatorView.isHidden = false
        }
    }
}

//MARK: - UITextField Delegate
extension ProfileEditViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
}
