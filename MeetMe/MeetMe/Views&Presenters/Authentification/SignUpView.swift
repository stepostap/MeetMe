//
//  SignUpView.swift
//  MeetMe
//
//  Created by Stepan Ostapenko on 30.08.2022.
//

import UIKit

class SignUpView: UIView, UITextFieldDelegate {

    /// Текстовое поле для ввода имени пользователя
    let nameTextField : UITextField = {
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
    
    ///  Текстовое поле для повторения введенного пароля
    let passwordRepeatTextField : UITextField = {
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
    let signUpButton = UIButton(type: .system)
    /// Идентификатор загрузки
    let loader = UIActivityIndicatorView()
    
    init() {
        super.init(frame: .zero)
        self.backgroundColor = UIColor(named: "BackgroundMain")
        configView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        
        self.addSubview(nameTextField)
        nameTextField.delegate = self
        nameTextField.pinTop(to: self.safeAreaLayoutGuide.topAnchor, const: 150)
        nameTextField.setWidth(to: 300)
        nameTextField.pinCenter(to: self.safeAreaLayoutGuide.centerXAnchor, const: 0)
        
        self.addSubview(emailTextField)
        emailTextField.delegate = self
        emailTextField.pinTop(to: nameTextField.bottomAnchor, const: 20)
        emailTextField.setWidth(to: 300)
        emailTextField.pinCenter(to: self.safeAreaLayoutGuide.centerXAnchor, const: 0)
        
        self.addSubview(passwordTextField)
        passwordTextField.delegate = self
        passwordTextField.pinTop(to: emailTextField.bottomAnchor, const: 20)
        passwordTextField.setWidth(to: 300)
        passwordTextField.pinCenter(to: self.safeAreaLayoutGuide.centerXAnchor, const: 0)
        
        self.addSubview(passwordRepeatTextField)
        passwordRepeatTextField.delegate = self
        passwordRepeatTextField.pinTop(to: passwordTextField.bottomAnchor, const: 20)
        passwordRepeatTextField.setWidth(to: 300)
        passwordRepeatTextField.pinCenter(to: self.safeAreaLayoutGuide.centerXAnchor, const: 0)
        
        self.addSubview(loader)
        loader.pinTop(to: passwordRepeatTextField.bottomAnchor, const: 20)
        loader.pinCenter(to: self.safeAreaLayoutGuide.centerXAnchor, const: 0)
        loader.setWidth(to: 30)
        loader.setHeight(to: 30)
        
        self.addSubview(signUpButton)
        signUpButton.setWidth(to: 200)
        signUpButton.pinCenter(to: self.centerXAnchor, const: 0)
        signUpButton.pinTop(to: loader.bottomAnchor, const: 40)
        signUpButton.setTitle("Зарегистрироваться", for: .normal)

    }
}
