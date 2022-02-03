//
//  LoginViewController.swift
//  Unsplash
//
//  Created by KimJaeYoun on 2021/12/21.
//

import UIKit
import RxSwift

final class OAuth2ViewController: UIViewController {
    //MARK: Properties
    private var viewModel = OAuth2ViewModel()
    private let disposeBag = DisposeBag()
    
    //MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        bindViewModel()
    }
}

//MARK: - Method
extension OAuth2ViewController {
    func bindViewModel() {
        let viewDidAppear = rx.sentMessage(#selector(UIViewController.viewDidAppear(_:))).map { _ in }
        
        let input = OAuth2ViewModel.Input(viewDidAppear: viewDidAppear)
        
        let output = viewModel.bind(input: input)
        
        output.tryLoginResult
            .withUnretained(self)
            .subscribe(onNext: { `self`, _ in
                self.dismiss(animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
    }
}
