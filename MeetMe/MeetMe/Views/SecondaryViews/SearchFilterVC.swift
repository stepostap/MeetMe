//
//  SearchFilterVC.swift
//  MeetMe
//
//  Created by Stepan Ostapenko on 03.03.2022.
//

import UIKit

class SearchFilterVC: UIViewController, UITextFieldDelegate {
    
    let formatter = DateFormatter()
    
    var searchOptions: MeetingSearchFilter?
    
    var maxParticipants : UITextField = {
        let textField = UITextField()
        textField.keyboardType = UIKeyboardType.default
        textField.returnKeyType = UIReturnKeyType.done
        textField.autocorrectionType = UITextAutocorrectionType.no
        textField.borderStyle = UITextField.BorderStyle.roundedRect
        textField.clearButtonMode = UITextField.ViewMode.whileEditing;
        return textField
    }()
    
    var meetingTypeCheckboxes = [CheckBox]()
    
    let isOnline = CheckBox.init()
    
    let datePicker = UIDatePicker()
    let startingDateTextField : UITextField = {
        let textField = UITextField()
        textField.borderStyle = UITextField.BorderStyle.roundedRect
        textField.clearButtonMode = UITextField.ViewMode.whileEditing;
        return textField
    }()
    
    @objc func isOnlineCheckboxSync() {
        if isOnline.isChecked {
            searchOptions?.online = true
        } else {
            searchOptions?.online = false
        }
        
    }
    
    let interestsVC = InterestsVC()
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        interestsVC.interests = searchOptions?.types ?? []
        interestsVC.completion = {(interest) in
            self.searchOptions?.types = interest
        }
        
        self.addChild(interestsVC)
        interestsVC.didMove(toParent: self)
        
        maxParticipants.text = searchOptions?.participantsMax.description
        isOnline.isChecked = searchOptions?.online ?? true
        formatter.dateFormat = "dd.MM HH:mm"
        if let date = searchOptions?.startingDate {
            startingDateTextField.text = formatter.string(from: date)
        }
    
        configureView()
    }
    
    override func viewWillLayoutSubviews() {
        view.backgroundColor = .systemBackground
        
    }
        
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let number = Int(maxParticipants.text ?? "100"), number > 1 {
            searchOptions?.participantsMax = number
        }
        else if maxParticipants.text?.isEmpty ?? false {
            searchOptions?.participantsMax = 100
            maxParticipants.text = "100"
        }
        else {
            let alert = UIAlertController(title: "Ошибка ввода", message: "Введено недопустимое значение", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
            searchOptions?.participantsMax = 100
            maxParticipants.text = "100"
            present(alert, animated: true, completion: nil)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return maxParticipants.resignFirstResponder()
    }
   
    
    @objc func updateDateTextview() {
        formatter.dateFormat = "dd.MM HH:mm"
        startingDateTextField.text = formatter.string(from: datePicker.date)
        searchOptions?.startingDate = datePicker.date
        
    }
    
    @objc func clearOptions() {
        for checkbox in interestsVC.meetingTypeCheckboxes {
            checkbox.isChecked = false
        }
        searchOptions?.types = []
        maxParticipants.text = "100"
        searchOptions?.participantsMax = 100
        isOnline.isChecked = false
        startingDateTextField.text = ""
        searchOptions?.startingDate = nil
    }
    
    func configureView() {
        
        let clearButton = UIButton(type: .system)
        clearButton.setTitle("Очистить", for: .normal)
        clearButton.titleLabel?.font = .systemFont(ofSize: 15)
        clearButton.addTarget(self, action: #selector(clearOptions), for: .touchUpInside)
        view.addSubview(clearButton)
        clearButton.pinTop(to: view.safeAreaLayoutGuide.topAnchor, const: 10)
        clearButton.pinRight(to: view.safeAreaLayoutGuide.trailingAnchor, const: 10)
        clearButton.setWidth(to: 100)
        clearButton.setHeight(to: 30)
        
        isOnline.style = .tick
        isOnline.borderStyle = .rounded
        isOnline.addTarget(self, action: #selector(isOnlineCheckboxSync), for: .valueChanged)
        view.addSubview(isOnline)
        isOnline.setConstraints(to: view, left: 15, top: 20, width: 30, height: 30)
        let isOnlineLabel = UILabel()
        isOnlineLabel.text = "Онлайн"
        
        view.addSubview(isOnlineLabel)
        isOnlineLabel.pinTop(to: view.safeAreaLayoutGuide.topAnchor, const: 20)
        isOnlineLabel.pinLeft(to: isOnline.trailingAnchor, const: 10)
        isOnlineLabel.setWidth(to: 100)
        isOnlineLabel.setHeight(to: 30)
        
        let maxParticipantsLabel = UILabel()
        maxParticipantsLabel.text = "Макс. число участников:"
        view.addSubview(maxParticipantsLabel)
        maxParticipantsLabel.font = .systemFont(ofSize: 13)
        maxParticipantsLabel.pinTop(to: isOnline.bottomAnchor, const: 10)
        maxParticipantsLabel.pinLeft(to: view.safeAreaLayoutGuide.leadingAnchor, const: 10)
        maxParticipantsLabel.setWidth(to: 180)
        maxParticipantsLabel.setHeight(to: 30)
        
        view.addSubview(maxParticipants)
        maxParticipants.delegate = self
        maxParticipants.pinTop(to: isOnline.bottomAnchor, const: 10)
        maxParticipants.pinLeft(to: maxParticipantsLabel.safeAreaLayoutGuide.trailingAnchor, const: 10)
        maxParticipants.setWidth(to: 150)
        maxParticipants.setHeight(to: 30)
        
        let datePickerLabel = UILabel()
        datePickerLabel.text = "Дата начала мероприятия:"
        view.addSubview(datePickerLabel)
        datePickerLabel.font = .systemFont(ofSize: 13)
        datePickerLabel.pinTop(to: maxParticipantsLabel.bottomAnchor, const: 10)
        datePickerLabel.pinLeft(to: view.safeAreaLayoutGuide.leadingAnchor, const: 10)
        datePickerLabel.setWidth(to: 180)
        datePickerLabel.setHeight(to: 30)
        
        datePicker.datePickerMode = .dateAndTime
        datePicker.addTarget(self, action: #selector(updateDateTextview), for: .valueChanged)
        startingDateTextField.inputView = datePicker
        view.addSubview(startingDateTextField)
        startingDateTextField.pinTop(to: maxParticipants.bottomAnchor, const: 10)
        startingDateTextField.pinLeft(to: datePickerLabel.safeAreaLayoutGuide.trailingAnchor, const: 10)
        startingDateTextField.setWidth(to: 150)
        startingDateTextField.setHeight(to: 30)
        
        view.addSubview(interestsVC.view)
        interestsVC.view.pinTop(to: startingDateTextField.bottomAnchor, const: 10)
        interestsVC.view.pinBottom(to: view.bottomAnchor, const: 10)
        interestsVC.view.pinRight(to: view.trailingAnchor, const: 10)
        interestsVC.view.pinLeft(to: view.leadingAnchor, const: 10)
    }
}
