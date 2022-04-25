//
//  SignUpVC.swift
//  MeetMe
//
//  Created by Stepan Ostapenko on 26.02.2022.
//

import UIKit

/// Контроллер, отвечающий за регистрацию пользователя
class SignUpVC: UIViewController, UITextFieldDelegate {
    
    /// Текстовое поле для ввода имени пользователя
    private let nameTextField : UITextField = {
        let textField = UITextField(frame: CGRect(x: 0, y: 0, width: 300, height: 30))
        textField.keyboardType = UIKeyboardType.default
        textField.returnKeyType = UIReturnKeyType.done
        textField.autocorrectionType = UITextAutocorrectionType.no
        textField.clearButtonMode = UITextField.ViewMode.whileEditing;
        textField.textAlignment = .left
        textField.placeholder = "Имя"
        return textField
    }()
    
    /// Текстовое поле для ввода почты пользователя
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
    
    ///  Текстовое поле для повторения введенного пароля
    private let passwordRepeatTextField : UITextField = {
        let textField = UITextField(frame: CGRect(x: 0, y: 0, width: 300, height: 30))
        textField.keyboardType = UIKeyboardType.default
        textField.returnKeyType = UIReturnKeyType.done
        textField.autocorrectionType = UITextAutocorrectionType.no
        textField.clearButtonMode = UITextField.ViewMode.whileEditing;
        textField.textAlignment = .left
        textField.placeholder = "Повторите пароль"
        textField.isSecureTextEntry = true
        return textField
    }()
    /// Кнопка для осуществления регистрации
    private let signUpButton = UIButton(type: .system)
    /// Идентификатор загрузки
    private let loader = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(named: "BackgroundMain")
        configView()
    }
    
    /// Проверка введенных логина и пароля на корректность
    private func loginAndPasswordCheck() throws {
        if let email = emailTextField.text {
            if email.isEmpty {
                throw RegisterErrors.emptyEmail
            }
            if !ErrorChecker.isEmailValid(email){
                throw LoginErrors.invalidEmail
            }
        } else {
            throw LoginErrors.invalidEmail
        }
        
        if let name = nameTextField.text {
            if name.isEmpty {
                throw RegisterErrors.emptyName
            }
        } else {
            throw RegisterErrors.emptyName
        }
        
        if let password = passwordTextField.text {
            if password.isEmpty {
                throw RegisterErrors.emptyPassword
            }
            if !password.elementsEqual(passwordRepeatTextField.text!) {
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
        loader.startAnimating()
        let name = nameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        AuthRequests.shared.register(info: RegisterInfo(email: email, password: password, fullName: name), completion: { (account, error) in
            if let error = error {
                self.loader.stopAnimating()
                let alert = ErrorChecker.handler.getAlertController(error: error)
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            if let account = account {
                User.currentUser = User()
                User.currentUser.account = account
                
                AuthRequests.shared.getJWTToken(info: JWTBullshit(email: email, password: password), completion: {(token, error) in
                    self.loader.stopAnimating()
                    if let error = error {
                        let alert = ErrorChecker.handler.getAlertController(error: error)
                        self.present(alert, animated: true, completion: nil)
                        return
                    }
                    if let token = token {
                        MeetingRequests.JWTToken = token
                        self.navigationController?.pushViewController(EmailCodeCheckVC(), animated: true)
                        //self.view.setRootViewController(NavigationHandler.createTabBar(), animated: true)
                    }
                })
            }
        })
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
    
    /// Формирование экрана регистрации 
    private func configView() {
        Styling.styleTextField(nameTextField)
        Styling.styleTextField(emailTextField)
        Styling.styleTextField(passwordTextField)
        Styling.styleTextField(passwordRepeatTextField)
        Styling.styleFilledButton(signUpButton)
        
        view.addSubview(nameTextField)
        nameTextField.delegate = self
        nameTextField.pinTop(to: view.safeAreaLayoutGuide.topAnchor, const: 150)
        nameTextField.setWidth(to: 300)
        nameTextField.pinCenter(to: view.safeAreaLayoutGuide.centerXAnchor, const: 0)
        
        view.addSubview(emailTextField)
        emailTextField.delegate = self
        emailTextField.pinTop(to: nameTextField.bottomAnchor, const: 20)
        emailTextField.setWidth(to: 300)
        emailTextField.pinCenter(to: view.safeAreaLayoutGuide.centerXAnchor, const: 0)
        
        view.addSubview(passwordTextField)
        passwordTextField.delegate = self
        passwordTextField.pinTop(to: emailTextField.bottomAnchor, const: 20)
        passwordTextField.setWidth(to: 300)
        passwordTextField.pinCenter(to: view.safeAreaLayoutGuide.centerXAnchor, const: 0)
        
        view.addSubview(passwordRepeatTextField)
        passwordRepeatTextField.delegate = self
        passwordRepeatTextField.pinTop(to: passwordTextField.bottomAnchor, const: 20)
        passwordRepeatTextField.setWidth(to: 300)
        passwordRepeatTextField.pinCenter(to: view.safeAreaLayoutGuide.centerXAnchor, const: 0)
        
        view.addSubview(loader)
        loader.pinTop(to: passwordRepeatTextField.bottomAnchor, const: 20)
        loader.pinCenter(to: view.safeAreaLayoutGuide.centerXAnchor, const: 0)
        loader.setWidth(to: 30)
        loader.setHeight(to: 30)
        
        view.addSubview(signUpButton)
        signUpButton.setWidth(to: 200)
        signUpButton.pinCenter(to: view.centerXAnchor, const: 0)
        signUpButton.pinTop(to: loader.bottomAnchor, const: 40)
        signUpButton.setTitle("Зарегистрироваться", for: .normal)
        //signUpButton.setTitleColor(.black, for: .normal)
        signUpButton.addTarget(self, action: #selector(signUp), for: .touchUpInside)
    }
}
