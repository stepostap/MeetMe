import UIKit

/// Контроллер, отвечающий за создание и редактирование мероприятия
class CreateMeetingVC: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate & UINavigationControllerDelegate, UITextViewDelegate {
    /// Мероприятие, которое пользователь редактирует
    var meeting: Meeting?
    /// Кнопка для создания мероприятия или сохранения введенных изменений
    private var createButton: UIBarButtonItem?
    /// Список идентификаторов приглашенных друзей
    private var invitedFriendsIDs = [Int64]()
    /// Список идентификаторов приглашенных групп
    private var invitedGroupsIDs = [Int64]()
    /// UI элемент для отображения картинки мероприятия
    private var chosenImage: UIImage?
    /// Форматтер даты
    private let formatter = DateFormatter()
    private var createMeetingView: CreateMeetingView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "BackgroundMain")
        createButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(createMeeting))
        navigationItem.rightBarButtonItem = createButton
        configView()
    }
    
    private func configView() {
        createMeetingView = CreateMeetingView(meeting: meeting)
        createMeetingView.chooseImageButton.addTarget(self, action: #selector(chooseImage), for: .touchUpInside)
        createMeetingView.editInterestsButton.addTarget(self, action: #selector(editInterests), for: .touchUpInside)
        createMeetingView.chooseImageButton.addTarget(self, action: #selector(chooseImage), for: .touchUpInside)
        createMeetingView.addFriendsButton.addTarget(self, action: #selector(addFriends), for: .touchUpInside)
        view = createMeetingView
    }
    
    /// Проверка полей на наличие подходящей информации для создания/редактирования мероприятия
    private func createMeetingCheck() throws {
        if createMeetingView.nameTextField.text!.isEmpty {
            throw CreateMeetingError.noName
        }
        if createMeetingView.maxParticipantsTextField.text!.isEmpty {
            throw CreateMeetingError.noMaxUser
        }
        if createMeetingView.privateSwitch.isOn && invitedGroupsIDs.isEmpty && invitedFriendsIDs.isEmpty {
            throw CreateMeetingError.noParticipants
        }
        if createMeetingView.startingDateTextField.text!.isEmpty {
            throw CreateMeetingError.noStartingDate
        }
        if (!createMeetingView.endingDateTextField.text!.isEmpty &&
            createMeetingView.datePicker1.date > createMeetingView.datePicker2.date) {
            throw CreateMeetingError.startEndDateError
        }
        if (createMeetingView.datePicker1.date < Date.now) {
            throw CreateMeetingError.startEndDateError
        }
    }
    
    /// Создание / заверешение редактирования мероприятия
    @objc private func createMeeting()  {
        do {
            try createMeetingCheck()
        } catch let error {
            let alert = ErrorChecker.handler.getAlertController(error: error)
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        var endingDate: Date?
        if let text = createMeetingView.endingDateTextField.text, !text.isEmpty {
            endingDate = createMeetingView.datePicker2.date
        }
        
        if let _ = meeting {
            self.meeting = Meeting(id: self.meeting!.id, creatorID: User.currentUser.account!.id, chatID: self.meeting!.chatID, name: createMeetingView.nameTextField.text!, types: createMeetingView.interests, info: createMeetingView.infoTextView.text, online: createMeetingView.onlineSwitch.isOn, isPrivate: createMeetingView.privateSwitch.isOn, isParticipant: true, groups: meeting!.participantsGroupsID, participantsMax: Int(createMeetingView.maxParticipantsTextField.text!)!, Location: createMeetingView.locationTextView.text, startingDate: createMeetingView.datePicker1.date, endingDate: endingDate, currentParticipantNumber: self.meeting!.currentParticipantNumber)
            
            MeetingRequests.shared.editMeeting(image: chosenImage, meeting: meeting!, completion: {(meeting, error) in
                if let error = error {
                    let alert = ErrorChecker.handler.getAlertController(error: error)
                    self.present(alert, animated: true, completion: nil)
                    return
                }
                if let meeting = meeting {
                    meeting.isUserParticipant = true
                    let index = User.currentUser.plannedMeetings!.firstIndex(of: meeting)
                    User.currentUser.plannedMeetings![index!] = meeting
                    
                    if !self.invitedFriendsIDs.isEmpty {
                        MeetingRequests.shared.inviteAccountsToMeeting(invites: MeetingInvitationsDTO(users: self.invitedFriendsIDs, groups: self.invitedGroupsIDs), meetingID: meeting.id, completion: {(error) in
                            if let error = error {
                                let alert = ErrorChecker.handler.getAlertController(error: error)
                                self.present(alert, animated: true, completion: nil)
                                return
                            }
                        })
                    }
                    
                    self.navigationController?.popViewController(animated: true)
                }
            })
        } else {
            self.meeting = Meeting(id: 0, creatorID: User.currentUser.account!.id, chatID: 0, name: createMeetingView.nameTextField.text!, types: createMeetingView.interests, info: createMeetingView.infoTextView.text, online: createMeetingView.onlineSwitch.isOn, isPrivate: createMeetingView.privateSwitch.isOn, isParticipant: true,  groups: [], participantsMax: Int(createMeetingView.maxParticipantsTextField.text!)!, Location: createMeetingView.locationTextView.text, startingDate: createMeetingView.datePicker1.date, endingDate: endingDate, currentParticipantNumber: 1)
            
            MeetingRequests.shared.createMeeting(image: chosenImage, meeting: meeting!, completion: {(meeting, error) in
                if let error = error {
                    let alert = ErrorChecker.handler.getAlertController(error: error)
                    self.present(alert, animated: true, completion: nil)
                    return
                }
                
                if let meeting = meeting {
                    if let _ = User.currentUser.plannedMeetings {
                        meeting.isUserParticipant = true
                        let index = User.currentUser.plannedMeetings?.lastIndex(where: {$0.startingDate < meeting.startingDate})
                        if let index = index {
                            User.currentUser.plannedMeetings?.insert(meeting, at: index + 1)
                        } else {
                            User.currentUser.plannedMeetings?.insert(meeting, at: 0)
                        }
                    } else {
                        User.currentUser.plannedMeetings = [meeting]
                    }

                    if !self.invitedFriendsIDs.isEmpty || !self.invitedGroupsIDs.isEmpty {
                        MeetingRequests.shared.inviteAccountsToMeeting(invites: MeetingInvitationsDTO(users: self.invitedFriendsIDs, groups: self.invitedGroupsIDs), meetingID: meeting.id, completion: {(error) in
                            if let error = error {
                                let alert = ErrorChecker.handler.getAlertController(error: error)
                                self.present(alert, animated: true, completion: nil)
                                return
                            }
                        })
                    }
                    
                    self.navigationController?.popViewController(animated: true)
                }
            })
        }
    }
    
    /// Выбор изображения
    @objc private func chooseImage() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
    }
    
    /// Открытие ChooseParticipantsVC для выбора друзей и групп, которые будут приглашены на мероприятие
    @objc private func addFriends() {
        let vc = ChooseParticipantsVC()
        vc.includeGroups = true
        vc.passData = {(friends, groups) in
            self.invitedFriendsIDs = friends
            self.invitedGroupsIDs = groups
        }
        vc.chosenFriendIDs = invitedFriendsIDs
        vc.chosenGroupIDs = invitedGroupsIDs
        navigationController?.pushViewController(vc, animated: true)
    }
    
    ///  Редактирование списка интересов мероприятия
    @objc private func editInterests() {
        let vc = InterestsVC()
        vc.interests = createMeetingView.interests
        vc.completion = {(interests) in
            self.createMeetingView.interests = interests
            self.createMeetingView.interestsTextView.text = Styling.getInterests(interestArray: self.createMeetingView.interests)
        }
        if let sheet = vc.sheetPresentationController {
            sheet.detents = [ .medium(), .large() ]
        }
        present(vc, animated: true)
    }
    
    
    // MARK: Delegates
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let userPickedImage = info[.editedImage] as? UIImage else { return }
        createMeetingView.meetingImage.image = userPickedImage
        chosenImage = userPickedImage
        picker.dismiss(animated: true)
    }
}
