//
//  AccountVC.swift
//  MeetMe
//
//  Created by Stepan Ostapenko on 24.02.2022.
//

import UIKit

class AccountVC: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate & UINavigationControllerDelegate, UITextViewDelegate {
    
    var account: Account?
    
    var logoutButton: UIBarButtonItem?
    var editButton: UIBarButtonItem?
    
    let scrollView = UIScrollView()
    let accountView = UIStackView()
    let friendsButton = UIButton()
    
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
        textField.isUserInteractionEnabled = false
        return textField
    }()
    
    let infoTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 15)
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.systemGray.cgColor
        textView.layer.cornerRadius = 5
        textView.autocorrectionType = UITextAutocorrectionType.no
        textView.isUserInteractionEnabled = false
        return textView
    }()
    
    let interestsTextView : UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 15)
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.systemGray.cgColor
        textView.layer.cornerRadius = 5
        textView.autocorrectionType = UITextAutocorrectionType.no
        textView.isUserInteractionEnabled = false
        return textView
    }()
    
    let vkLinkTextField : UITextField = {
        let textField = UITextField(frame: CGRect(x: 0, y: 0, width: 200, height: 30))
        textField.keyboardType = UIKeyboardType.default
        textField.returnKeyType = UIReturnKeyType.done
        textField.autocorrectionType = UITextAutocorrectionType.no
        textField.clearButtonMode = UITextField.ViewMode.whileEditing;
        textField.textAlignment = .left
        textField.placeholder = "Аккаунт ВК"
        textField.isUserInteractionEnabled = false
        textField.textColor = .systemBlue
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
        textField.isEnabled = false
        textField.isUserInteractionEnabled = false
        return textField
    }()
    
    let imageAndNameHeight = 320
    let infoHeight = 120
    let interestsHeight = 120
    let linksHeight = 200
    
    var accountViewHeight = 0
    var accountViewHeightConstraint: NSLayoutConstraint?
    
    var isUserAccount = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.backgroundColor = .systemGray4
        tabBarController?.tabBar.backgroundColor = .systemGray4
        
        logoutButton = UIBarButtonItem(title: "Sign out", style: .done, target: self, action: #selector(signOut))
        editButton = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editProfile))
        
        self.navigationItem.rightBarButtonItem = logoutButton
        self.navigationItem.leftBarButtonItem = editButton
        
        configView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setAccountInfo()
    }
    
    @objc func viewFriends() {
        
        let vc = FriendsVC()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func setAccountInfo() {
        accountViewHeight = imageAndNameHeight
        
        if let accountViewHeightConstraint = accountViewHeightConstraint {
            accountViewHeightConstraint.isActive = false
        }
        
        if isUserAccount {
            account = User.currentUser.account
        }
        
        print(self.account!.info)
        print(self.account!.interests)
        print(self.account!.socialMediaLinks)
        
        accountView.removeFullyAllArrangedSubviews()
        accountView.addArrangedSubview(configImageAndNameView())
        nameTextField.text = account?.name
        
        if User.currentUser.account?.info != "" {
            infoTextView.text = account?.info
            accountViewHeight += infoHeight
            accountView.addArrangedSubview(configInfoTextView())
        }

        if User.currentUser.account?.interests != [] {
            interestsTextView.text = Utilities.getInterests(interestArray: account?.interests ?? [])
            accountViewHeight += interestsHeight
            accountView.addArrangedSubview(configIterestsTextView())
        }

        if !(User.currentUser.account?.socialMediaLinks.isEmpty ?? true) {
            var vkLink = ""
            var tgLink = ""
            if let accountVkLink = account?.socialMediaLinks["vk"] {
                vkLinkTextField.text = accountVkLink
                vkLink = accountVkLink
            }
            if let accountTgLink = account?.socialMediaLinks["tg"] {
                tgLinkTextField.text = accountTgLink
                tgLink = accountTgLink
            }
            
            if !vkLink.isEmpty || !tgLink.isEmpty {
                accountViewHeight += linksHeight
                accountView.addArrangedSubview(configLinksView())
            }
            
        }
        
        accountViewHeightConstraint = accountView.heightAnchor.constraint(equalToConstant: CGFloat(accountViewHeight))
        accountViewHeightConstraint?.isActive = true
        //accountView.setHeight(to: accountViewHeight)
    }
    
    private func configView() {

        view.addSubview(scrollView)
        scrollView.addSubview(accountView)
        
        scrollView.isScrollEnabled = true
        scrollView.isUserInteractionEnabled = true
        scrollView.isPagingEnabled = false
        
        scrollView.pinCenter(to: view.safeAreaLayoutGuide.centerXAnchor, const: 0)
        scrollView.pinWidth(to: view.widthAnchor, mult: 1)
        scrollView.pinTop(to: view.topAnchor, const: 0)
        scrollView.pinBottom(to: view.bottomAnchor, const: 0)
        accountView.pin(to: scrollView)
        accountView.pinWidth(to: view.widthAnchor, mult: 1)
        
        accountView.spacing = 0
        accountView.axis  = NSLayoutConstraint.Axis.vertical
        
    }
    
    private func configImageAndNameView() -> UIView {
        let view = UIView()
        view.setHeight(to: imageAndNameHeight)
        //view.pinWidth(to: view.widthAnchor, mult: 1)
        view.addSubview(accountImage)
        accountImage.pinTop(to: view.safeAreaLayoutGuide.topAnchor, const: 10)
        accountImage.pinCenter(to: view.safeAreaLayoutGuide.centerXAnchor, const: 0)
        accountImage.setHeight(to: 220)
        accountImage.setWidth(to: 220)
        accountImage.image = UIImage(named: "placeholder")
        
        view.addSubview(nameTextField)
        Utilities.styleTextField(nameTextField)
        nameTextField.pinCenter(to: accountImage.safeAreaLayoutGuide.centerXAnchor, const: 0)
        nameTextField.pinTop(to: accountImage.bottomAnchor, const: 10)
        //nameTextField.pinBottom(to: view.bottomAnchor, const: 10)
        nameTextField.setHeight(to: 30)
        nameTextField.setWidth(to: 200)
        nameTextField.delegate = self
        nameTextField.isUserInteractionEnabled = false
        
        view.addSubview(friendsButton)
        friendsButton.pinLeft(to: view.leadingAnchor, const: 0)
        friendsButton.pinRight(to: view.trailingAnchor, const: 0)
        friendsButton.setHeight(to: 40)
        friendsButton.pinTop(to: nameTextField.bottomAnchor, const: 5)
        friendsButton.layer.borderWidth = 1
        friendsButton.layer.borderColor = UIColor.systemGray.cgColor
        friendsButton.setTitle("Друзья", for: .normal)
        friendsButton.setTitleColor(.darkGray, for: .normal)
        friendsButton.addTarget(self, action: #selector(viewFriends), for: .touchUpInside)
        
        return view
    }
    
    private func configInfoTextView() -> UIView{
        let view = UIView()
        view.setHeight(to: infoHeight)
        view.pinWidth(to: view.widthAnchor, mult: 1)
        
        let infoLabel = UILabel()
        infoLabel.font = UIFont.boldSystemFont(ofSize: 15)
        infoLabel.textColor = .systemGray
        infoLabel.text = "О себе"
        view.addSubview(infoLabel)
        infoLabel.pinTop(to: view.topAnchor, const: 10)
        infoLabel.pinLeft(to: view.safeAreaLayoutGuide.leadingAnchor, const: 30)
        infoLabel.setWidth(to: 150)
        infoLabel.setHeight(to: 30)
        
        view.addSubview(infoTextView)
        infoTextView.pinTop(to: infoLabel.bottomAnchor, const: 0)
        infoTextView.pinLeft(to: view.safeAreaLayoutGuide.leadingAnchor, const: 20)
        infoTextView.pinRight(to: view.safeAreaLayoutGuide.trailingAnchor, const: 20)
        infoTextView.setHeight(to: 80)
        infoTextView.delegate = self
        
        return view
    }
    
    private func configIterestsTextView() ->  UIView {
        let view = UIView()
        view.setHeight(to: interestsHeight)
        view.pinWidth(to: view.widthAnchor, mult: 1)
        
        let interestsLabel = UILabel()
        interestsLabel.font = UIFont.boldSystemFont(ofSize: 15)
        interestsLabel.textColor = .systemGray
        interestsLabel.text = "Интересы"
        view.addSubview(interestsLabel)
        interestsLabel.pinTop(to: view.topAnchor, const: 10)
        interestsLabel.pinLeft(to: view.safeAreaLayoutGuide.leadingAnchor, const: 30)
        interestsLabel.setWidth(to: 150)
        interestsLabel.setHeight(to: 30)
        
        view.addSubview(interestsTextView)
        interestsTextView.pinTop(to: interestsLabel.bottomAnchor, const: 0)
        interestsTextView.pinLeft(to: view.safeAreaLayoutGuide.leadingAnchor, const: 20)
        interestsTextView.pinRight(to: view.safeAreaLayoutGuide.trailingAnchor, const: 20)
        interestsTextView.setHeight(to: 80)
        
        return view
    }
    
    private func configLinksView() -> UIView {
        let view = UIView()
        view.setHeight(to: linksHeight)
        view.pinWidth(to: view.widthAnchor, mult: 1)
        view.setContentHuggingPriority(.init(100.0), for: .vertical)
        Utilities.styleTextField(vkLinkTextField)
        Utilities.styleTextField(tgLinkTextField)
        
        let linksLabel = UILabel()
        linksLabel.font = UIFont.boldSystemFont(ofSize: 15)
        linksLabel.textColor = .systemGray
        linksLabel.text = "Ссылки на соц. сети"
        view.addSubview(linksLabel)
        linksLabel.pinTop(to: view.topAnchor, const: 10)
        linksLabel.pinLeft(to: view.leadingAnchor, const: 25)
        linksLabel.setHeight(to: 30)
        linksLabel.setWidth(to: 200)
       
        let vkImage = UIImageView(image: UIImage(named: "vkLogo"))
        view.addSubview(vkImage)
        vkImage.contentMode = .scaleAspectFit
        vkImage.pinTop(to: linksLabel.bottomAnchor, const: 0)
        vkImage.pinLeft(to: view.safeAreaLayoutGuide.leadingAnchor, const: 20)
        vkImage.setWidth(to: 50)
        vkImage.setHeight(to: 50)
        
        view.addSubview(vkLinkTextField)
        vkLinkTextField.pinLeft(to: vkImage.trailingAnchor, const: 5)
        vkLinkTextField.pinCenter(to: vkImage.centerYAnchor, const: 0)
        vkLinkTextField.setWidth(to: 200)
        vkLinkTextField.setHeight(to: 30)
        vkLinkTextField.delegate = self
        
        let tgImage = UIImageView(image: UIImage(named: "tgLogo"))
        view.addSubview(tgImage)
        tgImage.contentMode = .scaleAspectFit
        tgImage.pinTop(to: vkImage.bottomAnchor, const: 10)
        tgImage.pinLeft(to: view.safeAreaLayoutGuide.leadingAnchor, const: 20)
        tgImage.setWidth(to: 50)
        tgImage.setHeight(to: 50)
        
        view.addSubview(tgLinkTextField)
        tgLinkTextField.pinLeft(to: tgImage.trailingAnchor, const: 5)
        tgLinkTextField.pinCenter(to: tgImage.centerYAnchor, const: 0)
        tgLinkTextField.setWidth(to: 200)
        tgLinkTextField.setHeight(to: 30)
        tgLinkTextField.delegate = self
        
        return view
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
    
    @objc func signOut() {
        UserDefaults.standard.removeObject(forKey: "userName")
        UserDefaults.standard.removeObject(forKey: "userPassword")
        view.setRootViewController(NavigationHandler.createAuthNC(), animated: true)
    }

    @objc func editProfile() {
        let editVC = EditAccountVC()
        navigationController?.pushViewController(editVC, animated: true)
    }
    
   
}
