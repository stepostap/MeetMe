//
//  AccountView.swift
//  MeetMe
//
//  Created by Stepan Ostapenko on 26.08.2022.
//

import UIKit

class AccountView: UIView {
    var account: Account?
    /// Кнопка для выхода из аккаунта
    var logoutButton: UIBarButtonItem?
    /// Кнопка для редактирования аккаунта
    var editButton: UIBarButtonItem?
    /// Прогручиваемая облать, которая содержит всю информацию о пользователе
    let scrollView = UIScrollView()
    /// Область с информацией о пользователе
    let accountStackView = UIStackView()
    /// Кнопка для перехода на экран списка друзей
    let friendsButton = UIButton(type: .system)
    /// Кнопка для добавления аккаунта в список друзей
    let addAsFriendButton = UIButton()
    ///  UI элемент,  отвечающий за отображение картнки аккунта
    let accountImage : UIImageView = {
        let image = UIImageView(frame: .zero)
        image.contentMode = .scaleAspectFit
        image.layer.borderWidth = 0
        image.kf.indicatorType = .activity
        return image
    }()
    /// Текстовое поле с именем пользователя
    let nameTextField : UITextField = {
        let textField = UITextField(frame: CGRect(x: 0, y: 0, width: 200, height: 30))
        textField.keyboardType = UIKeyboardType.default
        textField.returnKeyType = UIReturnKeyType.done
        textField.autocorrectionType = UITextAutocorrectionType.no
        textField.clearButtonMode = UITextField.ViewMode.whileEditing;
        textField.textAlignment = .center
        textField.font = UIFont.boldSystemFont(ofSize: 18)
        return textField
    }()
    /// Текстовое поле с информацией о пользователе
    let infoTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 15)
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.systemGray.cgColor
        textView.layer.cornerRadius = 5
        textView.autocorrectionType = UITextAutocorrectionType.no
        textView.backgroundColor = UIColor(named: "BackgroundDarker")
        textView.isScrollEnabled = false
        return textView
    }()
    /// Текстовое поле с интересами пользователя
    let interestsTextView : UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 15)
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.systemGray.cgColor
        textView.layer.cornerRadius = 5
        textView.autocorrectionType = UITextAutocorrectionType.no
        textView.backgroundColor = UIColor(named: "BackgroundDarker")
        return textView
    }()
    ///  Текстовое поле с именем аккаунта пользователя в ВК
    let vkLinkTextField : UITextField = {
        let textField = UITextField(frame: CGRect(x: 0, y: 0, width: 200, height: 30))
        textField.keyboardType = UIKeyboardType.default
        textField.returnKeyType = UIReturnKeyType.done
        textField.autocorrectionType = UITextAutocorrectionType.no
        textField.clearButtonMode = UITextField.ViewMode.whileEditing;
        textField.textAlignment = .left
        textField.placeholder = "Аккаунт ВК"
        textField.textColor = .systemBlue
        return textField
    }()
    /// Текстовое поле с именем аккаунта пользователя в Телеграмм
    let tgLinkTextField : UITextField = {
        let textField = UITextField(frame: CGRect(x: 0, y: 0, width: 200, height: 30))
        textField.keyboardType = UIKeyboardType.default
        textField.returnKeyType = UIReturnKeyType.done
        textField.autocorrectionType = UITextAutocorrectionType.no
        textField.clearButtonMode = UITextField.ViewMode.whileEditing;
        textField.textAlignment = .left
        textField.textColor = UIColor.systemBlue
        textField.placeholder = "Аккаунт в Телеграмме"
        textField.isEnabled = false
        return textField
    }()
    /// Текстовое поле с именем пользоателя в Инстаграм
    let instLinkTextField : UITextField = {
        let textField = UITextField(frame: CGRect(x: 0, y: 0, width: 200, height: 30))
        textField.keyboardType = UIKeyboardType.default
        textField.returnKeyType = UIReturnKeyType.done
        textField.autocorrectionType = UITextAutocorrectionType.no
        textField.clearButtonMode = UITextField.ViewMode.whileEditing;
        textField.textAlignment = .left
        textField.textColor = UIColor.systemBlue
        textField.placeholder = "Аккаунт в Телеграмме"
        textField.isEnabled = false
        return textField
    }()
    /// Константа высоты области с именем и картинкой
    let imageAndNameHeight = 280
    /// Константа высоты области с информацией об аккаунте
    let infoHeight = 40
    /// Константа высоты области с интересами
    let interestsHeight = 120
    /// Константа высоты области с ссылками
    let linksHeight = 200
    /// Константа высоты области с кнопкой просмотра друзей
    let friendsButtonHeight = 40
    /// Константа высоты области с ссылками на соц. сети пользователя
    let singleLinkHeight = 55
    /// Константа высоты области со всеми данными об аккаунте
    var accountViewHeight = 0
    /// Констреинт высоты области со всеми данными об аккаунте
    var accountViewHeightConstraint: NSLayoutConstraint?
    
    init() {
        super.init(frame: .zero)
        self.backgroundColor = UIColor(named: "BackgroundMain")
        configView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Configs
    /// Формирование экрана профиля
    func configView() {
        self.addSubview(scrollView)
        scrollView.addSubview(accountStackView)
        
        scrollView.isScrollEnabled = true
        scrollView.isUserInteractionEnabled = true
        scrollView.isPagingEnabled = false
        
        scrollView.pinCenter(to: self.safeAreaLayoutGuide.centerXAnchor, const: 0)
        scrollView.pinWidth(to: self.widthAnchor, mult: 1)
        scrollView.pinTop(to: self.topAnchor, const: 0)
        scrollView.pinBottom(to: self.bottomAnchor, const: 0)
        accountStackView.pin(to: scrollView)
        accountStackView.pinWidth(to: self.widthAnchor, mult: 1)
        
        accountStackView.spacing = 0
        accountStackView.axis  = NSLayoutConstraint.Axis.vertical
    }
    
    /// Формирование части экрана с картинкой и именем аккаунта
    func configImageAndNameView() -> UIView {
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
    func configFriendsButton() -> UIView {
        let view = UIView()
        view.setHeight(to: friendsButtonHeight)
        view.addSubview(friendsButton)
        friendsButton.setConstraints(to: view, left: 20, top: 0, right: 20, bottom: 0)
        Styling.styleButton(friendsButton)
        friendsButton.setTitle("Друзья", for: .normal)
    
        return view
    }
    
    /// Формирование части экрана с кнопкой для отправки запроса в друзья
    func configAddAsFriendButton() -> UIView {
        let view = UIView()
        view.setHeight(to: friendsButtonHeight)
        view.addSubview(addAsFriendButton)
        addAsFriendButton.setConstraints(to: view, left: 20, top: 0, right: 20, bottom: 0)
        addAsFriendButton.setTitle("Добавить в друзья", for: .normal)
        Styling.styleButton(addAsFriendButton)
        
        return view
    }
    
    /// Формирование части экрана с информацией о пользователе
    func configInfoTextView() -> UIView{
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
    func configIterestsTextView() ->  UIView {
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
    func configVKView() -> UIView {
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
    func configTGView() -> UIView {
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
    func configINSTView() -> UIView {
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
}

extension AccountView: UITextFieldDelegate, UITextViewDelegate {
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
}
