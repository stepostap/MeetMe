//
//  CreateGroupView.swift
//  MeetMe
//
//  Created by Stepan Ostapenko on 02.09.2022.
//

import UIKit

class CreateGroupView: UIView, UITextFieldDelegate {
    
    
    /// Прокручиваемая область, содержащая UI элементы
    private let scrollView = UIScrollView()
    /// Область с UI элементами
    private let mainView = UIView()
    /// Кнопка выбора изображения группы
    let chooseImageButton = UIButton(type: .system)
    /// Кнопка редактирования интересов группы
    let editInterestsButton = UIButton(type: .system)
    /// Кнопка для открытия ChooseParticipantsVC для добавления друзей в группу
    let addFriendsButton = UIButton()
    /// Переключатель, отображающий приватная или публичная данная группа
    let privateSwitch = UISwitch()
    /// Текстовое поле с названием группы
    let nameTextField : UITextField = {
        let textField = UITextField(frame: CGRect(x: 0, y: 0, width: 300, height: 30))
        textField.keyboardType = UIKeyboardType.default
        textField.returnKeyType = UIReturnKeyType.done
        textField.autocorrectionType = UITextAutocorrectionType.no
        textField.clearButtonMode = UITextField.ViewMode.whileEditing;
        textField.textAlignment = .center
        textField.font = UIFont.boldSystemFont(ofSize: 18)
        return textField
    }()
    /// Текстовое поле и информацией о группе
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
    /// Текстовое поле и интересами группы
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
    /// UI элемент, отображающий изображение группы
    let groupImage : UIImageView = {
        let image = UIImageView(frame: .zero)
        image.contentMode = .scaleAspectFit
        image.layer.borderWidth = 0
        Styling.styleImageView1(image)
        return image
    }()
        
