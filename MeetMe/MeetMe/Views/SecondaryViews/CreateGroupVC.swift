//
//  CreateGroupVC.swift
//  MeetMe
//
//  Created by Stepan Ostapenko on 22.03.2022.
//

import UIKit

class CreateGroupVC: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate & UINavigationControllerDelegate, UITextViewDelegate {
    
    var group: Meeting?
    var createButton: UIBarButtonItem?
    
    var interests = [Interests]()
    var friends = [Account]()
    
    let formatter = DateFormatter()
    let scrollView = UIScrollView()
    let mainView = UIView()
    
    let chooseImageButton = UIButton(type: .system)
    let editInterestsButton = UIButton(type: .system)
    let addFriendsButton = UIButton()
    
    let invitedFriendsLabel = UILabel()
    
    let privateSwitch = UISwitch()
    
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
    
    let infoTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 15)
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.systemGray.cgColor
        textView.layer.cornerRadius = 5
        textView.autocorrectionType = UITextAutocorrectionType.no
        return textView
    }()
    
    let interestsTextView : UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 15)
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.systemGray.cgColor
        textView.layer.cornerRadius = 5
        textView.autocorrectionType = UITextAutocorrectionType.no
        return textView
    }()
    
    let groupImage : UIImageView = {
        let image = UIImageView(frame: .zero)
        image.contentMode = .scaleAspectFit
        image.layer.borderWidth = 0
        return image
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        createButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(createGroup))
        navigationItem.rightBarButtonItem = createButton
        configView()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        showMeetingInfo()
    }
    
    private func showMeetingInfo() {
        formatter.dateFormat = "dd.MM HH:mm"
        if let meeting = group {
            nameTextField.text = meeting.name
        
            privateSwitch.isOn = meeting.isPrivate
            infoTextView.text = meeting.info
            interestsTextView.text = Utilities.getInterests(interestArray: meeting.types)
            print(formatter.string(from: meeting.startingDate))
            interests = meeting.types
        }
    }
    
    
    private func createGroupCheck() throws {
        
        if nameTextField.text!.isEmpty {
            throw CreateMeetingError.noName
        }
        
    }
    
    
    @objc func createGroup()  {
        do {
            try createGroupCheck()
        } catch let error {
            let alert = ErrorChecker.handler.getAlertController(error: error)
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        var friendIds = [User.currentUser.account!.id]
        for friend in friends {
            friendIds.append(friend.id)
        }
        var groupIds = [Int64]()
        
    }
    
    @objc func chooseImage() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let userPickedImage = info[.editedImage] as? UIImage else { return }
        groupImage.image = userPickedImage
        picker.dismiss(animated: true)
    }
    
    @objc func editInterests() {
        let vc = InterestsVC()
        vc.interests = interests
        vc.completion = {(interests) in
            
            self.interests = interests
            self.interestsTextView.text = Utilities.getInterests(interestArray: self.interests)
        }
        
        if let sheet = vc.sheetPresentationController {
            sheet.detents = [ .medium(), .large() ]
        }
        
        present(vc, animated: true)
    }
    
    
    @objc func addFriends() {
        
    }
    
    @objc func addGroups() {
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
    
    func configView() {
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
    
    
    func configNameAndImageView() {
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
        
        Utilities.styleTextField(nameTextField)
        mainView.addSubview(nameTextField)
        nameTextField.pinCenter(to: mainView.safeAreaLayoutGuide.centerXAnchor, const: 0)
        nameTextField.pinTop(to: groupImage.bottomAnchor, const: 10)
        nameTextField.setWidth(to: 300)
        nameTextField.setHeight(to: 30)
        nameTextField.placeholder = "Название группы"
        nameTextField.delegate = self
    }
    
    
    func configOnlinePrivateView() {
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
    
    
    func configInfoAndInterestsView() {
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
    
    func configParticipantsView() {
        
        Utilities.styleFilledButton(addFriendsButton)
        addFriendsButton.setTitle("Добавить участников", for: .normal)
        mainView.addSubview(addFriendsButton)
        addFriendsButton.pinTop(to: interestsTextView.bottomAnchor, const: 20)
        addFriendsButton.pinLeft(to: mainView.leadingAnchor, const: 20)
        addFriendsButton.setHeight(to: 40)
        addFriendsButton.pinRight(to: mainView.trailingAnchor, const: 20)
        addFriendsButton.addTarget(self, action: #selector(addFriends), for: .touchUpInside)
        
    }
}
