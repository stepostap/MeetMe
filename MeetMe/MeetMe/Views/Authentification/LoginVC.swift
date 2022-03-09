//
//  LoginVC.swift
//  MeetMe
//
//  Created by Stepan Ostapenko on 26.02.2022.
//

import UIKit

class LoginVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        
        let loginButton = UIButton()
        loginButton.setTitle("Login", for: .normal)
        view.addSubview(loginButton)
        loginButton.setConstraints(to: view, left: 20, top: 20, right: 20, height: 30)
        Utilities.styleFilledButton(loginButton)
        loginButton.addTarget(self, action: #selector(login), for: .touchUpInside)
        
        
        let signUpButton = UIButton()
        view.addSubview(signUpButton)
        signUpButton.setConstraints(to: view, left: 20, top: 60, right: 20, height: 30)
        Utilities.styleHollowButton(signUpButton)
        signUpButton.setTitle("Sign Up", for: .normal)
        signUpButton.setTitleColor(.black, for: .normal)
        signUpButton.addTarget(self, action: #selector(signUp), for: .touchUpInside)
    }

    @objc func login() {
        
        User.currentUser.account = getAccount()
        
        view.setRootViewController(NavigationHandler.createTabBar(), animated: true)
        
    }
    
    private func getAccount() -> Account {
        return Account(id: "", name: "Stepan Ostapenko", info: "I am a student from Moscow", imageData: nil)
        
    }
    
    @objc func signUp() {
        
        self.navigationController?.pushViewController(SignUpVC(), animated: true)
    }
}
