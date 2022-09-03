//
//  LoginView.swift
//  MeetMe
//
//  Created by Stepan Ostapenko on 30.08.2022.
//

import UIKit

class LoginView: UIView, UITextFieldDelegate {
    
    let loginButton = UIButton(type: .system)
    /// Кнопка для регистрации
    let signUpButton = UIButton(type: .system)
    /// Идентификатор загрузки
    let loader = UIActivityIndicatorView()
    /// Требуется ли сохранять на устройстве логин и пароль для повторного входа
    var shouldSaveLoginAndPassword: CheckBox?
    /// Текстовое поле для ввода электронной почты пользователя
    let emailTextField : UITextField = {
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
    let passwordTextField : UITextField = {
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
    
    init() {
        super.init(frame: .zero)
        self.backgroundColor = UIColor(named: "BackgroundMain")
        configView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Формирование экрана логина
    private func configView() {
        Styling.styleTextField(emailTextField)
        Styling.styleTextField(passwordTextField)
        Styling.styleFilledButton(loginButton)
        Styling.styleHollowButton(signUpButton)
        
        self.addSubview(emailTextField)
        emailTextField.pinCenter(to: self.safeAreaLayoutGuide.centerXAnchor, const: 0)
        emailTextField.setWidth(to: 300)
        emailTextField.pinTop(to: self.safeAreaLayoutGuide.topAnchor, const: 150)
        emailTextField.delegate = self
        
        self.addSubview(passwordTextField)
        passwordTextField.pinCenter(to: self.safeAreaLayoutGuide.centerXAnchor, const: 0)
        passwordTextField.setWidth(to: 300)
        passwordTextField.pinTop(to: emailTextField.bottomAnchor, const: 20)
        passwordTextField.delegate = self
        
        shouldSaveLoginAndPassword = CheckBox.init()
        shouldSaveLoginAndPassword?.borderStyle = .roundedSquare(radius: 5)
        self.addSubview(shouldSaveLoginAndPassword!)
        shouldSaveLoginAndPassword?.setWidth(to: 20)
        shouldSaveLoginAndPassword?.setHeight(to: 20)
        shouldSaveLoginAndPassword?.pinLeft(to: passwordTextField.leadingAnchor, const: 0)
        shouldSaveLoginAndPassword?.pinTop(to: passwordTextField.bottomAnchor, const: 25)
        
        let staySignedInLabel = UILabel()
        self.addSubview(staySignedInLabel)
        staySignedInLabel.text = "Запомнить логин и пароль"
        staySignedInLabel.pinTop(to: passwordTextField.bottomAnchor, const: 25)
        staySignedInLabel.pinLeft(to: shouldSaveLoginAndPassword!.trailingAnchor, const: 10)
        staySignedInLabel.setWidth(to: 250)
        staySignedInLabel.setHeight(to: 20)
        
        loader.hidesWhenStopped = true
        self.addSubview(loader)
        loader.pinTop(to: staySignedInLabel.bottomAnchor, const: 20)
        loader.pinCenter(to: self.safeAreaLayoutGuide.centerXAnchor, const: 0)
        loader.setWidth(to: 30)
        loader.setHeight(to: 30)
        
        loginButton.setTitle("Войти", for: .normal)
        self.addSubview(loginButton)
        loginButton.pinTop(to: loader.bottomAnchor, const: 30)
        loginButton.pinCenter(to: self.safeAreaLayoutGuide.centerXAnchor, const: 0)
        loginButton.setWidth(to: 200)
        loginButton.setHeight(to: 30)
        // loginButton.addTarget(self, action: #selector(login), for: .touchUpInside)
        
        self.addSubview(signUpButton)
        signUpButton.pinTop(to: loginButton.bottomAnchor, const: 10)
        signUpButton.pinCenter(to: self.safeAreaLayoutGuide.centerXAnchor, const: 0)
        signUpButton.setWidth(to: 200)
        signUpButton.setHeight(to: 30)
        signUpButton.setTitle("Зарегистрироваться", for: .normal)
        signUpButton.setTitleColor(.systemBlue, for: .normal)
        // signUpButton.addTarget(self, action: #selector(signUp), for: .touchUpInside)
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
}
