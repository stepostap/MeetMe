//
//  AccountVC.swift
//  MeetMe
//
//  Created by Stepan Ostapenko on 24.02.2022.
//

import UIKit
import Kingfisher

/// Контроллер, отвечающий за отображение аккаунта
class AccountVC: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate & UINavigationControllerDelegate, UITextViewDelegate {
    /// Аккаунт
    var account: Account?
    /// Кнопка для выхода из аккаунта
    private var logoutButton: UIBarButtonItem?
    /// Кнопка для редактирования аккаунта
    private var editButton: UIBarButtonItem?
    private var accountView = AccountView()
    var isUserAccount = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(named: "BackgroundMain")

        logoutButton = UIBarButtonItem(title: "Выйти", style: .done, target: self, action: #selector(signOut))
        editButton = UIBarButtonItem(title: "Изменить", style: .done, target: self, action: #selector(editProfile))
        
        if isUserAccount {
            self.navigationItem.rightBarButtonItem = logoutButton
            self.navigationItem.leftBarButtonItem = editButton
        } else {
            FriendsReequests.shared.getFriends(completion: {(accounts, error) in
                if let error = error {
                    let alert = ErrorChecker.handler.getAlertController(error: error)
                    self.present(alert, animated: true, completion: nil)
                    return
                }
                
                if let accounts = accounts {
                    User.currentUser.friends = accounts
                    self.setAccountInfo()
                }
            })
        }
        
        configView()
    }
    
    private func configView() {
        accountView.friendsButton.addTarget(self, action: #selector(viewFriends), for: .touchUpInside)
        accountView.addAsFriendButton.addTarget(self, action: #selector(addAsFriend), for: .touchUpInside)
        view = accountView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if User.currentUser.friends != nil || isUserAccount {
            setAccountInfo()
        }
    }
    
    /// Вывод информации о пользователе
    func setAccountInfo() {
        accountView.accountViewHeight = accountView.imageAndNameHeight
        
        if let accountViewHeightConstraint = accountView.accountViewHeightConstraint {
            accountViewHeightConstraint.isActive = false
        }
        
        if isUserAccount {
            account = User.currentUser.account
        }
        
        accountView.accountStackView.removeFullyAllArrangedSubviews()
        accountView.accountStackView.addArrangedSubview(accountView.configImageAndNameView())
        accountView.nameTextField.text = account?.name
        
        if isUserAccount {
            accountView.accountStackView.addArrangedSubview(accountView.configFriendsButton())
            accountView.accountViewHeight += accountView.friendsButtonHeight
        } else if !User.currentUser.friends!.contains(account!) {
            accountView.accountStackView.addArrangedSubview(accountView.configAddAsFriendButton())
            accountView.accountViewHeight += accountView.friendsButtonHeight
        }
        
        if account!.info != "" {
            accountView.infoTextView.text = account?.info
            let height = accountView.infoTextView.sizeThatFits(accountView.infoTextView.bounds.size).height
            accountView.accountViewHeight += accountView.infoHeight + Int(height)
            accountView.accountStackView.addArrangedSubview(accountView.configInfoTextView())
        }
        
        if !account!.imageDataURL.isEmpty {
            let url = URL(string: account!.imageDataURL)
            accountView.accountImage.kf.setImage(with: url, options: [ .forceRefresh])
        }

        if account!.interests != [] {
            accountView.interestsTextView.text = Styling.getInterests(interestArray: account?.interests ?? [])
            accountView.accountViewHeight += accountView.interestsHeight
            accountView.accountStackView.addArrangedSubview(accountView.configIterestsTextView())
        }

        if !(account!.isLinksEmpty()) {
            let view = UIView()
            let linksLabel = UILabel()
            view.addSubview(linksLabel)
            view.setHeight(to: 30)
            linksLabel.font = UIFont.boldSystemFont(ofSize: 15)
            linksLabel.textColor = .systemGray
            linksLabel.text = "Ссылки на соц. сети"
            linksLabel.pinTop(to: view.topAnchor, const: 10)
            linksLabel.pinLeft(to: view.leadingAnchor, const: 25)
            linksLabel.setHeight(to: 30)

            accountView.accountStackView.addArrangedSubview(view)
            accountView.accountViewHeight += 30
            
            if let accountVkLink = account?.socialMediaLinks["vk"], !accountVkLink.isEmpty {
                accountView.vkLinkTextField.text = accountVkLink
                accountView.accountStackView.addArrangedSubview(accountView.configVKView())
                accountView.accountViewHeight += accountView.singleLinkHeight
            }
            
            if let accountTgLink = account?.socialMediaLinks["tg"], !accountTgLink.isEmpty {
                accountView.tgLinkTextField.text = accountTgLink
                accountView.accountStackView.addArrangedSubview(accountView.configTGView())
                accountView.accountViewHeight += accountView.singleLinkHeight
            }
            
            if let accountInstLink = account?.socialMediaLinks["inst"], !accountInstLink.isEmpty {
                accountView.instLinkTextField.text = accountInstLink
                accountView.accountStackView.addArrangedSubview(accountView.configINSTView())
                accountView.accountViewHeight += accountView.singleLinkHeight
            }
        }
        
        accountView.accountViewHeightConstraint = accountView.accountStackView.heightAnchor.constraint(equalToConstant: CGFloat(accountView.accountViewHeight))
        accountView.accountViewHeightConstraint?.isActive = true
    }
    
    /// Переход на экран просмотра друзей и заявок
    @objc private func viewFriends() {
        let vc = FriendsVC()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    /// Отправка аккаунту запроса на дружбу
    @objc private func addAsFriend() {
        FriendsReequests.shared.makeFriendRequest(recieverId: account!.id, completion: {(error) in
            if let error = error {
                let alert = ErrorChecker.handler.getAlertController(error: error)
                self.present(alert, animated: true, completion: nil)
                return
            }
            self.accountView.addAsFriendButton.isEnabled = false
        })
    }
    
    /// Выход из аккаунта
    @objc private func signOut() {
        UserDefaults.standard.removeObject(forKey: "userEmail")
        UserDefaults.standard.removeObject(forKey: "userPassword")
        MeetMeRequests.JWTToken = ""
        User.currentUser = User()
        view.setRootViewController(NavigationHandler.createAuthNC(), animated: true)
    }

    /// Открытие контроллера, отвечающего за редактирование профиля
    @objc private func editProfile() {
        let editVC = EditAccountVC()
        navigationController?.pushViewController(editVC, animated: true)
    }
}
