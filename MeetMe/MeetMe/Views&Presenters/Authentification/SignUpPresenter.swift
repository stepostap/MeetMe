//
//  SignUpVC.swift
//  MeetMe
//
//  Created by Stepan Ostapenko on 26.02.2022.
//

import UIKit

/// Контроллер, отвечающий за регистрацию пользователя
class SignUpVC: UIViewController, UITextFieldDelegate {
    
    let signUpView = SignUpView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view = signUpView
        signUpView.signUpButton.addTarget(self, action: #selector(signUp), for: .touchUpInside)
    }
    
    /// Проверка введенных логина и пароля на корректность
    private func loginAndPasswordCheck() throws {
        if let email = signUpView.emailTextField.text {
            if email.isEmpty {
                throw RegisterErrors.emptyEmail
            }
            if !ErrorChecker.isEmailValid(email){
                throw LoginErrors.invalidEmail
            }
        } else {
            throw LoginErrors.invalidEmail
        }
        
        if let name = signUpView.nameTextField.text {
            if name.isEmpty {
                throw RegisterErrors.emptyName
            }
        } else {
            throw RegisterErrors.emptyName
        }
        
        if let password = signUpView.passwordTextField.text {
            if password.isEmpty {
                throw RegisterErrors.emptyPassword
            }
            if !password.elementsEqual(signUpView.passwordRepeatTextField.text!) {
                throw RegisterErrors.passwordsDontMatch
            }
        } else {
            throw LoginErrors.invalidPassword
        }
        
    }
    
    /// Осуществление регистрации пользователя
    @objc private func signUp() {
        do {
            try loginAndPasswordCheck()
            
        } catch let error {
            let alert = ErrorChecker.handler.getAlertController(error: error)
            present(alert, animated: true, completion: nil)
            return
        }
        signUpView.loader.startAnimating()
        let name = signUpView.nameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let email = signUpView.emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = signUpView.passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        AuthRequests.shared.register(info: RegisterInfo(email: email, password: password, fullName: name), completion: { (account, error) in
            if let error = error {
                self.signUpView.loader.stopAnimating()
                let alert = ErrorChecker.handler.getAlertController(error: error)
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            if let account = account {
                User.currentUser = User()
                User.currentUser.account = account
                
                AuthRequests.shared.getJWTToken(info: JWTBullshit(email: email, password: password), completion: {(token, error) in
                    self.signUpView.loader.stopAnimating()
                    if let error = error {
                        let alert = ErrorChecker.handler.getAlertController(error: error)
                        self.present(alert, animated: true, completion: nil)
                        return
                    }
                    if let token = token {
                        MeetingRequests.JWTToken = token
                        self.view.setRootViewController(NavigationHandler.createTabBar(), animated: true)
                    }
                })
            }
        })
    }
}
