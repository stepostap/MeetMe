//
//  SignUpVC.swift
//  MeetMe
//
//  Created by Stepan Ostapenko on 26.02.2022.
//

import UIKit

class SignUpVC: UIViewController, UITextFieldDelegate {

    let nameTextField : UITextField = {
        let textField = UITextField(frame: CGRect(x: 0, y: 0, width: 300, height: 30))
        textField.keyboardType = UIKeyboardType.default
        textField.returnKeyType = UIReturnKeyType.done
        textField.autocorrectionType = UITextAutocorrectionType.no
        textField.clearButtonMode = UITextField.ViewMode.whileEditing;
        textField.textAlignment = .left
        textField.placeholder = "Name"
        return textField
    }()
    
    let emailTextField : UITextField = {
        let textField = UITextField(frame: CGRect(x: 0, y: 0, width: 300, height: 30))
        textField.keyboardType = UIKeyboardType.default
        textField.returnKeyType = UIReturnKeyType.done
        textField.autocorrectionType = UITextAutocorrectionType.no
        textField.clearButtonMode = UITextField.ViewMode.whileEditing;
        textField.textAlignment = .left
        textField.placeholder = "Email"
        return textField
    }()
    
    let passwordTextField : UITextField = {
        let textField = UITextField(frame: CGRect(x: 0, y: 0, width: 300, height: 30))
        textField.keyboardType = UIKeyboardType.default
        textField.returnKeyType = UIReturnKeyType.done
        textField.autocorrectionType = UITextAutocorrectionType.no
        textField.clearButtonMode = UITextField.ViewMode.whileEditing;
        textField.textAlignment = .left
        textField.placeholder = "Password"
        textField.isSecureTextEntry = true
        return textField
    }()
    
    let passwordRepeatTextField : UITextField = {
        let textField = UITextField(frame: CGRect(x: 0, y: 0, width: 300, height: 30))
        textField.keyboardType = UIKeyboardType.default
        textField.returnKeyType = UIReturnKeyType.done
        textField.autocorrectionType = UITextAutocorrectionType.no
        textField.clearButtonMode = UITextField.ViewMode.whileEditing;
        textField.textAlignment = .left
        textField.placeholder = "Repeat password"
        textField.isSecureTextEntry = true
        return textField
    }()
    
    let signUpButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        configView()
        // Do any additional setup after loading the view.
    }
    
    private func configView() {
        Utilities.styleTextField(nameTextField)
        Utilities.styleTextField(emailTextField)
        Utilities.styleTextField(passwordTextField)
        Utilities.styleTextField(passwordRepeatTextField)
        Utilities.styleFilledButton(signUpButton)
        
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
        
        view.addSubview(signUpButton)
        signUpButton.setWidth(to: 200)
        signUpButton.pinCenter(to: view.centerXAnchor, const: 0)
        signUpButton.pinTop(to: passwordRepeatTextField.bottomAnchor, const: 40)
        signUpButton.setTitle("Sign Up", for: .normal)
        signUpButton.setTitleColor(.black, for: .normal)
        signUpButton.addTarget(self, action: #selector(signUp), for: .touchUpInside)
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
        
        if let name = nameTextField.text {
            if name.isEmpty {
                throw RegisterErrors.emptyName
            }
        } else {
            throw RegisterErrors.emptyName
        }
        
        if let password = passwordTextField.text {
            if password.isEmpty {
                throw LoginErrors.emptyPassword
            }
            if ErrorChecker.isPasswordValid(password){
                throw RegisterErrors.weakPassword
            }
            if !password.elementsEqual(passwordRepeatTextField.text!) {
                throw RegisterErrors.passwordsDontMatch
            }
        } else {
            throw LoginErrors.invalidPassword
        }
        
    }
    
    @objc func signUp() {
        
        do {
            try loginAndPasswordCheck()
            
        } catch let error {
            let alert = ErrorChecker.handler.getAlertController(error: error)
            present(alert, animated: true, completion: nil)
            return
        }
        
        
        
        let name = nameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        Networker.shared.registerUser(name: name, email: email, password: password, completion: { (user, error) in
            if let error = error {
                let alert = ErrorChecker.handler.getAlertController(error: error)
                self.present(alert, animated: true, completion: nil)
                
                return
            }
            
            if let user = user {
                User.currentUser = user
                self.view.setRootViewController(NavigationHandler.createTabBar(), animated: true)
            }
        })
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
}
