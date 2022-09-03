//
//  SignUpVC.swift
//  MeetMe
//
//  Created by Stepan Ostapenko on 26.02.2022.
//

import UIKit

/// Коонтроллер для ввода кода, полученного пользователем по электронной почте
class EmailCodeCheckVC: UIViewController, UITextFieldDelegate {
    /// Текекстовое поле для ввода имени пользователя
    private let codeTextField : UITextField = {
        let textField = UITextField(frame: CGRect(x: 0, y: 0, width: 300, height: 30))
        textField.keyboardType = UIKeyboardType.default
        textField.returnKeyType = UIReturnKeyType.done
        textField.autocorrectionType = UITextAutocorrectionType.no
        textField.clearButtonMode = UITextField.ViewMode.whileEditing;
        textField.textAlignment = .left
        textField.placeholder = "Введите код"
        textField.keyboardType = UIKeyboardType.numberPad
        return textField
    }()
    /// Кнопка для входа
    private let signUpButton = UIButton()
    /// Кнопка для повторной отправки кода
    private let sendCodeAgainButton = UIButton(type: .system)
    /// Идентификатор загрузки
    private let loader = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(named: "BackgroundMain")
        configView()
        // Do any additional setup after loading the view.
    }
    
    /// Формирование экрана 
    private func configView() {
        Styling.styleTextField(codeTextField)
        Styling.styleFilledButton(signUpButton)
        
        view.addSubview(codeTextField)
        codeTextField.delegate = self
        codeTextField.pinTop(to: view.safeAreaLayoutGuide.topAnchor, const: 150)
        codeTextField.setWidth(to: 300)
        codeTextField.pinCenter(to: view.safeAreaLayoutGuide.centerXAnchor, const: 0)
        
        view.addSubview(sendCodeAgainButton)
        sendCodeAgainButton.setTitle("Отправить код повторно", for: .normal)
        sendCodeAgainButton.setTitleColor(.systemBlue, for: .normal)
        sendCodeAgainButton.pinTop(to: codeTextField.bottomAnchor, const: 5)
        sendCodeAgainButton.setWidth(to: 300)
        sendCodeAgainButton.pinLeft(to: codeTextField.leadingAnchor, const: 5)
        sendCodeAgainButton.titleLabel?.textAlignment = .left
        sendCodeAgainButton.addTarget(self, action: #selector(repeatCode), for: .touchUpInside)
        
        view.addSubview(loader)
        loader.pinTop(to: sendCodeAgainButton.bottomAnchor, const: 20)
        loader.pinCenter(to: view.safeAreaLayoutGuide.centerXAnchor, const: 0)
        loader.setWidth(to: 30)
        loader.setHeight(to: 30)
        
        view.addSubview(signUpButton)
        signUpButton.setWidth(to: 200)
        signUpButton.pinCenter(to: view.centerXAnchor, const: 0)
        signUpButton.pinTop(to: loader.bottomAnchor, const: 30)
        signUpButton.setTitle("Привязать почту", for: .normal)
        signUpButton.setTitleColor(.black, for: .normal)
        signUpButton.addTarget(self, action: #selector(signUp), for: .touchUpInside)
    }
    
    @objc private func repeatCode() {
        AuthRequests.shared.requestAnotherVerificationCode(completion: {(error) in
            if let error = error {
                let alert = ErrorChecker.handler.getAlertController(error: error)
                self.present(alert, animated: true, completion: nil)
                return
            } else {
                print("code sent again")
            }
        })
    }
    
    /// Вход пользователя в приложение
    @objc private func signUp() {
        if let emailCode = codeTextField.text, !emailCode.isEmpty {
            AuthRequests.shared.sendVerificationCode(code: emailCode, completion: {(error) in
                if let error = error {
                    let alert = ErrorChecker.handler.getAlertController(error: error)
                    self.present(alert, animated: true, completion: nil)
                    return
                }
                self.view.setRootViewController(NavigationHandler.createTabBar(), animated: true)
            })
        } else {
            print("empty Code")
            return
        }
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
}
