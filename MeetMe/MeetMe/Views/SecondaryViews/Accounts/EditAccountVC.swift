//
//  EditAccountVC.swift
//  MeetMe
//
//  Created by Stepan Ostapenko on 12.03.2022.
//

import UIKit

class EditAccountVC: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate & UINavigationControllerDelegate, UITextViewDelegate {
    
    var account = Account(account: User.currentUser.account!)
    var saveButton: UIBarButtonItem?

    let chooseImageButton = UIButton(type: .system)
    let editInterestsButton = UIButton(type: .system)
    
    let scrollView = UIScrollView()
    let editView = UIView()
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.backgroundColor = .systemGray4
        tabBarController?.tabBar.backgroundColor = .systemGray4
        
        saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveProfile))
        
        self.navigationItem.rightBarButtonItem = saveButton
        
        configView()
    }
    
    private func configView() {
        
        view.addSubview(scrollView)
        scrollView.addSubview(editView)
        
        scrollView.isScrollEnabled = true
        scrollView.isUserInteractionEnabled = true
        scrollView.isPagingEnabled = false
        
        scrollView.pinCenter(to: view.safeAreaLayoutGuide.centerXAnchor, const: 0)
        scrollView.pinWidth(to: view.widthAnchor, mult: 1)
        scrollView.pinTop(to: view.topAnchor, const: 0)
        scrollView.pinBottom(to: view.bottomAnchor, const: 0)
        editView.pin(to: scrollView)
        editView.pinWidth(to: view.widthAnchor, mult: 1)
        editView.pinHeight(to: view.heightAnchor, mult: 1)

        
        chooseImageButton.setTitle("Выбрать изображение", for: .normal)
        chooseImageButton.addTarget(self, action: #selector(chooseImage), for: .touchUpInside)
        editView.addSubview(chooseImageButton)
        chooseImageButton.pinTop(to: editView.safeAreaLayoutGuide.topAnchor, const: 0)
        chooseImageButton.pinCenter(to: editView.safeAreaLayoutGuide.centerXAnchor, const: 0)
        chooseImageButton.setWidth(to: 200)
    
        editView.addSubview(accountImage)
        accountImage.pinTop(to: chooseImageButton.bottomAnchor, const: 0)
        accountImage.pinCenter(to: editView.safeAreaLayoutGuide.centerXAnchor, const: 0)
        accountImage.pinWidth(to: editView.safeAreaLayoutGuide.widthAnchor, mult: 0.5)
        accountImage.pinHeight(to: editView.safeAreaLayoutGuide.widthAnchor, mult: 0.5)
        accountImage.image = UIImage(named: "placeholder")
        
        Utilities.styleTextField(nameTextField)
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
        editInterestsButton.addTarget(self, action: #selector(editInterests), for: .touchUpInside)
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
        
        Utilities.styleTextField(vkLinkTextField)
        Utilities.styleTextField(tgLinkTextField)
        
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
    }
    
   
    
    @objc func editInterests() {
        let vc = InterestsVC()
        vc.interests = account.interests
        vc.completion = {(interests) in
            print(interests)
            self.account.interests = interests
            self.interestsTextView.text = Utilities.getInterests(interestArray: self.account.interests)
        }
        
        if let sheet = vc.sheetPresentationController {
            sheet.detents = [ .medium(), .large() ]
        }
        
        present(vc, animated: true)
    }
    
    
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
    
    @objc func saveProfile() {
        
        if vkLinkTextField.text != nil {
            account.socialMediaLinks["vk"] = vkLinkTextField.text!
        }
        
        if tgLinkTextField.text != nil {
            account.socialMediaLinks["tg"] = tgLinkTextField.text!
        }
        
        account.info = infoTextView.text
        if !nameTextField.text!.isEmpty {
            account.name = nameTextField.text!
        }
        
        
        AuthRequests.shared.editAccount(account: EditAccountDTO(fullName: account.name, description: account.info, links: account.socialMediaLinks, interests: InterestsParser.getInterestsString(interests: account.interests)), completion: {(account, error) in
            
            if let error = error {
                let alert = ErrorChecker.handler.getAlertController(error: error)
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            if let account = account {
                User.currentUser.account = Account(account: self.account)
                self.navigationController?.popViewController(animated: true)
            }
        })
    }
}

