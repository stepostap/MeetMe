//
//  LoginVC.swift
//  MeetMe
//
//  Created by Stepan Ostapenko on 26.02.2022.
//

import UIKit

class LoginVC: UIViewController, UITextFieldDelegate {
    
    let loginButton = UIButton()
    let signUpButton = UIButton()
    let loader = UIActivityIndicatorView()
    var shouldSaveLoginAndPassword: CheckBox?
    
    let emailTextField : UITextField = {
        let textField = UITextField(frame: CGRect(x: 0, y: 0, width: 300, height: 30))
        textField.keyboardType = UIKeyboardType.default
        textField.returnKeyType = UIReturnKeyType.done
        textField.autocorrectionType = UITextAutocorrectionType.no
        textField.clearButtonMode = UITextField.ViewMode.whileEditing;
        textField.textAlignment = .left
        textField.placeholder = "email"
        textField.text = "Stepostap@gmail.com"
        return textField
    }()
    
    let passwordTextField : UITextField = {
        let textField = UITextField(frame: CGRect(x: 0, y: 0, width: 300, height: 30))
        textField.keyboardType = UIKeyboardType.default
        textField.returnKeyType = UIReturnKeyType.done
        textField.autocorrectionType = UITextAutocorrectionType.no
        textField.clearButtonMode = UITextField.ViewMode.whileEditing;
        textField.textAlignment = .left
        textField.placeholder = "password"
        textField.isSecureTextEntry = true
        textField.text = "12345"
        return textField
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        configView()
    }
    
    private func configView() {
        Utilities.styleTextField(emailTextField)
        Utilities.styleTextField(passwordTextField)
        Utilities.styleFilledButton(loginButton)
        Utilities.styleHollowButton(signUpButton)
        
        view.addSubview(emailTextField)
        emailTextField.pinCenter(to: view.safeAreaLayoutGuide.centerXAnchor, const: 0)
        emailTextField.setWidth(to: 300)
        emailTextField.pinTop(to: view.safeAreaLayoutGuide.topAnchor, const: 150)
        emailTextField.delegate = self
        
        view.addSubview(passwordTextField)
        passwordTextField.pinCenter(to: view.safeAreaLayoutGuide.centerXAnchor, const: 0)
        passwordTextField.setWidth(to: 300)
        passwordTextField.pinTop(to: emailTextField.bottomAnchor, const: 20)
        passwordTextField.delegate = self
        
        shouldSaveLoginAndPassword = CheckBox.init()
        shouldSaveLoginAndPassword?.style = .tick
        shouldSaveLoginAndPassword?.borderStyle = .roundedSquare(radius: 5)
        view.addSubview(shouldSaveLoginAndPassword!)
        shouldSaveLoginAndPassword?.setWidth(to: 20)
        shouldSaveLoginAndPassword?.setHeight(to: 20)
        shouldSaveLoginAndPassword?.pinLeft(to: passwordTextField.leadingAnchor, const: 0)
        shouldSaveLoginAndPassword?.pinTop(to: passwordTextField.bottomAnchor, const: 25)
        
        let staySignedInLabel = UILabel()
        view.addSubview(staySignedInLabel)
        staySignedInLabel.text = "Запомнить логин и пароль"
        staySignedInLabel.pinTop(to: passwordTextField.bottomAnchor, const: 25)
        staySignedInLabel.pinLeft(to: shouldSaveLoginAndPassword!.trailingAnchor, const: 10)
        staySignedInLabel.setWidth(to: 250)
        staySignedInLabel.setHeight(to: 20)
        
        loader.hidesWhenStopped = true
        view.addSubview(loader)
        loader.pinTop(to: staySignedInLabel.bottomAnchor, const: 20)
        loader.pinCenter(to: view.safeAreaLayoutGuide.centerXAnchor, const: 0)
        loader.setWidth(to: 30)
        loader.setHeight(to: 30)
        
        loginButton.setTitle("Login", for: .normal)
        view.addSubview(loginButton)
        loginButton.pinTop(to: loader.bottomAnchor, const: 30)
        loginButton.pinCenter(to: view.safeAreaLayoutGuide.centerXAnchor, const: 0)
        loginButton.setWidth(to: 200)
        loginButton.setHeight(to: 30)
        loginButton.addTarget(self, action: #selector(login), for: .touchUpInside)
        
        view.addSubview(signUpButton)
        signUpButton.pinTop(to: loginButton.bottomAnchor, const: 10)
        signUpButton.pinCenter(to: view.safeAreaLayoutGuide.centerXAnchor, const: 0)
        signUpButton.setWidth(to: 200)
        signUpButton.setHeight(to: 30)
        signUpButton.setTitle("Sign Up", for: .normal)
        signUpButton.setTitleColor(.black, for: .normal)
        signUpButton.addTarget(self, action: #selector(signUp), for: .touchUpInside)
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
    
    private func loginAndPasswordCheck() throws {
        if let email = emailTextField.text {
            if email.isEmpty {
                throw LoginErrors.emptyLogin
            }
            if !ErrorChecker.isEmailValid(email){
                throw LoginErrors.invalidEmail
            }
        } else {
            throw LoginErrors.invalidEmail
        }
        
        if let password = passwordTextField.text {
            if password.isEmpty {
                throw LoginErrors.emptyPassword
            }
        } else {
            throw LoginErrors.invalidPassword
        }
        
    }

    @objc func login() {
        
        do {
            try loginAndPasswordCheck()
                
        } catch let error {
            let alert = ErrorChecker.handler.getAlertController(error: error)
            present(alert, animated: true, completion: nil)
            return
        }
        
        let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        loader.startAnimating()
        
        Networker.shared.loginUser(email: email, password: password, completion: { (user, error) in
            if let error = error {
                let alert = ErrorChecker.handler.getAlertController(error: error)
                self.present(alert, animated: true, completion: nil)
                self.loader.stopAnimating()
                return
            }
            
            if let user = user {
                
                if self.shouldSaveLoginAndPassword!.isChecked {
                    UserDefaults.standard.set(email, forKey: "userName")
                    UserDefaults.standard.set(password, forKey: "userPassword")
                    
                }
                
                User.currentUser = user
                self.loader.stopAnimating()
                self.view.setRootViewController(NavigationHandler.createTabBar(), animated: true)
            }
            
        })
    }
    
    
    @objc func signUp() {
        
        self.navigationController?.pushViewController(SignUpVC(), animated: true)
    }
}
