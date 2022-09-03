//
//  SearchFilterVC.swift
//  MeetMe
//
//  Created by Stepan Ostapenko on 03.03.2022.
//

import UIKit

/// Контроллер, отвечающий за создание фильтра для поиска мероприятий
class SearchFilterVC: UIViewController, UITextFieldDelegate {
    /// Форматер даты
    private let formatter = DateFormatter()
    /// Фильтр для поиска мероприятий
    var searchOptions: MeetingSearchFilter?
    /// Поле для ввода максимального числа участников
    private var maxParticipants : UITextField = {
        let textField = UITextField()
        textField.keyboardType = UIKeyboardType.default
        textField.returnKeyType = UIReturnKeyType.done
        textField.autocorrectionType = UITextAutocorrectionType.no
        textField.borderStyle = UITextField.BorderStyle.roundedRect
        textField.clearButtonMode = UITextField.ViewMode.whileEditing;
        //textField.backgroundColor = UIColor(named: "BackgroundMain")
        return textField
    }()
    /// Чекбоксы для выбора интересов, которые должны быть у найденных мероприятий
    private var meetingTypeCheckboxes = [CheckBox]()
    /// Интересы, которые должны быть у найденных мероприятий
    private let interestsVC = InterestsVC()
    /// Проводится ли мероприятие онлайн
    private let isOnline = CheckBox.init()
    /// Выбор даты
    private let datePicker = UIDatePicker()
    /// Поле для отображения даты начала мероприятия
    private let startingDateTextField : UITextField = {
        let textField = UITextField()
        textField.borderStyle = UITextField.BorderStyle.roundedRect
        textField.clearButtonMode = UITextField.ViewMode.whileEditing;
        return textField
    }()
    /// Поле для отображения даты конца мероприятия
    private let endingDateTextField : UITextField = {
        let textField = UITextField()
        textField.borderStyle = UITextField.BorderStyle.roundedRect
        textField.clearButtonMode = UITextField.ViewMode.whileEditing;
        return textField
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "BackgroundDarker")
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
        if let date = searchOptions?.endingDate {
            endingDateTextField.text = formatter.string(from: date)
        }
    
        configureView()
    }
    
    
    /// Метод для синхронизации значения чекбокса и поля isOnline
    @objc private func isOnlineCheckboxSync() {
        if isOnline.isChecked {
            searchOptions?.online = true
        } else {
            searchOptions?.online = false
        }
        
    }
    
    /// Очистка введенных настроек
    @objc private func clearOptions() {
        searchOptions?.types = []
        maxParticipants.text = "100"
        searchOptions?.participantsMax = 100
        isOnline.isChecked = false
        startingDateTextField.text = ""
        searchOptions?.startingDate = nil
    }
    
    /// Отображение в текстовых полях выбранной даты
    @objc private func updateDateTextview() {
        if startingDateTextField.isEditing {
            //formatter.dateFormat = "dd.MM HH:mm"
            startingDateTextField.text = formatter.string(from: datePicker.date)
            searchOptions?.startingDate = datePicker.date
        }
        if endingDateTextField.isEditing {
            //formatter.dateFormat = "dd.MM HH:mm"
            endingDateTextField.text = formatter.string(from: datePicker.date)
            searchOptions?.endingDate = datePicker.date
        }
    }
    
    // MARK: Text Delegates
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
   
    // MARK: Configs
    /// Формирование экрана фильтра поиска
    private func configureView() {
        
        let clearButton = UIButton(type: .system)
        clearButton.setTitle("Очистить", for: .normal)
        clearButton.titleLabel?.font = .systemFont(ofSize: 15)
        clearButton.addTarget(self, action: #selector(clearOptions), for: .touchUpInside)
        view.addSubview(clearButton)
        clearButton.pinTop(to: view.safeAreaLayoutGuide.topAnchor, const: 10)
        clearButton.pinRight(to: view.safeAreaLayoutGuide.trailingAnchor, const: 10)
        clearButton.setWidth(to: 100)
        clearButton.setHeight(to: 30)
        
        //isOnline.style = .tick
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
        
        let endinfDatePickerLabel = UILabel()
        endinfDatePickerLabel.text = "Дата конца мероприятия:"
        view.addSubview(endinfDatePickerLabel)
        endinfDatePickerLabel.font = .systemFont(ofSize: 13)
        endinfDatePickerLabel.pinTop(to: datePickerLabel.bottomAnchor, const: 10)
        endinfDatePickerLabel.pinLeft(to: view.safeAreaLayoutGuide.leadingAnchor, const: 10)
        endinfDatePickerLabel.setWidth(to: 180)
        endinfDatePickerLabel.setHeight(to: 30)
        
        endingDateTextField.inputView = datePicker
        view.addSubview(endingDateTextField)
        endingDateTextField.pinTop(to: startingDateTextField.bottomAnchor, const: 10)
        endingDateTextField.pinLeft(to: endinfDatePickerLabel.safeAreaLayoutGuide.trailingAnchor, const: 10)
        endingDateTextField.setWidth(to: 150)
        endingDateTextField.setHeight(to: 30)
        
        view.addSubview(interestsVC.view)
        interestsVC.view.pinTop(to: endingDateTextField.bottomAnchor, const: 10)
        interestsVC.view.pinBottom(to: view.bottomAnchor, const: 10)
        interestsVC.view.pinRight(to: view.trailingAnchor, const: 10)
        interestsVC.view.pinLeft(to: view.leadingAnchor, const: 10)
    }
}
