//
//  Extension + UIAlertController.swift
//  Unsplash
//
//  Created by KimJaeYoun on 2021/12/24.
//

import UIKit

extension UIAlertController {
    static func generateOneActionAlert(
        message: String,
        completionHanlder: ((UIAlertAction) -> Void)? = nil
    ) -> UIAlertController {
        
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .cancel, handler: completionHanlder)
        
        alert.addAction(okAction)
        
        return alert
    }
}
