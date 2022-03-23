//
//  CreateMeetingVC.swift
//  MeetMe
//
//  Created by Stepan Ostapenko on 12.03.2022.
//

import UIKit

class CreateMeetingVC: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate & UINavigationControllerDelegate, UITextViewDelegate {
    
    var meeting: Meeting?
    var createButton: UIBarButtonItem?
    
    var interests = [Interests]()
    var friends = [Account]()
    var groups = [Group]()
    
    let formatter = DateFormatter()
    let scrollView = UIScrollView()
    let mainView = UIView()
    
    let chooseImageButton = UIButton(type: .system)
    let editInterestsButton = UIButton(type: .system)
    let addFriendsButton = UIButton()
    let addGroupsButton = UIButton()
    
    let invitedFriendsLabel = UILabel()
    let invitedGroupsLabel = UILabel()
    
    let onlineSwitch = UISwitch()
    let privateSwitch = UISwitch()
    
    let datePicker1 = UIDatePicker()
    let datePicker2 = UIDatePicker()
    let startingDateTextField : UITextField = {
        let textField = UITextField(frame: CGRect(x: 0, y: 0, width: 150, height: 30))
        textField.borderStyle = UITextField.BorderStyle.roundedRect
        textField.clearButtonMode = UITextField.ViewMode.whileEditing;
        return textField
    }()
    
    let endingDateTextField : UITextField = {
        let textField = UITextField(frame: CGRect(x: 0, y: 0, width: 150, height: 30))
        textField.borderStyle = UITextField.BorderStyle.roundedRect
        textField.clearButtonMode = UITextField.ViewMode.whileEditing;
        return textField
    }()
    
    let maxParticipantsTextField : UITextField = {
        let textField = UITextField(frame: CGRect(x: 0, y: 0, width: 60, height: 30))
        textField.textAlignment = .left
        textField.keyboardType = UIKeyboardType.numberPad
        return textField
    }()
    
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
    
    let meetingImage : UIImageView = {
        let image = UIImageView(frame: .zero)
        image.contentMode = .scaleAspectFit
        image.layer.borderWidth = 0
        return image
    }()
    
