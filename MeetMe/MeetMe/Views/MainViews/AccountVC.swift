//
//  AccountVC.swift
//  MeetMe
//
//  Created by Stepan Ostapenko on 24.02.2022.
//

import UIKit

class AccountVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        let logoutButton = UIBarButtonItem(title: "Sign out", style: .done, target: self, action: #selector(signOut))
        self.navigationItem.rightBarButtonItem = logoutButton
    }
    
    @objc func signOut() {
        view.setRootViewController(NavigationHandler.createAuthNC(), animated: true)
    }


}
