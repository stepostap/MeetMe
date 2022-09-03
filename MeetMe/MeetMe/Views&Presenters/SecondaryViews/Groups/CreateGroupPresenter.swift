//
//  CreateGroupVC.swift
//  MeetMe
//
//  Created by Stepan Ostapenko on 22.03.2022.
//

import UIKit
import Kingfisher

/// Контроллер, отвечающий за создание и редактирование группы
class CreateGroupVC: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    /// Группа, информацию о которой пользователь редактирует
    var group: Group?
    var completion: ((Group) -> (Void))?
    /// Список интересов
    private var interests = [Interests]()
    /// Список идентификаторов приглашенных в группу друзей
    private var invitedFriendsIDs = [Int64]()
    ///  Выбранное изображение группы
    private var chosenImage: UIImage?
    /// Форматер даты
    private let formatter = DateFormatter()
    /// Кнопка сохранения изменений или создания новой группы
    private var createButton: UIBarButtonItem?
    private let createGroupView = CreateGroupView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        showGroupInfo()
    }
    
    private func configView() {
        createButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(createGroup))
        navigationItem.rightBarButtonItem = createButton
        createGroupView.chooseImageButton.addTarget(self, action: #selector(chooseImage), for: .touchUpInside)
        createGroupView.editInterestsButton.addTarget(self, action: #selector(editInterests), for: .touchUpInside)
        createGroupView.addFriendsButton.addTarget(self, action: #selector(addFriends), for: .touchUpInside)
        view = createGroupView
    }
    
    /// Отображение информации о группе (при редактировании)
    private func showGroupInfo() {
        formatter.dateFormat = "dd.MM HH:mm"
        if let group = group {
            createGroupView.nameTextField.text = group.groupName
        
            createGroupView.privateSwitch.isOn = group.isPrivate
            createGroupView.infoTextView.text = group.groupInfo
            createGroupView.interestsTextView.text = Styling.getInterests(interestArray: group.interests)
            interests = group.interests
            if group.groupImageURL.isEmpty {
                createGroupView.groupImage.image = UIImage(named: "placeholder")
            } else {
                createGroupView.groupImage.kf.setImage(with: URL(string: group.groupImageURL), options: [.forceRefresh])
            }
            
        }
    }
    
    /// Проверка введенных пользователем данных
    private func createGroupCheck() throws {
        if createGroupView.nameTextField.text!.isEmpty {
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
            let dto = GroupEditDTO(name: createGroupView.nameTextField.text ?? group.groupName, description: createGroupView.infoTextView.text, isPrivate: createGroupView.privateSwitch.isOn, interests: InterestsParser.getInterestsString(interests: interests))
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
            let createdGroup = Group(id: 0, groupImage: "", groupName: createGroupView.nameTextField.text!, groupInfo: createGroupView.infoTextView.text, interests: interests, meetings: [], participants: [], admins: [User.currentUser.account!.id])
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
            self.createGroupView.interestsTextView.text = Styling.getInterests(interestArray: self.interests)
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
        createGroupView.groupImage.image = userPickedImage
        chosenImage = userPickedImage
        picker.dismiss(animated: true)
    }
}
