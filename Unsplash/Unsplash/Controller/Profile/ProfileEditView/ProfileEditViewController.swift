//
//  ProfileEditViewController.swift
//  Unsplash
//
//  Created by KimJaeYoun on 2022/02/08.
//

import UIKit
import RxSwift
import RxKeyboard

class ProfileEditViewController: UIViewController {
    private let disposeBag = DisposeBag()
    var viewModel: ProfileEditViewModel?
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configureKeyboardHeight()
    }
}

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
}
