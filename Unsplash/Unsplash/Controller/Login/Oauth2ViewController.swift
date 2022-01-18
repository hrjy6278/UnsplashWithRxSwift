//
//  LoginViewController.swift
//  Unsplash
//
//  Created by KimJaeYoun on 2021/12/21.
//

import UIKit
import AuthenticationServices

final class Oauth2ViewController: UIViewController {
    //MARK: Properties
    private var webAuthenticationSession: ASWebAuthenticationSession?
    private let unsplashAPIManager = UnsplashAPIManager()
    
    //MARK: View Life Cycle
    override func viewDidLoad() {
        view.backgroundColor = .white
    }
    
    override func viewDidAppear(_ animated: Bool) {
        getAuthrization()
    }
}

//MARK: - Authrization Method
extension Oauth2ViewController {
    private func getAuthrization() {
        guard let URL = try? UnsplashRouter.userAuthorize.asURLRequest().url else { return }
        let ASwebCallbackURLScheme = "jissCallback"
        
        webAuthenticationSession = generateASWebAuthenticationSession(url: URL,
                                                                      callbackURLScheme: ASwebCallbackURLScheme)
        webAuthenticationSession?.presentationContextProvider = self
        webAuthenticationSession?.start()
    }
    
    private func generateASWebAuthenticationSession(url: URL,
                                                    callbackURLScheme: String) -> ASWebAuthenticationSession {
        return ASWebAuthenticationSession(url: url,
                                          callbackURLScheme: callbackURLScheme) { [weak self] callBackURL, erorr in
            guard let self = self else { return }
            
            guard erorr == nil,
                  let callBackURL = callBackURL,
                  let accessCode = callBackURL.getValue(for: "code") else {
                      let message = "로그인에 실패하였습니다. 다시 시도해주세요."
                      self.showAlert(message: message) { _ in
                          self.navigationController?.popViewController(animated: true)
                      }
                      return
                  }
            
//            self.unsplashAPIManager.fetchAccessToken(accessCode: accessCode) { isSuccess in
//                if isSuccess == false {
//                    let message = "로그인에 실패하였습니다. 다시 시도해주세요."
//                    self.showAlert(message: message)
//                }
//                self.navigationController?.popViewController(animated: true)
//            }
        }
    }
}

extension Oauth2ViewController: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return ASPresentationAnchor()
    }
}
