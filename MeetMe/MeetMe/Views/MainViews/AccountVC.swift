//
//  AccountVC.swift
//  MeetMe
//
//  Created by Stepan Ostapenko on 24.02.2022.
//

import UIKit

class AccountVC: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    var logoutButton: UIBarButtonItem?
    var editButton: UIBarButtonItem?
    var saveButton: UIBarButtonItem?
    
    var canEdit = false
    
    let chooseImageButton = UIButton(type: .system)
    
    let accountImage : UIImageView = {
        let image = UIImageView(frame: .zero)
        image.contentMode = .scaleAspectFit
        image.layer.borderWidth = 0
        return image
    }()
    
    let nameTextField : UITextField = {
        let textField = UITextField(frame: CGRect(x: 0, y: 0, width: 200, height: 30))
        textField.keyboardType = UIKeyboardType.default
        textField.returnKeyType = UIReturnKeyType.done
        textField.autocorrectionType = UITextAutocorrectionType.no
        textField.clearButtonMode = UITextField.ViewMode.whileEditing;
        textField.textAlignment = .center
        return textField
    }()
    
    
    let infoTextField = UITextView()
    let intrestsTextField = UITextField()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        logoutButton = UIBarButtonItem(title: "Sign out", style: .done, target: self, action: #selector(signOut))
        editButton = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editProfile))
        saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveProfile))
        
        self.navigationItem.rightBarButtonItem = logoutButton
        self.navigationItem.leftBarButtonItem = editButton
        
        configView()
    }
    
    private func configView() {
        
        chooseImageButton.setTitle("Выбрать изображение", for: .normal)
        chooseImageButton.isHidden = true
        chooseImageButton.addTarget(self, action: #selector(chooseImage), for: .touchUpInside)
        view.addSubview(chooseImageButton)
        chooseImageButton.pinTop(to: view.safeAreaLayoutGuide.topAnchor, const: 0)
        chooseImageButton.pinCenter(to: view.safeAreaLayoutGuide.centerXAnchor, const: 0)
        chooseImageButton.setWidth(to: 200)
    
        view.addSubview(accountImage)
        accountImage.pinTop(to: chooseImageButton.bottomAnchor, const: 5)
        accountImage.pinCenter(to: view.safeAreaLayoutGuide.centerXAnchor, const: 0)
        accountImage.setWidth(to: 250)
        accountImage.setHeight(to: 250)
        accountImage.image = UIImage(named: "placeholder")
        
        
        view.addSubview(nameTextField)
        nameTextField.pinCenter(to: view.safeAreaLayoutGuide.centerXAnchor, const: 0)
        nameTextField.pinTop(to: accountImage.bottomAnchor, const: 20)
        //nameTextField.setWidth(to: 250)
        //nameTextField.setHeight(to: 30)
        nameTextField.text = User.currentUser.account?.name
        nameTextField.isUserInteractionEnabled = false
        nameTextField.delegate = self
        
        view.addSubview(infoTextField)
        infoTextField.pinTop(to: nameTextField.bottomAnchor, const: 10)
        infoTextField.pinLeft(to: view.safeAreaLayoutGuide.leadingAnchor, const: 10)
        
    }
    
    func enableEditing() {
        nameTextField.isUserInteractionEnabled = true
        infoTextField.isUserInteractionEnabled = true
        intrestsTextField.isUserInteractionEnabled = true
        chooseImageButton.isHidden = false
    }
    
    func disableEditing() {
        nameTextField.isUserInteractionEnabled = false
        infoTextField.isUserInteractionEnabled = false
        intrestsTextField.isUserInteractionEnabled = false
        chooseImageButton.isHidden = true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
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
        accountImage.image = userPickedImage
        picker.dismiss(animated: true)
    }
    
    @objc func signOut() {
        view.setRootViewController(NavigationHandler.createAuthNC(), animated: true)
    }

    @objc func editProfile() {
        enableEditing()
        navigationItem.leftBarButtonItem = saveButton
    }
    
    @objc func saveProfile() {
        disableEditing()
        navigationItem.leftBarButtonItem = editButton
    }
}
