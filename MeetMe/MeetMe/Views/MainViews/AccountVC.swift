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
    /// Прогручиваемая облать, которая содержит всю информацию о пользователе
    private let scrollView = UIScrollView()
    /// Область с информацией о пользователе
    private let accountView = UIStackView()
    /// Кнопка для перехода на экран списка друзей
    private let friendsButton = UIButton(type: .system)
    /// Кнопка для добавления аккаунта в список друзей
    private let addAsFriendButton = UIButton()
    ///  UI элемент,  отвечающий за отображение картнки аккунта
    private let accountImage : UIImageView = {
        let image = UIImageView(frame: .zero)
        image.contentMode = .scaleAspectFit
        image.layer.borderWidth = 0
        image.kf.indicatorType = .activity
        return image
    }()
    /// Текстовое поле с именем пользователя
    private let nameTextField : UITextField = {
        let textField = UITextField(frame: CGRect(x: 0, y: 0, width: 200, height: 30))
        textField.keyboardType = UIKeyboardType.default
        textField.returnKeyType = UIReturnKeyType.done
        textField.autocorrectionType = UITextAutocorrectionType.no
        textField.clearButtonMode = UITextField.ViewMode.whileEditing;
        textField.textAlignment = .center
        textField.font = UIFont.boldSystemFont(ofSize: 18)
        textField.isUserInteractionEnabled = false
        return textField
    }()
    /// Текстовое поле с информацией о пользователе
    private let infoTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 15)
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.systemGray.cgColor
        textView.layer.cornerRadius = 5
        textView.autocorrectionType = UITextAutocorrectionType.no
        textView.isUserInteractionEnabled = false
        textView.backgroundColor = UIColor(named: "BackgroundDarker")
        textView.isScrollEnabled = false
        return textView
    }()
    /// Текстовое поле с интересами пользователя
    private let interestsTextView : UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 15)
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.systemGray.cgColor
        textView.layer.cornerRadius = 5
        textView.autocorrectionType = UITextAutocorrectionType.no
        textView.backgroundColor = UIColor(named: "BackgroundDarker")
        textView.isUserInteractionEnabled = false
        return textView
    }()
    ///  Текстовое поле с именем аккаунта пользователя в ВК
    private let vkLinkTextField : UITextField = {
        let textField = UITextField(frame: CGRect(x: 0, y: 0, width: 200, height: 30))
        textField.keyboardType = UIKeyboardType.default
        textField.returnKeyType = UIReturnKeyType.done
        textField.autocorrectionType = UITextAutocorrectionType.no
        textField.clearButtonMode = UITextField.ViewMode.whileEditing;
        textField.textAlignment = .left
        textField.placeholder = "Аккаунт ВК"
        textField.isUserInteractionEnabled = false
        textField.textColor = .systemBlue
        return textField
    }()
    /// Текстовое поле с именем аккаунта пользователя в Телеграмм
    private let tgLinkTextField : UITextField = {
        let textField = UITextField(frame: CGRect(x: 0, y: 0, width: 200, height: 30))
        textField.keyboardType = UIKeyboardType.default
        textField.returnKeyType = UIReturnKeyType.done
        textField.autocorrectionType = UITextAutocorrectionType.no
        textField.clearButtonMode = UITextField.ViewMode.whileEditing;
        textField.textAlignment = .left
        textField.textColor = UIColor.systemBlue
        textField.placeholder = "Аккаунт в Телеграмме"
        textField.isEnabled = false
        textField.isUserInteractionEnabled = false
        return textField
    }()
    /// Текстовое поле с именем пользоателя в Инстаграм
    private let instLinkTextField : UITextField = {
        let textField = UITextField(frame: CGRect(x: 0, y: 0, width: 200, height: 30))
        textField.keyboardType = UIKeyboardType.default
        textField.returnKeyType = UIReturnKeyType.done
        textField.autocorrectionType = UITextAutocorrectionType.no
        textField.clearButtonMode = UITextField.ViewMode.whileEditing;
        textField.textAlignment = .left
        textField.textColor = UIColor.systemBlue
        textField.placeholder = "Аккаунт в Телеграмме"
        textField.isEnabled = false
        textField.isUserInteractionEnabled = false
        return textField
    }()
    /// Константа высоты области с именем и картинкой
    private let imageAndNameHeight = 280
    /// Константа высоты области с информацией об аккаунте
    private let infoHeight = 40
    /// Константа высоты области с интересами
    private let interestsHeight = 120
    /// Константа высоты области с ссылками
    private let linksHeight = 200
    /// Константа высоты области с кнопкой просмотра друзей
    private let friendsButtonHeight = 40
    /// Константа высоты области с ссылками на соц. сети пользователя
    private let singleLinkHeight = 55
    /// Константа высоты области со всеми данными об аккаунте
    private var accountViewHeight = 0
    /// Констреинт высоты области со всеми данными об аккаунте
    private var accountViewHeightConstraint: NSLayoutConstraint?
    /// Отображается аккаунт пользователя или другой аккаунт
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
    
    override func viewWillAppear(_ animated: Bool) {
        if User.currentUser.friends != nil || isUserAccount {
            setAccountInfo()
        }
    }
    
    /// Переход на экран просмотра друзей и заявок
    @objc private func viewFriends() {
        let vc = FriendsVC()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    /// Вывод информации о пользователе
    private func setAccountInfo() {
        accountViewHeight = imageAndNameHeight
        
        if let accountViewHeightConstraint = accountViewHeightConstraint {
            accountViewHeightConstraint.isActive = false
        }
        
        if isUserAccount {
            account = User.currentUser.account
        }
        
        accountView.removeFullyAllArrangedSubviews()
        accountView.addArrangedSubview(configImageAndNameView())
        nameTextField.text = account?.name
        
        if isUserAccount {
            accountView.addArrangedSubview(configFriendsButton())
            accountViewHeight += friendsButtonHeight
        } else if !User.currentUser.friends!.contains(account!) {
            accountView.addArrangedSubview(configAddAsFriendButton())
            accountViewHeight += friendsButtonHeight
        }
        
        if account!.info != "" {
            infoTextView.text = account?.info
            let height = infoTextView.sizeThatFits(infoTextView.bounds.size).height
            accountViewHeight += infoHeight + Int(height)
            accountView.addArrangedSubview(configInfoTextView())
        }
        
        if !account!.imageDataURL.isEmpty {
            let url = URL(string: account!.imageDataURL)
            accountImage.kf.setImage(with: url, options: [ .forceRefresh])
            
        }

        if account!.interests != [] {
            interestsTextView.text = Styling.getInterests(interestArray: account?.interests ?? [])
            accountViewHeight += interestsHeight
            accountView.addArrangedSubview(configIterestsTextView())
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

            accountView.addArrangedSubview(view)
            accountViewHeight += 30
            
            if let accountVkLink = account?.socialMediaLinks["vk"], !accountVkLink.isEmpty {
                vkLinkTextField.text = accountVkLink
                accountView.addArrangedSubview(configVKView())
                accountViewHeight += singleLinkHeight
            }
            
            if let accountTgLink = account?.socialMediaLinks["tg"], !accountTgLink.isEmpty {
                tgLinkTextField.text = accountTgLink
                accountView.addArrangedSubview(configTGView())
                accountViewHeight += singleLinkHeight
            }
            
            if let accountInstLink = account?.socialMediaLinks["inst"], !accountInstLink.isEmpty {
                instLinkTextField.text = accountInstLink
                accountView.addArrangedSubview(configINSTView())
                accountViewHeight += singleLinkHeight
            }
        }
        
        accountViewHeightConstraint = accountView.heightAnchor.constraint(equalToConstant: CGFloat(accountViewHeight))
        accountViewHeightConstraint?.isActive = true
    }
    
    /// Отправка аккаунту запроса на дружбу
    @objc private func addAsFriend() {
        FriendsReequests.shared.makeFriendRequest(recieverId: account!.id, completion: {(error) in
            if let error = error {
                let alert = ErrorChecker.handler.getAlertController(error: error)
                self.present(alert, animated: true, completion: nil)
                return
            }
            self.addAsFriendButton.isEnabled = false
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
    
    /// Переход на страничку аккаунта в ВК
    @objc private func viewVkLink(recognizer: UITapGestureRecognizer) {
        if recognizer.state == UITapGestureRecognizer.State.ended {
            if let vkLink = account?.socialMediaLinks["vk"] {
                if let url = URL(string: "https://vk.com/\(vkLink)") {
                    UIApplication.shared.open(url)
                }
            }
        }
    }
    
    /// Переход на страничку аккаунта в Телеграмм
    @objc private func viewTGLink(recognizer: UITapGestureRecognizer) {
        if recognizer.state == UITapGestureRecognizer.State.ended {
            if let tgLink = account?.socialMediaLinks["tg"] {
                if let url = URL(string: "https://t.me/\(tgLink)") {
                    UIApplication.shared.open(url)
                }
            }
        }
    }
    
    /// Переход на страничку аккаунта в Инстаграме
    @objc private func viewINSTLink(recognizer: UITapGestureRecognizer) {
        if recognizer.state == UITapGestureRecognizer.State.ended {
            if let instLink = account?.socialMediaLinks["inst"] {
                if let url = URL(string: "https://www.instagram.com/\(instLink)") {
                    UIApplication.shared.open(url)
                }
            }
        }
    }
    
    /// Выбор изображения пользователя
    @objc private func chooseImage() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
    }
    
    // MARK: Configs
    /// Формирование экрана профиля
    private func configView() {
        view.addSubview(scrollView)
        scrollView.addSubview(accountView)
        
        scrollView.isScrollEnabled = true
        scrollView.isUserInteractionEnabled = true
        scrollView.isPagingEnabled = false
        
        scrollView.pinCenter(to: view.safeAreaLayoutGuide.centerXAnchor, const: 0)
        scrollView.pinWidth(to: view.widthAnchor, mult: 1)
        scrollView.pinTop(to: view.topAnchor, const: 0)
        scrollView.pinBottom(to: view.bottomAnchor, const: 0)
        accountView.pin(to: scrollView)
        accountView.pinWidth(to: view.widthAnchor, mult: 1)
        
        accountView.spacing = 0
        accountView.axis  = NSLayoutConstraint.Axis.vertical
        
    }
    
    /// Формирование части экрана с картинкой и именем аккаунта
    private func configImageAndNameView() -> UIView {
        let view = UIView()
        view.setHeight(to: imageAndNameHeight)
        Styling.styleImageView1(accountImage)
        view.addSubview(accountImage)
        accountImage.pinTop(to: view.safeAreaLayoutGuide.topAnchor, const: 10)
        accountImage.pinCenter(to: view.safeAreaLayoutGuide.centerXAnchor, const: 0)
        accountImage.setHeight(to: 220)
        accountImage.setWidth(to: 220)
        accountImage.image = UIImage(named: "placeholder")
        
        view.addSubview(nameTextField)
        Styling.styleTextField(nameTextField)
        nameTextField.pinCenter(to: accountImage.safeAreaLayoutGuide.centerXAnchor, const: 0)
        nameTextField.pinTop(to: accountImage.bottomAnchor, const: 10)
        //nameTextField.pinBottom(to: view.bottomAnchor, const: 10)
        nameTextField.setHeight(to: 30)
        nameTextField.setWidth(to: 200)
        nameTextField.delegate = self
        nameTextField.isUserInteractionEnabled = false
    
        return view
    }
    
    /// Формирование части экрана с кнопкой для просмотра друзей
    private func configFriendsButton() -> UIView {
        let view = UIView()
        view.setHeight(to: friendsButtonHeight)
        view.addSubview(friendsButton)
        friendsButton.setConstraints(to: view, left: 20, top: 0, right: 20, bottom: 0)
        Styling.styleButton(friendsButton)
        friendsButton.setTitle("Друзья", for: .normal)
        friendsButton.addTarget(self, action: #selector(viewFriends), for: .touchUpInside)
        
        return view
    }
    
    /// Формирование части экрана с кнопкой для отправки запроса в друзья
    private func configAddAsFriendButton() -> UIView {
        let view = UIView()
        view.setHeight(to: friendsButtonHeight)
        view.addSubview(addAsFriendButton)
        addAsFriendButton.setConstraints(to: view, left: 20, top: 0, right: 20, bottom: 0)
        addAsFriendButton.setTitle("Добавить в друзья", for: .normal)
        Styling.styleButton(addAsFriendButton)
        addAsFriendButton.addTarget(self, action: #selector(addAsFriend), for: .touchUpInside)
        
        return view
    }
    
    /// Формирование части экрана с информацией о пользователе
    private func configInfoTextView() -> UIView{
        let view = UIView()
        
        let infoLabel = UILabel()
        infoLabel.font = UIFont.boldSystemFont(ofSize: 15)
        infoLabel.textColor = .systemGray
        infoLabel.text = "О себе"
        view.addSubview(infoLabel)
        infoLabel.pinTop(to: view.topAnchor, const: 10)
        infoLabel.pinLeft(to: view.safeAreaLayoutGuide.leadingAnchor, const: 30)
        infoLabel.setWidth(to: 150)
        infoLabel.setHeight(to: 30)
        
        view.addSubview(infoTextView)
        infoTextView.pinTop(to: infoLabel.bottomAnchor, const: 0)
        infoTextView.pinLeft(to: view.safeAreaLayoutGuide.leadingAnchor, const: 20)
        infoTextView.pinRight(to: view.safeAreaLayoutGuide.trailingAnchor, const: 20)
        //infoTextView.setHeight(to: 80)
        infoTextView.delegate = self
        
        return view
    }
    
    /// Формирование части экрана с интересами пользователя
    private func configIterestsTextView() ->  UIView {
        let view = UIView()
        view.setHeight(to: interestsHeight)
        view.pinWidth(to: view.widthAnchor, mult: 1)
        
        let interestsLabel = UILabel()
        interestsLabel.font = UIFont.boldSystemFont(ofSize: 15)
        interestsLabel.textColor = .systemGray
        interestsLabel.text = "Интересы"
        view.addSubview(interestsLabel)
        interestsLabel.pinTop(to: view.topAnchor, const: 10)
        interestsLabel.pinLeft(to: view.safeAreaLayoutGuide.leadingAnchor, const: 30)
        interestsLabel.setWidth(to: 150)
        interestsLabel.setHeight(to: 30)
        
        view.addSubview(interestsTextView)
        interestsTextView.pinTop(to: interestsLabel.bottomAnchor, const: 0)
        interestsTextView.pinLeft(to: view.safeAreaLayoutGuide.leadingAnchor, const: 20)
        interestsTextView.pinRight(to: view.safeAreaLayoutGuide.trailingAnchor, const: 20)
        interestsTextView.setHeight(to: 80)
        
        return view
    }
    
    /// Формирование части экрана с ссылкой на аккаунт пользователя в ВК
    private func configVKView() -> UIView {
        let view = UIView()
        view.setHeight(to: singleLinkHeight)
        view.pinWidth(to: view.widthAnchor, mult: 1)
        
        let vkImage = UIImageView(image: UIImage(named: "vkLogo"))
        view.addSubview(vkImage)
        vkImage.contentMode = .scaleAspectFit
        vkImage.pinTop(to: view.topAnchor, const: 5)
        vkImage.pinLeft(to: view.safeAreaLayoutGuide.leadingAnchor, const: 20)
        vkImage.setWidth(to: 50)
        vkImage.setHeight(to: 50)
        vkImage.isUserInteractionEnabled = true
        let vkTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewVkLink))
        vkTapGestureRecognizer.numberOfTapsRequired = 1
        vkImage.addGestureRecognizer(vkTapGestureRecognizer)
        
        Styling.styleTextField(vkLinkTextField)
        view.addSubview(vkLinkTextField)
        vkLinkTextField.pinLeft(to: vkImage.trailingAnchor, const: 5)
        vkLinkTextField.pinCenter(to: vkImage.centerYAnchor, const: 0)
        vkLinkTextField.setWidth(to: 200)
        vkLinkTextField.setHeight(to: 30)
        vkLinkTextField.delegate = self
        
        return view
    }
    
    /// Формирование части экрана с ссылкой на аккаунт пользователя в Телелеграмм
    private func configTGView() -> UIView {
        let view = UIView()
        view.setHeight(to: singleLinkHeight)
        view.pinWidth(to: view.widthAnchor, mult: 1)
        
        let tgImage = UIImageView(image: UIImage(named: "tgLogo"))
        view.addSubview(tgImage)
        tgImage.contentMode = .scaleAspectFit
        tgImage.pinTop(to: view.topAnchor, const: 5)
        tgImage.pinLeft(to: view.safeAreaLayoutGuide.leadingAnchor, const: 20)
        tgImage.setWidth(to: 50)
        tgImage.setHeight(to: 50)
        tgImage.isUserInteractionEnabled = true
        let tgTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewTGLink))
        tgTapGestureRecognizer.numberOfTapsRequired = 1
        tgImage.addGestureRecognizer(tgTapGestureRecognizer)
        
        Styling.styleTextField(tgLinkTextField)
        view.addSubview(tgLinkTextField)
        tgLinkTextField.pinLeft(to: tgImage.trailingAnchor, const: 5)
        tgLinkTextField.pinCenter(to: tgImage.centerYAnchor, const: 0)
        tgLinkTextField.setWidth(to: 200)
        tgLinkTextField.setHeight(to: 30)
        tgLinkTextField.delegate = self
        
        return view
    }
    
    /// Формирование части экрана с ссылкой на аккаунт пользователя в Инстаграме
    private func configINSTView() -> UIView {
        let view = UIView()
        view.setHeight(to: singleLinkHeight)
        view.pinWidth(to: view.widthAnchor, mult: 1)
        
        let instImage = UIImageView(image: UIImage(named: "instLogo"))
        view.addSubview(instImage)
        instImage.contentMode = .scaleAspectFit
        instImage.pinTop(to: view.topAnchor, const: 5)
        instImage.pinLeft(to: view.safeAreaLayoutGuide.leadingAnchor, const: 20)
        instImage.setWidth(to: 50)
        instImage.setHeight(to: 50)
        instImage.isUserInteractionEnabled = true
        let tgTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewINSTLink))
        tgTapGestureRecognizer.numberOfTapsRequired = 1
        instImage.addGestureRecognizer(tgTapGestureRecognizer)
        
        Styling.styleTextField(instLinkTextField)
        view.addSubview(instLinkTextField)
        instLinkTextField.pinLeft(to: instImage.trailingAnchor, const: 5)
        instLinkTextField.pinCenter(to: instImage.centerYAnchor, const: 0)
        instLinkTextField.setWidth(to: 200)
        instLinkTextField.setHeight(to: 30)
        instLinkTextField.delegate = self
        
        return view
    }
    
   
    // MARK: Delegates
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        return textView.resignFirstResponder()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText = textView.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: text)
        return updatedText.count <= 175
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let userPickedImage = info[.editedImage] as? UIImage else { return }
        accountImage.image = userPickedImage
        picker.dismiss(animated: true)
    }
}