    let locationTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 15)
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.systemGray.cgColor
        textView.layer.cornerRadius = 5
        textView.autocorrectionType = UITextAutocorrectionType.no
        return textView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        createButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(createMeeting))
        navigationItem.rightBarButtonItem = createButton
        configView()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        showMeetingInfo()
    }
    
    private func showMeetingInfo() {
        formatter.dateFormat = "dd.MM HH:mm"
        if let meeting = meeting {
            nameTextField.text = meeting.name
            onlineSwitch.isOn = meeting.isOnline
            privateSwitch.isOn = meeting.isPrivate
            infoTextView.text = meeting.info
            interestsTextView.text = Utilities.getInterests(interestArray: meeting.types)
            print(formatter.string(from: meeting.startingDate))
            startingDateTextField.text = formatter.string(from: meeting.startingDate)
            if let endingDate = meeting.endingDate {
                endingDateTextField.text = formatter.string(from: endingDate)
            }
            interests = meeting.types
            maxParticipantsTextField.text = meeting.participantsMax.description
        }
    }
    
    
    private func createMeetingCheck() throws {
        
        if nameTextField.text!.isEmpty {
            throw CreateMeetingError.noName
        }
        if maxParticipantsTextField.text!.isEmpty {
            throw CreateMeetingError.noMaxUser
        }
        if privateSwitch.isOn && groups.isEmpty && friends.isEmpty {
            throw CreateMeetingError.noParticipants
        }
        if startingDateTextField.text!.isEmpty {
            throw CreateMeetingError.noStartingDate
        }
        if (!endingDateTextField.text!.isEmpty && datePicker1.date > datePicker2.date) || datePicker1.date < Date.now {
            throw CreateMeetingError.startEndDateError
        }
    }
    
    
    @objc func createMeeting()  {
        do {
            try createMeetingCheck()
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
        for group in groups {
            groupIds.append(group.id)
        }
        var endingDate: Date?
        if let text = endingDateTextField.text, !text.isEmpty {
            endingDate = datePicker2.date
        }
        
        if let _ = meeting {
            self.meeting = Meeting(id: self.meeting!.id, creatorID: User.currentUser.account!.id, name: nameTextField.text!, types: interests, info: infoTextView.text, online: onlineSwitch.isOn, isPrivate: privateSwitch.isOn, participants: friendIds, groups: groupIds, participantsMax: Int(maxParticipantsTextField.text!)!, Location: locationTextView.text, startingDate: datePicker1.date, endingDate: endingDate, currentParticipantNumber: self.meeting!.currentParticipantNumber)
            
            MeetingRequests.shared.editMeeting(meeting: meeting!, completion: {(error) in
                if let error = error {
                    let alert = ErrorChecker.handler.getAlertController(error: error)
                    self.present(alert, animated: true, completion: nil)
                    return
                }
                let index = User.currentUser.plannedMeetings.firstIndex(of: self.meeting!)
                User.currentUser.plannedMeetings[index!] = self.meeting!
                self.navigationController?.popViewController(animated: true)
            })
        } else {
            self.meeting = Meeting(id: 0, creatorID: User.currentUser.account!.id, name: nameTextField.text!, types: interests, info: infoTextView.text, online: onlineSwitch.isOn, isPrivate: privateSwitch.isOn, participants: friendIds, groups: groupIds, participantsMax: Int(maxParticipantsTextField.text!)!, Location: locationTextView.text, startingDate: datePicker1.date, endingDate: endingDate, currentParticipantNumber: 1)
            
            MeetingRequests.shared.createMeeting(meeting: meeting!, completion: {(meeting, error) in
                if let error = error {
                    let alert = ErrorChecker.handler.getAlertController(error: error)
                    self.present(alert, animated: true, completion: nil)
                    return
                }
                
                if let meeting = meeting {
                    User.currentUser.plannedMeetings.append(meeting)
                    self.navigationController?.popViewController(animated: true)
                }
            })
        }
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
        meetingImage.image = userPickedImage
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
    
    @objc func updateStartingDateTextview() {
        formatter.dateFormat = "dd.MM HH:mm"
        startingDateTextField.text = formatter.string(from: datePicker1.date)
    }
    
    @objc func updateEndingDateTextview() {
        formatter.dateFormat = "dd.MM HH:mm"
        endingDateTextField.text = formatter.string(from: datePicker2.date)
    }
    
    @objc func addFriends() {
        let vc = ChooseParticipantsVC()
        navigationController?.pushViewController(vc, animated: true)
    }
    
   
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == maxParticipantsTextField {
            if let number = Int(maxParticipantsTextField.text!) {
                if number > 100 {
                    maxParticipantsTextField.text = 100.description
                }
                if number < 2 {
                    maxParticipantsTextField.text = 2.description
                }
            } else {
                maxParticipantsTextField.text = ""
            }
        }
        
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
        mainView.setHeight(to: 1050)
        
        configNameAndImageView()
        configOnlinePrivateView()
        configInfoAndInterestsView()
        configDateView()
        configLocationView()
        configParticipantsView()
    }
    
    
    func configNameAndImageView() {
        chooseImageButton.setTitle("Выбрать изображение", for: .normal)
        chooseImageButton.addTarget(self, action: #selector(chooseImage), for: .touchUpInside)
        mainView.addSubview(chooseImageButton)
        chooseImageButton.pinTop(to: mainView.safeAreaLayoutGuide.topAnchor, const: 0)
        chooseImageButton.pinCenter(to: mainView.safeAreaLayoutGuide.centerXAnchor, const: 0)
        chooseImageButton.setWidth(to: 200)
        
        mainView.addSubview(meetingImage)
        meetingImage.pinTop(to: chooseImageButton.bottomAnchor, const: 0)
        meetingImage.pinCenter(to: mainView.safeAreaLayoutGuide.centerXAnchor, const: 0)
        meetingImage.pinWidth(to: mainView.safeAreaLayoutGuide.widthAnchor, mult: 0.5)
        meetingImage.pinHeight(to: mainView.safeAreaLayoutGuide.widthAnchor, mult: 0.5)
        meetingImage.image = UIImage(named: "placeholder")
        
        Utilities.styleTextField(nameTextField)
        mainView.addSubview(nameTextField)
        nameTextField.pinCenter(to: mainView.safeAreaLayoutGuide.centerXAnchor, const: 0)
        nameTextField.pinTop(to: meetingImage.bottomAnchor, const: 10)
        nameTextField.setWidth(to: 300)
        nameTextField.setHeight(to: 30)
        nameTextField.placeholder = "Название мероприятия"
        nameTextField.delegate = self
    }
    
    
    func configOnlinePrivateView() {
        let onlineLabel = UILabel()
        onlineLabel.text = "Онлайн"
        mainView.addSubview(onlineLabel)
        onlineLabel.pinTop(to: nameTextField.bottomAnchor, const: 20)
        onlineLabel.pinLeft(to: mainView.leadingAnchor, const: 30)
        onlineLabel.setHeight(to: 30)
        onlineLabel.setWidth(to: 100)
        
        mainView.addSubview(onlineSwitch)
        onlineSwitch.pinCenter(to: onlineLabel.centerYAnchor, const: 0)
        onlineSwitch.pinRight(to: mainView.trailingAnchor, const: 30)
        
        let privateLabel = UILabel()
        privateLabel.text = "Приватное"
        mainView.addSubview(privateLabel)
        privateLabel.pinTop(to: onlineLabel.bottomAnchor, const: 10)
        privateLabel.pinLeft(to: mainView.leadingAnchor, const: 30)
        privateLabel.setHeight(to: 30)
        privateLabel.setWidth(to: 100)
        
        mainView.addSubview(privateSwitch)
        privateSwitch.pinCenter(to: privateLabel.centerYAnchor, const: 0)
        privateSwitch.pinRight(to: mainView.trailingAnchor, const: 30)
    }
    
    
    func configInfoAndInterestsView() {
        let infoLabel = UILabel()
        infoLabel.font = UIFont.boldSystemFont(ofSize: 15)
        infoLabel.textColor = .systemGray
        infoLabel.text = "О мероприятии"
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
        interestsLabel.text = "Теги мероприятия"
        mainView.addSubview(interestsLabel)
        interestsLabel.pinTop(to: infoTextView.bottomAnchor, const: 10)
        interestsLabel.pinLeft(to: mainView.safeAreaLayoutGuide.leadingAnchor, const: 30)
        interestsLabel.setWidth(to: 150)
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

    func configDateView() {
        let datesLabel = UILabel()
        datesLabel.font = UIFont.boldSystemFont(ofSize: 15)
        datesLabel.textColor = .systemGray
        datesLabel.text = "Время проведения"
        mainView.addSubview(datesLabel)
        datesLabel.pinTop(to: interestsTextView.bottomAnchor, const: 20)
        datesLabel.pinLeft(to: mainView.safeAreaLayoutGuide.leadingAnchor, const: 30)
        datesLabel.setWidth(to: 150)
        datesLabel.setHeight(to: 30)
        
        let startingDateLabel = UILabel()
        startingDateLabel.text = "Начало:"
        mainView.addSubview(startingDateLabel)
        startingDateLabel.pinTop(to: datesLabel.bottomAnchor, const: 10)
        startingDateLabel.pinLeft(to: mainView.leadingAnchor, const: 20)
        startingDateLabel.setHeight(to: 30)
        startingDateLabel.setWidth(to: 80)
        
        Utilities.styleTextField(startingDateTextField)
        datePicker1.datePickerMode = .dateAndTime
        datePicker1.addTarget(self, action: #selector(updateStartingDateTextview), for: .valueChanged)
        mainView.addSubview(startingDateTextField)
        startingDateTextField.pinLeft(to: startingDateLabel.trailingAnchor, const: 10)
        startingDateTextField.pinCenter(to: startingDateLabel.centerYAnchor, const: 0)
        startingDateTextField.setWidth(to: 150)
        startingDateTextField.setHeight(to: 30)
        startingDateTextField.inputView = datePicker1
        startingDateTextField.delegate = self
        
        let endingDateLabel = UILabel()
        endingDateLabel.text = "Конец:"
        mainView.addSubview(endingDateLabel)
        endingDateLabel.pinTop(to: startingDateLabel.bottomAnchor, const: 10)
        endingDateLabel.pinLeft(to: mainView.leadingAnchor, const: 20)
        endingDateLabel.setHeight(to: 30)
        endingDateLabel.setWidth(to: 80)
        
        Utilities.styleTextField(endingDateTextField)
        datePicker2.datePickerMode = .dateAndTime
        datePicker2.addTarget(self, action: #selector(updateEndingDateTextview), for: .valueChanged)
        mainView.addSubview(endingDateTextField)
        endingDateTextField.pinLeft(to: endingDateLabel.trailingAnchor, const: 10)
        endingDateTextField.pinCenter(to: endingDateLabel.centerYAnchor, const: 0)
        endingDateTextField.setWidth(to: 150)
        endingDateTextField.setHeight(to: 30)
        endingDateTextField.inputView = datePicker2
        endingDateTextField.delegate = self
    }
    
    func configLocationView() {
        let locationLabel = UILabel()
        view.addSubview(locationLabel)
        locationLabel.text = "Место проведения"
        locationLabel.font = UIFont.boldSystemFont(ofSize: 15)
        locationLabel.textColor = .systemGray
        locationLabel.pinTop(to: endingDateTextField.bottomAnchor, const: 20)
        locationLabel.pinLeft(to: mainView.leadingAnchor, const: 30)
        locationLabel.setWidth(to: 150)
        locationLabel.setHeight(to: 30)
        
        view.addSubview(locationTextView)
        locationTextView.pinTop(to: locationLabel.bottomAnchor, const: 0)
        locationTextView.pinLeft(to: mainView.leadingAnchor, const: 20)
        locationTextView.pinRight(to: mainView.trailingAnchor, const: 20)
        locationTextView.setHeight(to: 100)
        locationTextView.delegate = self
    }
    
    func configParticipantsView() {
        let participantsLabel = UILabel()
        participantsLabel.font = UIFont.boldSystemFont(ofSize: 15)
        participantsLabel.textColor = .systemGray
        participantsLabel.text = "Участники"
        mainView.addSubview(participantsLabel)
        participantsLabel.pinTop(to: locationTextView.bottomAnchor, const: 20)
        participantsLabel.pinLeft(to: mainView.safeAreaLayoutGuide.leadingAnchor, const: 30)
        participantsLabel.setWidth(to: 150)
        participantsLabel.setHeight(to: 30)
        
        let maxPartaicipantsLabel = UILabel()
        maxPartaicipantsLabel.text = "Макс. участников:"
        mainView.addSubview(maxPartaicipantsLabel)
        maxPartaicipantsLabel.pinTop(to: participantsLabel.bottomAnchor, const: 0)
        maxPartaicipantsLabel.pinLeft(to: mainView.leadingAnchor, const: 20)
        maxPartaicipantsLabel.setHeight(to: 30)
        maxPartaicipantsLabel.setWidth(to: 180)
        
        Utilities.styleTextField(maxParticipantsTextField)
        mainView.addSubview(maxParticipantsTextField)
        maxParticipantsTextField.pinCenter(to: maxPartaicipantsLabel.centerYAnchor, const: 0)
        maxParticipantsTextField.pinLeft(to: maxPartaicipantsLabel.trailingAnchor, const: 0)
        maxParticipantsTextField.setWidth(to: 60)
        maxParticipantsTextField.setHeight(to: 30)
        maxParticipantsTextField.delegate = self
        
        Utilities.styleFilledButton(addFriendsButton)
        addFriendsButton.setTitle("Добавить участников", for: .normal)
        mainView.addSubview(addFriendsButton)
        addFriendsButton.pinTop(to: maxPartaicipantsLabel.bottomAnchor, const: 20)
        addFriendsButton.pinLeft(to: mainView.leadingAnchor, const: 20)
        addFriendsButton.setHeight(to: 40)
        addFriendsButton.pinRight(to: mainView.trailingAnchor, const: 20)
        addFriendsButton.addTarget(self, action: #selector(addFriends), for: .touchUpInside)
        
//        mainView.addSubview(invitedFriendsLabel)
//        invitedFriendsLabel.layer.borderWidth = 1
//        invitedFriendsLabel.layer.cornerRadius = 10
//        invitedFriendsLabel.backgroundColor = .systemGray4
//        invitedFriendsLabel.pinLeft(to: addFriendsButton.trailingAnchor, const: 10)
//        invitedFriendsLabel.pinCenter(to: addFriendsButton.centerYAnchor, const: 0)
//        invitedFriendsLabel.setWidth(to: 20)
//        invitedFriendsLabel.setHeight(to: 20)
//
//        Utilities.styleFilledButton(addGroupsButton)
//        addGroupsButton.setTitle("Добавить группы", for: .normal)
//        mainView.addSubview(addGroupsButton)
//        addGroupsButton.pinTop(to: addFriendsButton.bottomAnchor, const: 20)
//        addGroupsButton.pinLeft(to: mainView.leadingAnchor, const: 20)
//        addGroupsButton.setHeight(to: 30)
//        addGroupsButton.setWidth(to: 180)
//        addGroupsButton.addTarget(self, action: #selector(addGroups), for: .touchUpInside)
//
//        mainView.addSubview(invitedGroupsLabel)
//        invitedGroupsLabel.layer.borderWidth = 1
//        invitedGroupsLabel.layer.cornerRadius = 10
//        invitedGroupsLabel.backgroundColor = .systemGray4
//        invitedGroupsLabel.pinLeft(to: addGroupsButton.trailingAnchor, const: 10)
//        invitedGroupsLabel.pinCenter(to: addGroupsButton.centerYAnchor, const: 0)
//        invitedGroupsLabel.setWidth(to: 20)
//        invitedGroupsLabel.setHeight(to: 20)
    }
    
}
