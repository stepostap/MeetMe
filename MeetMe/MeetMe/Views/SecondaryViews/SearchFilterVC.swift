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
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        createCheckboxArray()
        for checkbox in meetingTypeCheckboxes {
            checkbox.isChecked = searchOptions?.types.contains(Interests.allCases[checkbox.index]) ?? false
        }
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
    
    func createCheckboxStackview() -> UIStackView {
        let checkboxStack = UIStackView()
        checkboxStack.axis = NSLayoutConstraint.Axis.vertical
        checkboxStack.alignment = UIStackView.Alignment.leading
        checkboxStack.spacing = 10
        
        for checkbox in meetingTypeCheckboxes {
            checkboxStack.addArrangedSubview(createCheckboxWithLabel(checkbox: checkbox,
                                                                     text: Interests.allCases[checkbox.index].rawValue))
        }
        
        return checkboxStack
    }
    
    func createCheckboxArray(){
        var i = 0
        for _ in Interests.allCases {
            let checkbox = CheckBox.init()
            checkbox.style = .tick
            checkbox.borderStyle = .roundedSquare(radius: 5)
            checkbox.index = i
            checkbox.addTarget(self, action: #selector(syncCheckbox(_:)), for: .valueChanged)
            i += 1
            meetingTypeCheckboxes.append(checkbox)
        }
    }
    
    @objc func syncCheckbox(_ sender: CheckBox)  {
        let type = Interests.allCases[sender.index]
        if sender.isChecked {
            searchOptions?.types.append(type)
        } else {
            if let index = searchOptions?.types.firstIndex(of: type){
                searchOptions?.types.remove(at: index)
            }
        }
    }
    
    
    func createCheckboxWithLabel(checkbox: CheckBox, text: String) -> UIView {
        let container = UIView()
        container.setHeight(to: 30)
        container.setWidth(to: 200)
        
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 15)
        
        container.addSubview(checkbox)
        container.addSubview(label)
        
        checkbox.setConstraints(to: container, left: 5, top: 5, width: 30, height: 30)
        label.pinLeft(to: checkbox.trailingAnchor, const: 10)
        label.pinTop(to: container.topAnchor, const: 10)
        
        return container
    }
    
    @objc func updateDateTextview() {
        formatter.dateFormat = "dd.MM HH:mm"
        startingDateTextField.text = formatter.string(from: datePicker.date)
        searchOptions?.startingDate = datePicker.date
        
    }
    
    @objc func clearOptions() {
        for checkbox in meetingTypeCheckboxes {
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
        
        let stack = createCheckboxStackview()
        view.addSubview(stack)
        stack.pinTop(to: startingDateTextField.bottomAnchor, const: 10)
        stack.pinLeft(to: view.safeAreaLayoutGuide.leadingAnchor, const: 10)
        stack.setWidth(to: 200)
        //stack.setHeight(to: 300)
        
    }
}
