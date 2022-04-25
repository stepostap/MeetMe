//
//  CreateGroupVC.swift
//  MeetMe
//
//  Created by Stepan Ostapenko on 22.03.2022.
//

import UIKit
import Kingfisher

/// Контроллер, отвечающий за создание и редактирование группы
class CreateGroupVC: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate & UINavigationControllerDelegate, UITextViewDelegate {
    /// Группа, информацию о которой пользователь редактирует
    var group: Group?
    /// Кнопка сохранения изменений или создания новой группы
    private var createButton: UIBarButtonItem?
    /// Метод, который вызывается при заверешении редактирования группы для передачи новых данных о ней в GroupScreen
    var completion: ((Group) -> (Void))?
    /// Список интересов
    private var interests = [Interests]()
    /// Список идентификаторов приглашенных в группу друзей
    private var invitedFriendsIDs = [Int64]()
    ///  Выбранное изображение группы
    private var chosenImage: UIImage?
    /// Форматер даты
    private let formatter = DateFormatter()
    /// Прокручиваемая область, содержащая UI элементы
    private let scrollView = UIScrollView()
    /// Область с UI элементами
    private let mainView = UIView()
    /// Кнопка выбора изображения группы
    private let chooseImageButton = UIButton(type: .system)
    /// Кнопка редактирования интересов группы
    private let editInterestsButton = UIButton(type: .system)
    /// Кнопка для открытия ChooseParticipantsVC для добавления друзей в группу
    private let addFriendsButton = UIButton()
    /// Переключатель, отображающий приватная или публичная данная группа
    private let privateSwitch = UISwitch()
    /// Текстовое поле с названием группы
    private let nameTextField : UITextField = {
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
    private let infoTextView: UITextView = {
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
    private let interestsTextView : UITextView = {
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
    private let groupImage : UIImageView = {
        let image = UIImageView(frame: .zero)
        image.contentMode = .scaleAspectFit
        image.layer.borderWidth = 0
        Styling.styleImageView1(image)
        return image
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "BackgroundMain")
        createButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(createGroup))
        navigationItem.rightBarButtonItem = createButton
        configView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        showGroupInfo()
    }
    
    /// Отображение информации о группе (при редактировании)
    private func showGroupInfo() {
        formatter.dateFormat = "dd.MM HH:mm"
        if let group = group {
            nameTextField.text = group.groupName
        
            privateSwitch.isOn = group.isPrivate
            infoTextView.text = group.groupInfo
            interestsTextView.text = Styling.getInterests(interestArray: group.interests)
            interests = group.interests
            if group.groupImageURL.isEmpty {
                groupImage.image = UIImage(named: "placeholder")
            } else {
                groupImage.kf.setImage(with: URL(string: group.groupImageURL), options: [.forceRefresh])
            }
            
        }
    }
    
    /// Проверка введенных пользователем данных
    private func createGroupCheck() throws {
        if nameTextField.text!.isEmpty {
            throw CreateMeetingError.noName
        }
    }
    
    /// Создание новой группы или сохранение данных отредактироыванной группы
    @objc private func createGroup()  {
        do {
            try createGroupCheck()
        } catch let error {
            let alert = ErrorChecker.handler.getAlertController(error: error)
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        if let group = group {
            let dto = GroupEditDTO(name: nameTextField.text ?? group.groupName, description: infoTextView.text, isPrivate: privateSwitch.isOn, interests: InterestsParser.getInterestsString(interests: interests))
            GroupRequests.shared.editGroup(groupID: group.id, image: chosenImage, newInfo: dto, completion: {(group, error) in
                if let error = error {
                    let alert = ErrorChecker.handler.getAlertController(error: error)
                    self.present(alert, animated: true, completion: nil)
                    return
                }
                if let group = group {
                    let index = User.currentUser.groups?.firstIndex(of: group)
                    User.currentUser.groups![index!] = group
                    self.completion?(group)
                    self.navigationController?.popViewController(animated: true)
                }
            })
        } else {
            let createdGroup = Group(id: 0, groupImage: "", groupName: nameTextField.text!, groupInfo: infoTextView.text, interests: interests, meetings: [], participants: [], admins: [User.currentUser.account!.id])
            GroupRequests.shared.createGroup(image: chosenImage, group: createdGroup, completion: {(group, error) in
                if let error = error {
                    let alert = ErrorChecker.handler.getAlertController(error: error)
                    self.present(alert, animated: true, completion: nil)
                    return
                }
                if let group = group {
                    User.currentUser.groups!.append(group)
                    GroupRequests.shared.addNewGroupParticipants(participants: self.invitedFriendsIDs, groupID: group.id, completion: {(error) in
                        if let error = error {
                            let alert = ErrorChecker.handler.getAlertController(error: error)
                            self.present(alert, animated: true, completion: nil)
                            return
                        }
                    })
                    self.navigationController?.popViewController(animated: true)
                }
            })
        }
    }
    
    /// Выбор изображения группы
    @objc private func chooseImage() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
    }
    
    ///  Редактирование выбранных интересов группы
    @objc private func editInterests() {
        let vc = InterestsVC()
        vc.interests = interests
        vc.completion = {(interests) in
            
            self.interests = interests
            self.interestsTextView.text = Styling.getInterests(interestArray: self.interests)
        }
        
        if let sheet = vc.sheetPresentationController {
            sheet.detents = [ .medium(), .large() ]
        }
        
        present(vc, animated: true)
    }
    
    /// Выбор идентификторов друзей, которые будут добавлены в группу при ее создании или заверешении редактирования
    @objc private func addFriends() {
        let vc = ChooseParticipantsVC()
        vc.passData = {(friends, groups) in
            self.invitedFriendsIDs = friends
        }
        vc.chosenFriendIDs = invitedFriendsIDs
        if let group = group, group.participants != nil {
            vc.alreadyAddedFriends = group.participants!
        }
        
        navigationController?.pushViewController(vc, animated: true)
    }
    

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let userPickedImage = info[.editedImage] as? UIImage else { return }
        groupImage.image = userPickedImage
        chosenImage = userPickedImage
        picker.dismiss(animated: true)
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
    
    // MARK: Configs
    /// Формирование экрана с полями для ввода/редактирование инорфмации о группе
    private func configView() {
        view.addSubview(scrollView)
        scrollView.addSubview(mainView)
        
        scrollView.isScrollEnabled = true
        scrollView.isUserInteractionEnabled = true
        scrollView.isPagingEnabled = false
        
        scrollView.pinCenter(to: view.safeAreaLayoutGuide.centerXAnchor, const: 0)
        scrollView.pinWidth(to: view.widthAnchor, mult: 1)
        scrollView.pinTop(to: view.topAnchor, const: 0)
        scrollView.pinBottom(to: view.bottomAnchor, const: 0)
        mainView.pin(to: scrollView)
        mainView.pinWidth(to: view.widthAnchor, mult: 1)
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
        chooseImageButton.addTarget(self, action: #selector(chooseImage), for: .touchUpInside)
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
        infoTextView.delegate = self
        
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
        editInterestsButton.addTarget(self, action: #selector(editInterests), for: .touchUpInside)
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
        chooseImageButton.addTarget(self, action: #selector(chooseImage), for: .touchUpInside)
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
        addFriendsButton.addTarget(self, action: #selector(addFriends), for: .touchUpInside)
        
    }
}
