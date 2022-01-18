//
//  Extension + UIViewController.swift
//  Unsplash
//
//  Created by KimJaeYoun on 2021/12/24.
//

import UIKit

extension UIViewController {
    func showAlert(message: String, completion: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController.generateOneActionAlert(message: message,
                                                 completionHanlder: completion)
        
        present(alert, animated: true, completion: nil)
    }
}