    init() {
        super.init(frame: .zero)
        self.backgroundColor = UIColor(named: "BackgroundMain")
        configView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
    
    // MARK: Configs
    /// Формирование экрана с полями для ввода/редактирование инорфмации о группе
    private func configView() {
        addSubview(scrollView)
        scrollView.addSubview(mainView)
        
        scrollView.isScrollEnabled = true
        scrollView.isUserInteractionEnabled = true
        scrollView.isPagingEnabled = false
        
        scrollView.pinCenter(to: self.safeAreaLayoutGuide.centerXAnchor, const: 0)
        scrollView.pinWidth(to: self.widthAnchor, mult: 1)
        scrollView.pinTop(to: self.topAnchor, const: 0)
        scrollView.pinBottom(to: self.bottomAnchor, const: 0)
        mainView.pin(to: scrollView)
        mainView.pinWidth(to: self.widthAnchor, mult: 1)
        //mainView.pinHeight(to: view.heightAnchor, mult: 1)
        mainView.setHeight(to: 650)
        
        configNameAndImageView()
        configOnlinePrivateView()
        configInfoAndInterestsView()
        configParticipantsView()
    }
    
    /// Формирование раздела экрана с названием и картикной группы
    private func configNameAndImageView() {
        chooseImageButton.setTitle("Выбрать изображение", for: .normal)
        // 
        mainView.addSubview(chooseImageButton)
        chooseImageButton.pinTop(to: mainView.safeAreaLayoutGuide.topAnchor, const: 0)
        chooseImageButton.pinCenter(to: mainView.safeAreaLayoutGuide.centerXAnchor, const: 0)
        chooseImageButton.setWidth(to: 200)
        
        mainView.addSubview(groupImage)
        groupImage.pinTop(to: chooseImageButton.bottomAnchor, const: 0)
        groupImage.pinCenter(to: mainView.safeAreaLayoutGuide.centerXAnchor, const: 0)
        groupImage.pinWidth(to: mainView.safeAreaLayoutGuide.widthAnchor, mult: 0.5)
        groupImage.pinHeight(to: mainView.safeAreaLayoutGuide.widthAnchor, mult: 0.5)
        groupImage.image = UIImage(named: "placeholder")
        
        Styling.styleTextField(nameTextField)
        mainView.addSubview(nameTextField)
        nameTextField.pinCenter(to: mainView.safeAreaLayoutGuide.centerXAnchor, const: 0)
        nameTextField.pinTop(to: groupImage.bottomAnchor, const: 10)
        nameTextField.setWidth(to: 300)
        nameTextField.setHeight(to: 30)
        nameTextField.placeholder = "Название группы"
        nameTextField.delegate = self
    }
    
    /// Формирование раздела экрана с переключателем приватная/публичная группа
    private func configOnlinePrivateView() {
        let privateLabel = UILabel()
        privateLabel.text = "Приватная группа"
        mainView.addSubview(privateLabel)
        privateLabel.pinTop(to: nameTextField.bottomAnchor, const: 20)
        privateLabel.pinLeft(to: mainView.leadingAnchor, const: 30)
        privateLabel.setHeight(to: 30)
        privateLabel.setWidth(to: 180)
        
        mainView.addSubview(privateSwitch)
        privateSwitch.pinCenter(to: privateLabel.centerYAnchor, const: 0)
        privateSwitch.pinRight(to: mainView.trailingAnchor, const: 30)
    }
    
    /// Формирование раздела экрана со списком интересов
    private func configInfoAndInterestsView() {
        let infoLabel = UILabel()
        infoLabel.font = UIFont.boldSystemFont(ofSize: 15)
        infoLabel.textColor = .systemGray
        infoLabel.text = "Описание группы"
        mainView.addSubview(infoLabel)
        infoLabel.pinTop(to: privateSwitch.bottomAnchor, const: 10)
        infoLabel.pinLeft(to: mainView.safeAreaLayoutGuide.leadingAnchor, const: 30)
        infoLabel.setWidth(to: 150)
        infoLabel.setHeight(to: 30)
        
        mainView.addSubview(infoTextView)
        infoTextView.pinTop(to: infoLabel.bottomAnchor, const: 0)
        infoTextView.pinLeft(to: mainView.safeAreaLayoutGuide.leadingAnchor, const: 20)
        infoTextView.pinRight(to: mainView.safeAreaLayoutGuide.trailingAnchor, const: 20)
        infoTextView.setHeight(to: 80)
        
        let interestsLabel = UILabel()
        interestsLabel.font = UIFont.boldSystemFont(ofSize: 15)
        interestsLabel.textColor = .systemGray
        interestsLabel.text = "Теги группы"
        mainView.addSubview(interestsLabel)
        interestsLabel.pinTop(to: infoTextView.bottomAnchor, const: 10)
        interestsLabel.pinLeft(to: mainView.safeAreaLayoutGuide.leadingAnchor, const: 30)
        interestsLabel.setWidth(to: 180)
        interestsLabel.setHeight(to: 30)
        
        mainView.addSubview(editInterestsButton)
        editInterestsButton.setTitle("Изменить", for: .normal)
        // editInterestsButton.addTarget(self, action: #selector(editInterests), for: .touchUpInside)
        editInterestsButton.pinTop(to: infoTextView.bottomAnchor, const: 10)
        editInterestsButton.pinRight(to: mainView.safeAreaLayoutGuide.trailingAnchor, const: 20)
        editInterestsButton.setWidth(to: 120)
        editInterestsButton.setHeight(to: 30)
        
        mainView.addSubview(interestsTextView)
        interestsTextView.pinTop(to: interestsLabel.bottomAnchor, const: 0)
        interestsTextView.pinLeft(to: mainView.safeAreaLayoutGuide.leadingAnchor, const: 20)
        interestsTextView.pinRight(to: mainView.safeAreaLayoutGuide.trailingAnchor, const: 20)
        interestsTextView.setHeight(to: 80)
        interestsTextView.isUserInteractionEnabled = false
        
        chooseImageButton.setTitle("Выбрать изображение", for: .normal)
        // 
        mainView.addSubview(chooseImageButton)
        chooseImageButton.pinTop(to: mainView.safeAreaLayoutGuide.topAnchor, const: 0)
        chooseImageButton.pinCenter(to: mainView.safeAreaLayoutGuide.centerXAnchor, const: 0)
        chooseImageButton.setWidth(to: 200)
    }
    
    /// Формирование раздела экрана с кнопкой для просмотра и добавления участников группы
    private func configParticipantsView() {
        Styling.styleFilledButton(addFriendsButton)
        addFriendsButton.setTitle("Добавить участников", for: .normal)
        mainView.addSubview(addFriendsButton)
        addFriendsButton.pinTop(to: interestsTextView.bottomAnchor, const: 20)
        addFriendsButton.pinLeft(to: mainView.leadingAnchor, const: 20)
        addFriendsButton.setHeight(to: 40)
        addFriendsButton.pinRight(to: mainView.trailingAnchor, const: 20)
        //
    }
}
