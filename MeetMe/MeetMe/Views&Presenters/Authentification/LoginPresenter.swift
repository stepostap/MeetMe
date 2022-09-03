//
//  LoginVC.swift
//  MeetMe
//
//  Created by Stepan Ostapenko on 26.02.2022.
//

import UIKit

/// Контроллер для входа пользователя в приложение
class LoginVC: UIViewController, UITextFieldDelegate {

    let loginView = LoginView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        view.backgroundColor = UIColor(named: "BackgroundMain")
        view = loginView
        loginView.loginButton.addTarget(self, action: #selector(login), for: .touchUpInside)
        loginView.signUpButton.addTarget(self, action: #selector(signUp), for: .touchUpInside)
    }
    
    /// Проверка введенных почты и пароля на корректность
    private func loginAndPasswordCheck() throws {
        if let email = loginView.emailTextField.text {
            if email.isEmpty {
                throw LoginErrors.emptyLogin
            }
            if !ErrorChecker.isEmailValid(email){
                throw LoginErrors.invalidEmail
            }
        } else {
            throw LoginErrors.invalidEmail
        }
        
        if let password = loginView.passwordTextField.text {
            if password.isEmpty {
                throw LoginErrors.emptyPassword
            }
        } else {
            throw LoginErrors.invalidPassword
        }
        
    }
    
    /// Вход пользователя в приложение
    @objc private func login() {
        do {
            try loginAndPasswordCheck()
        } catch let error {
            let alert = ErrorChecker.handler.getAlertController(error: error)
            present(alert, animated: true, completion: nil)
            return
        }
        
        let email = loginView.emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = loginView.passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        loginView.loader.startAnimating()
       
        AuthRequests.shared.getJWTToken(info: JWTBullshit(email: email, password: password), completion: {(token, error) in
            if let error = error {
                self.loginView.loader.stopAnimating()
                let alert = ErrorChecker.handler.getAlertController(error: error)
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            if let token = token {
                MeetMeRequests.JWTToken = token
                AuthRequests.shared.login(info: LoginInfo(email: email, password: password), completion: { (account, error) in
                    self.loginView.loader.stopAnimating()
                    if let error = error {
                        let alert = ErrorChecker.handler.getAlertController(error: error)
                        self.present(alert, animated: true, completion: nil)
                        self.loginView.loader.stopAnimating()
                        return
                    }

                    if let account = account {

                        if self.loginView.shouldSaveLoginAndPassword!.isChecked {
                            UserDefaults.standard.set(email, forKey: "userEmail")
                            UserDefaults.standard.set(password, forKey: "userPassword")
                            print("saved \(email) and \(password) to user defaults")
                        }

                        User.currentUser.account = account
                        self.view.setRootViewController(NavigationHandler.createTabBar(), animated: true)
                    }
                })
            }
        })
    }
    
    /// Кнопка для перехода на контроллер регистрации 
    @objc private func signUp() {
        self.navigationController?.pushViewController(SignUpVC(), animated: true)
    }
}
