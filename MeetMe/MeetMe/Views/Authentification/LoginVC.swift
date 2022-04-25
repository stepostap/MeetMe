//
//  LoginVC.swift
//  MeetMe
//
//  Created by Stepan Ostapenko on 26.02.2022.
//

import UIKit

/// Контроллер для входа пользователя в приложение
class LoginVC: UIViewController, UITextFieldDelegate {
    ///  Кнопка для входа
    private let loginButton = UIButton(type: .system)
    /// Кнопка для регистрации
    private let signUpButton = UIButton(type: .system)
    /// Идентификатор загрузки
    private let loader = UIActivityIndicatorView()
    /// Требуется ли сохранять на устройстве логин и пароль для повторного входа
    private var shouldSaveLoginAndPassword: CheckBox?
    /// Текстовое поле для ввода электронной почты пользователя
    private let emailTextField : UITextField = {
        let textField = UITextField(frame: CGRect(x: 0, y: 0, width: 300, height: 30))
        textField.keyboardType = UIKeyboardType.default
        textField.returnKeyType = UIReturnKeyType.done
        textField.autocorrectionType = UITextAutocorrectionType.no
        textField.clearButtonMode = UITextField.ViewMode.whileEditing;
        textField.textAlignment = .left
        textField.placeholder = "Почта"
        return textField
    }()
    /// Текстовое поле для ввода пароля пользователя
    private let passwordTextField : UITextField = {
        let textField = UITextField(frame: CGRect(x: 0, y: 0, width: 300, height: 30))
        textField.keyboardType = UIKeyboardType.default
        textField.returnKeyType = UIReturnKeyType.done
        textField.autocorrectionType = UITextAutocorrectionType.no
        textField.clearButtonMode = UITextField.ViewMode.whileEditing;
        textField.textAlignment = .left
        textField.placeholder = "Пароль"
        textField.isSecureTextEntry = true
        return textField
    }()
    var alerts = [UIAlertController]()
    var curAlert = 0
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        view.backgroundColor = UIColor(named: "BackgroundMain")
        configView()
    }
    
    
    /// Формирование экрана логина
    private func configView() {
        Styling.styleTextField(emailTextField)
        Styling.styleTextField(passwordTextField)
        Styling.styleFilledButton(loginButton)
        Styling.styleHollowButton(signUpButton)
        
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
        //shouldSaveLoginAndPassword?.style = .tick
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
        
        loginButton.setTitle("Войти", for: .normal)
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
        signUpButton.setTitle("Зарегистрироваться", for: .normal)
        signUpButton.setTitleColor(.systemBlue, for: .normal)
        signUpButton.addTarget(self, action: #selector(signUp), for: .touchUpInside)
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
    
    /// Проверка введенных почты и пароля на корректность
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
    
    /// Вход пользователя в приложение
    @objc private func login() {
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
       
        AuthRequests.shared.getJWTToken(info: JWTBullshit(email: email, password: password), completion: {(token, error) in
            if let error = error {
                self.loader.stopAnimating()
                let alert = ErrorChecker.handler.getAlertController(error: error)
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            if let token = token {
                MeetMeRequests.JWTToken = token
                AuthRequests.shared.login(info: LoginInfo(email: email, password: password), completion: { (account, error) in
                    self.loader.stopAnimating()
                    if let error = error {
                        let alert = ErrorChecker.handler.getAlertController(error: error)
                        self.present(alert, animated: true, completion: nil)
                        self.loader.stopAnimating()
                        return
                    }

                    if let account = account {

                        if self.shouldSaveLoginAndPassword!.isChecked {
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
