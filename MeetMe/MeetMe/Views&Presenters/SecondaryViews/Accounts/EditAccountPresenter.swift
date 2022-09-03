//
//  EditAccountVC.swift
//  MeetMe
//
//  Created by Stepan Ostapenko on 12.03.2022.
//

import UIKit
import Kingfisher

/// Контроллер, отвечающий за редактирование информации об аккаунте
class EditAccountVC: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate & UINavigationControllerDelegate, UITextViewDelegate {
    
    private var chosenImage: UIImage?
    private var editAccountView: EditAccountView!
    /// Кнопка сохранения введенной информации
    var saveButton: UIBarButtonItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configView()
    }
    
    private func configView() {
        saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveProfile))
        self.navigationItem.rightBarButtonItem = saveButton
        editAccountView = EditAccountView()
        editAccountView.chooseImageButton.addTarget(self, action: #selector(chooseImage), for: .touchUpInside)
        editAccountView.editInterestsButton.addTarget(self, action: #selector(editInterests), for: .touchUpInside)
        view = editAccountView
    }
    
    /// Сохранение внесенных изменений
    @objc private func saveProfile() {
        editAccountView.account.socialMediaLinks["vk"] = editAccountView.vkLinkTextField.text ?? ""
        editAccountView.account.socialMediaLinks["tg"] = editAccountView.tgLinkTextField.text ?? ""
        editAccountView.account.socialMediaLinks["inst"] = editAccountView.instLinkTextField.text ?? ""
        
        editAccountView.account.info = editAccountView.infoTextView.text
        if !editAccountView.nameTextField.text!.isEmpty {
            editAccountView.account.name = editAccountView.nameTextField.text!
        }
        
        AccountRequests.shared.editAccount(image: chosenImage, account: EditAccountDTO(fullName: editAccountView.account.name, description: editAccountView.account.info, links: editAccountView.account.socialMediaLinks, interests: InterestsParser.getInterestsString(interests: editAccountView.account.interests)), completion: {(account, error) in
            
            if let error = error {
                let alert = ErrorChecker.handler.getAlertController(error: error)
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            if let account = account {
                User.currentUser.account = Account(account: account)
                self.navigationController?.popViewController(animated: true)
            }
        })
    }
    
    /// Редактирование интересов пользователя
    @objc private func editInterests() {
        let vc = InterestsVC()
        vc.interests = editAccountView.account.interests
        vc.completion = {(interests) in
            print(interests)
            self.editAccountView.account.interests = interests
            self.editAccountView.interestsTextView.text = Styling.getInterests(interestArray: self.editAccountView.account.interests)
        }
        
        if let sheet = vc.sheetPresentationController {
            sheet.detents = [ .medium(), .large() ]
        }
        
        present(vc, animated: true)
    }
    
    /// Выбор изображения пользователя 
    @objc private func chooseImage() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
    }
    
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let userPickedImage = info[.editedImage] as? UIImage else { return }
        editAccountView.accountImage.image = userPickedImage
        chosenImage = userPickedImage
        picker.dismiss(animated: true)
    }
    
    
}

