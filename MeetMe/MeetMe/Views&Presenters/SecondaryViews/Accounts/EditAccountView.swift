//
//  EditAccountView.swift
//  MeetMe
//
//  Created by Stepan Ostapenko on 02.09.2022.
//

import UIKit

class EditAccountView: UIView {
    /// Аккаунт пользователя
    var account = Account(account: User.currentUser.account!)
    ///  Кнопка выбора изображения (автара) пользователя
    let chooseImageButton = UIButton(type: .system)
    /// Кнопка выбора хэштегов (интересов) пользователя
    let editInterestsButton = UIButton(type: .system)
    /// Прокручиваемая область, на которой расположены UI элементы
    private let scrollView = UIScrollView()
    /// Область с UI элементами
    private let editView = UIView()
    /// Текстовое поле для ввода ссылки на аккаунт в ВК
    let vkLinkTextField : UITextField = {
        let textField = UITextField(frame: CGRect(x: 0, y: 0, width: 200, height: 30))
        textField.keyboardType = UIKeyboardType.default
        textField.returnKeyType = UIReturnKeyType.done
        textField.autocorrectionType = UITextAutocorrectionType.no
        textField.clearButtonMode = UITextField.ViewMode.whileEditing;
        textField.textAlignment = .left
        textField.textColor = UIColor.systemBlue
        textField.placeholder = "Аккаунт ВК"
        return textField
    }()
    /// Текстовое поле для ввода ссылки на аккаунт в Телеграмм
    let tgLinkTextField : UITextField = {
        let textField = UITextField(frame: CGRect(x: 0, y: 0, width: 200, height: 30))
        textField.keyboardType = UIKeyboardType.default
        textField.returnKeyType = UIReturnKeyType.done
        textField.autocorrectionType = UITextAutocorrectionType.no
        textField.clearButtonMode = UITextField.ViewMode.whileEditing;
        textField.textAlignment = .left
        textField.textColor = UIColor.systemBlue
        textField.placeholder = "Аккаунт в Телеграмме"
        return textField
    }()
    /// Текстовое поле для ввода ссылки на аккаунт в Instagram
    let instLinkTextField : UITextField = {
        let textField = UITextField(frame: CGRect(x: 0, y: 0, width: 200, height: 30))
        textField.keyboardType = UIKeyboardType.default
        textField.returnKeyType = UIReturnKeyType.done
        textField.autocorrectionType = UITextAutocorrectionType.no
        textField.clearButtonMode = UITextField.ViewMode.whileEditing;
        textField.textAlignment = .left
        textField.textColor = UIColor.systemBlue
        textField.placeholder = "Аккаунт в Instagram"
        return textField
    }()
    /// UI элемент, отображающий изображение пользователя
    let accountImage : UIImageView = {
        let image = UIImageView(frame: .zero)
        image.contentMode = .scaleAspectFit
        image.layer.borderWidth = 0
        Styling.styleImageView1(image)
        return image
    }()
    /// Текстовое поле, отображающее имя пользователя
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
    /// Тествоеое поле, отображающе информацию о пользователе
    let infoTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 15)
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.systemGray.cgColor
        textView.layer.cornerRadius = 5
        textView.autocorrectionType = UITextAutocorrectionType.no
        textView.backgroundColor = UIColor(named: "BackgroundDarker")
        return textView
    }()
    /// Текстовое поле, отображающее список интересов пользователя
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
    
    init() {
        super.init(frame: .zero)
        self.backgroundColor = UIColor(named: "BackgroundMain")
        configView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Configs
    private func configView() {
        
        self.addSubview(scrollView)
        scrollView.addSubview(editView)
        
        scrollView.isScrollEnabled = true
        scrollView.isUserInteractionEnabled = true
        scrollView.isPagingEnabled = false
        
        scrollView.pinCenter(to: self.safeAreaLayoutGuide.centerXAnchor, const: 0)
        scrollView.pinWidth(to: self.widthAnchor, mult: 1)
        scrollView.pinTop(to: self.topAnchor, const: 0)
        scrollView.pinBottom(to: self.bottomAnchor, const: 0)
        editView.pin(to: scrollView)
        editView.pinWidth(to: self.widthAnchor, mult: 1)
        editView.setHeight(to: 750)

        
        chooseImageButton.setTitle("Выбрать изображение", for: .normal)
        // 
        editView.addSubview(chooseImageButton)
        chooseImageButton.pinTop(to: editView.safeAreaLayoutGuide.topAnchor, const: 0)
        chooseImageButton.pinCenter(to: editView.safeAreaLayoutGuide.centerXAnchor, const: 0)
        chooseImageButton.setWidth(to: 200)
    
        editView.addSubview(accountImage)
        accountImage.pinTop(to: chooseImageButton.bottomAnchor, const: 0)
        accountImage.pinCenter(to: editView.safeAreaLayoutGuide.centerXAnchor, const: 0)
        accountImage.pinWidth(to: editView.safeAreaLayoutGuide.widthAnchor, mult: 0.5)
        accountImage.pinHeight(to: editView.safeAreaLayoutGuide.widthAnchor, mult: 0.5)
        if account.imageDataURL.isEmpty {
            accountImage.image = UIImage(named: "placeholder")
        } else {
            accountImage.kf.setImage(with: URL(string: account.imageDataURL))
        }
        
        
        Styling.styleTextField(nameTextField)
        editView.addSubview(nameTextField)
        nameTextField.pinCenter(to: editView.safeAreaLayoutGuide.centerXAnchor, const: 0)
        nameTextField.pinTop(to: accountImage.bottomAnchor, const: 10)
        nameTextField.setWidth(to: 200)
        nameTextField.text = account.name
        nameTextField.delegate = self
        
        let infoLabel = UILabel()
        infoLabel.font = UIFont.boldSystemFont(ofSize: 15)
        infoLabel.textColor = .systemGray
        infoLabel.text = "О себе"
        editView.addSubview(infoLabel)
        infoLabel.pinTop(to: nameTextField.bottomAnchor, const: 10)
        infoLabel.pinLeft(to: editView.safeAreaLayoutGuide.leadingAnchor, const: 30)
        infoLabel.setWidth(to: 150)
        infoLabel.setHeight(to: 30)
        
        editView.addSubview(infoTextView)
        infoTextView.pinTop(to: infoLabel.bottomAnchor, const: 0)
        infoTextView.pinLeft(to: editView.safeAreaLayoutGuide.leadingAnchor, const: 20)
        infoTextView.pinRight(to: editView.safeAreaLayoutGuide.trailingAnchor, const: 20)
        infoTextView.setHeight(to: 80)
        infoTextView.text = account.info
        infoTextView.delegate = self
        
        let interestsLabel = UILabel()
        interestsLabel.font = UIFont.boldSystemFont(ofSize: 15)
        interestsLabel.textColor = .systemGray
        interestsLabel.text = "Интересы"
        editView.addSubview(interestsLabel)
        interestsLabel.pinTop(to: infoTextView.bottomAnchor, const: 10)
        interestsLabel.pinLeft(to: editView.safeAreaLayoutGuide.leadingAnchor, const: 30)
        interestsLabel.setWidth(to: 150)
        interestsLabel.setHeight(to: 30)
        
        editView.addSubview(editInterestsButton)
        editInterestsButton.setTitle("Изменить", for: .normal)
        // editInterestsButton.addTarget(self, action: #selector(editInterests), for: .touchUpInside)
        editInterestsButton.pinTop(to: infoTextView.bottomAnchor, const: 10)
        editInterestsButton.pinRight(to: editView.safeAreaLayoutGuide.trailingAnchor, const: 20)
        editInterestsButton.setWidth(to: 120)
        editInterestsButton.setHeight(to: 30)
        
        editView.addSubview(interestsTextView)
        interestsTextView.pinTop(to: interestsLabel.bottomAnchor, const: 0)
        interestsTextView.pinLeft(to: editView.safeAreaLayoutGuide.leadingAnchor, const: 20)
        interestsTextView.pinRight(to: editView.safeAreaLayoutGuide.trailingAnchor, const: 20)
        interestsTextView.setHeight(to: 80)
        interestsTextView.text = account.getInterests()
        interestsTextView.isUserInteractionEnabled = false
        
        configLinkView()
        
    }
    
    private func configLinkView() {
        
        Styling.styleTextField(vkLinkTextField)
        Styling.styleTextField(tgLinkTextField)
        Styling.styleTextField(instLinkTextField)
        
        let linksLabel = UILabel()
        linksLabel.font = UIFont.boldSystemFont(ofSize: 15)
        linksLabel.textColor = .systemGray
        linksLabel.text = "Ссылки на соц. сети"
        editView.addSubview(linksLabel)
        linksLabel.pinTop(to: interestsTextView.bottomAnchor, const: 10)
        linksLabel.pinLeft(to: editView.leadingAnchor, const: 25)
        linksLabel.setHeight(to: 30)
        linksLabel.setWidth(to: 200)
       
        let vkImage = UIImageView(image: UIImage(named: "vkLogo"))
        editView.addSubview(vkImage)
        vkImage.contentMode = .scaleAspectFit
        vkImage.pinTop(to: linksLabel.bottomAnchor, const: 0)
        vkImage.pinLeft(to: editView.safeAreaLayoutGuide.leadingAnchor, const: 20)
        vkImage.setWidth(to: 50)
        vkImage.setHeight(to: 50)
        
        editView.addSubview(vkLinkTextField)
        vkLinkTextField.pinLeft(to: vkImage.trailingAnchor, const: 5)
        vkLinkTextField.pinCenter(to: vkImage.centerYAnchor, const: 0)
        vkLinkTextField.setWidth(to: 200)
        vkLinkTextField.setHeight(to: 30)
        if let link = account.socialMediaLinks["vk"] {
            vkLinkTextField.text = link
        }
        vkLinkTextField.delegate = self
        
        let tgImage = UIImageView(image: UIImage(named: "tgLogo"))
        editView.addSubview(tgImage)
        tgImage.contentMode = .scaleAspectFit
        tgImage.pinTop(to: vkImage.bottomAnchor, const: 10)
        tgImage.pinLeft(to: editView.safeAreaLayoutGuide.leadingAnchor, const: 20)
        tgImage.setWidth(to: 50)
        tgImage.setHeight(to: 50)
        
        editView.addSubview(tgLinkTextField)
        tgLinkTextField.pinLeft(to: tgImage.trailingAnchor, const: 5)
        tgLinkTextField.pinCenter(to: tgImage.centerYAnchor, const: 0)
        tgLinkTextField.setWidth(to: 200)
        tgLinkTextField.setHeight(to: 30)
        if let link = account.socialMediaLinks["tg"] {
            tgLinkTextField.text = link
        }
        tgLinkTextField.delegate = self
        
        let instImage = UIImageView(image: UIImage(named: "instLogo"))
        editView.addSubview(instImage)
        instImage.contentMode = .scaleAspectFit
        instImage.pinTop(to: tgImage.bottomAnchor, const: 10)
        instImage.pinLeft(to: editView.safeAreaLayoutGuide.leadingAnchor, const: 20)
        instImage.setWidth(to: 50)
        instImage.setHeight(to: 50)
        
        editView.addSubview(instLinkTextField)
        instLinkTextField.pinLeft(to: instImage.trailingAnchor, const: 5)
        instLinkTextField.pinCenter(to: instImage.centerYAnchor, const: 0)
        instLinkTextField.setWidth(to: 200)
        instLinkTextField.setHeight(to: 30)
        if let link = account.socialMediaLinks["inst"] {
            instLinkTextField.text = link
        }
        instLinkTextField.delegate = self
    }
}

// MARK: Text delegates
extension EditAccountView: UITextViewDelegate, UITextFieldDelegate {
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
