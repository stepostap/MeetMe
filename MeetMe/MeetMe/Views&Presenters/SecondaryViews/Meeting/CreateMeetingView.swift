//
//  CreateMeetingView.swift
//  MeetMe
//
//  Created by Stepan Ostapenko on 02.09.2022.
//

import UIKit

class CreateMeetingView: UIView, UITextFieldDelegate, UITextViewDelegate {
    /// Мероприятие, которое пользователь редактирует
    var meeting: Meeting?
    /// Список интересов мероприятия
    var interests = [Interests]()
    private let formatter = DateFormatter()
    /// Прокручиваемая область с информацией о мерпориятии
    private let scrollView = UIScrollView()
    /// Область с информацией о мероприятии
    private let mainView = UIView()
    /// Кнопка для выбора изображения мероприятия
    let chooseImageButton = UIButton(type: .system)
    /// Кнопка для редактирования интересов мероприятия
    let editInterestsButton = UIButton(type: .system)
    /// Кнопка для выбора друзей и групп, которые будут приглашены на мероприятие
    let addFriendsButton = UIButton()
    /// Элемент для настройки онлайн/оффлайн значения мероприятия
    let onlineSwitch = UISwitch()
    /// Элемент для настройки приватное/публичное значения мероприятия
    let privateSwitch = UISwitch()
    /// Выбор даты
    let datePicker1 = UIDatePicker()
    let datePicker2 = UIDatePicker()
    /// Текстовое поле для отображения/ввода даты начала мероприятия
    let startingDateTextField : UITextField = {
        let textField = UITextField(frame: CGRect(x: 0, y: 0, width: 150, height: 30))
        textField.borderStyle = UITextField.BorderStyle.roundedRect
        textField.clearButtonMode = UITextField.ViewMode.whileEditing;
        return textField
    }()
    /// Текстовое поле для отображения/ввода даты концы мероприятия
    let endingDateTextField : UITextField = {
        let textField = UITextField(frame: CGRect(x: 0, y: 0, width: 150, height: 30))
        textField.borderStyle = UITextField.BorderStyle.roundedRect
        textField.clearButtonMode = UITextField.ViewMode.whileEditing;
        return textField
    }()
    /// Текстовое поле для отображения/ввода максимального числа участников мероприятия
    let maxParticipantsTextField : UITextField = {
        let textField = UITextField(frame: CGRect(x: 0, y: 0, width: 60, height: 30))
        textField.textAlignment = .left
        textField.keyboardType = UIKeyboardType.numberPad
        return textField
    }()
    /// Текстовове поля для отображения/вввода названия мероприятия
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
    /// Текстовое поле для отображения/ввода информации о мероприятии
    let infoTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 15)
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.systemGray.cgColor
        textView.layer.cornerRadius = 5
        textView.autocorrectionType = UITextAutocorrectionType.no
        textView.backgroundColor = UIColor(named: "BackgroundDarker")
        return textView
    }()
    /// Текстовое поля для отображения списка интересов пользователя
    let interestsTextView : UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 15)
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.systemGray.cgColor
        textView.layer.cornerRadius = 5
        textView.autocorrectionType = UITextAutocorrectionType.no
        textView.backgroundColor = UIColor(named: "BackgroundDarker")
        return textView
    }()
    /// UI элемент для отображения изображения мероприятия
    let meetingImage : UIImageView = {
        let image = UIImageView(frame: .zero)
        image.contentMode = .scaleAspectFit
        image.layer.borderWidth = 0
        Styling.styleImageView1(image)
        return image
    }()
    /// Текстовое поле для отображения места проведения мероприятия
    let locationTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 15)
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.systemGray.cgColor
        textView.layer.cornerRadius = 5
        textView.autocorrectionType = UITextAutocorrectionType.no
        textView.backgroundColor = UIColor(named: "BackgroundDarker")
        return textView
    }()
    
    init(meeting: Meeting?) {
        super.init(frame: .zero)
        self.meeting = meeting
        self.backgroundColor = UIColor(named: "BackgroundMain")
        configView()
        showMeetingInfo()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Метод для отображения информации о мероприятии
    private func showMeetingInfo() {
        formatter.dateFormat = "dd.MM HH:mm"
        if let meeting = meeting {
            nameTextField.text = meeting.name
            onlineSwitch.isOn = meeting.isOnline
            privateSwitch.isOn = meeting.isPrivate
            infoTextView.text = meeting.info
            interestsTextView.text = Styling.getInterests(interestArray: meeting.types)
            print(formatter.string(from: meeting.startingDate))
            startingDateTextField.text = formatter.string(from: meeting.startingDate)
            if let endingDate = meeting.endingDate {
                endingDateTextField.text = formatter.string(from: endingDate)
                datePicker2.date = endingDate
            }
            interests = meeting.types
            maxParticipantsTextField.text = meeting.participantsMax.description
            datePicker1.date = meeting.startingDate
            if !meeting.imageURL.isEmpty {
                meetingImage.kf.setImage(with: URL(string: meeting.imageURL))
            } else {
                meetingImage.image = UIImage(named: "placeholder")
            }
            
        }
    }
    
    @objc func updateStartingDateTextview() {
        formatter.dateFormat = "dd.MM HH:mm"
        startingDateTextField.text = formatter.string(from: datePicker1.date)
    }
    
    @objc func updateEndingDateTextview() {
        formatter.dateFormat = "dd.MM HH:mm"
        endingDateTextField.text = formatter.string(from: datePicker2.date)
    }
    
    @objc func datepickerDone() {
        endEditing(true)
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
    
    // MARK: Configs
    /// Формирование экрана
    private func configView() {
        addSubview(scrollView)
        scrollView.addSubview(mainView)
        
        scrollView.isScrollEnabled = true
        scrollView.isUserInteractionEnabled = true
        scrollView.isPagingEnabled = false
        
        scrollView.pinCenter(to: safeAreaLayoutGuide.centerXAnchor, const: 0)
        scrollView.pinWidth(to: widthAnchor, mult: 1)
        scrollView.pinTop(to: topAnchor, const: 0)
        scrollView.pinBottom(to: bottomAnchor, const: 0)
        mainView.pin(to: scrollView)
        mainView.pinWidth(to: widthAnchor, mult: 1)
        //mainView.pinHeight(to: view.heightAnchor, mult: 1)
        mainView.setHeight(to: 1050)
        
        configNameAndImageView()
        configOnlinePrivateView()
        configInfoAndInterestsView()
        configDateView()
        configLocationView()
        configParticipantsView()
    }
    
    /// Формирование части экрана, отображающей название и картинку мероприятия
    private func configNameAndImageView() {
        chooseImageButton.setTitle("Выбрать изображение", for: .normal)
        // 
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
        
        Styling.styleTextField(nameTextField)
        mainView.addSubview(nameTextField)
        nameTextField.pinCenter(to: mainView.safeAreaLayoutGuide.centerXAnchor, const: 0)
        nameTextField.pinTop(to: meetingImage.bottomAnchor, const: 10)
        nameTextField.setWidth(to: 300)
        nameTextField.setHeight(to: 30)
        nameTextField.placeholder = "Название мероприятия"
        nameTextField.delegate = self
    }
    
    /// Формирование части экрана, отображающей onlineSwitch и privateSwitch
    private func configOnlinePrivateView() {
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
    
    /// Формирование части экрана, отображающей информацию и интересы мероприятия
    private func configInfoAndInterestsView() {
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
        // 
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
        // 
        mainView.addSubview(chooseImageButton)
        chooseImageButton.pinTop(to: mainView.safeAreaLayoutGuide.topAnchor, const: 0)
        chooseImageButton.pinCenter(to: mainView.safeAreaLayoutGuide.centerXAnchor, const: 0)
        chooseImageButton.setWidth(to: 200)
    }

    /// Формирование части экрана, отображающей даты проведения мероприятия
    private func configDateView() {
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
        
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let doneBtn = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(datepickerDone))
        toolBar.setItems([doneBtn], animated: true)
        
        Styling.styleTextField(startingDateTextField)
        datePicker1.datePickerMode = .dateAndTime
        datePicker1.addTarget(self, action: #selector(updateStartingDateTextview), for: .valueChanged)
        mainView.addSubview(startingDateTextField)
        startingDateTextField.pinLeft(to: startingDateLabel.trailingAnchor, const: 10)
        startingDateTextField.pinCenter(to: startingDateLabel.centerYAnchor, const: 0)
        startingDateTextField.setWidth(to: 150)
        startingDateTextField.setHeight(to: 30)
        datePicker1.preferredDatePickerStyle = .wheels
        startingDateTextField.inputView = datePicker1
        startingDateTextField.inputAccessoryView = toolBar
        startingDateTextField.delegate = self
        
        let endingDateLabel = UILabel()
        endingDateLabel.text = "Конец:"
        mainView.addSubview(endingDateLabel)
        endingDateLabel.pinTop(to: startingDateLabel.bottomAnchor, const: 10)
        endingDateLabel.pinLeft(to: mainView.leadingAnchor, const: 20)
        endingDateLabel.setHeight(to: 30)
        endingDateLabel.setWidth(to: 80)
        
        Styling.styleTextField(endingDateTextField)
        datePicker2.datePickerMode = .dateAndTime
        datePicker2.preferredDatePickerStyle = .wheels
        datePicker2.addTarget(self, action: #selector(updateEndingDateTextview), for: .valueChanged)
        mainView.addSubview(endingDateTextField)
        endingDateTextField.pinLeft(to: endingDateLabel.trailingAnchor, const: 10)
        endingDateTextField.pinCenter(to: endingDateLabel.centerYAnchor, const: 0)
        endingDateTextField.setWidth(to: 150)
        endingDateTextField.setHeight(to: 30)
        endingDateTextField.inputAccessoryView = toolBar
        endingDateTextField.inputView = datePicker2
        endingDateTextField.delegate = self
    }
    
    /// Формирование части экрана, отображающей место проведения мероприятия
    private func configLocationView() {
        let locationLabel = UILabel()
        addSubview(locationLabel)
        locationLabel.text = "Место проведения"
        locationLabel.font = UIFont.boldSystemFont(ofSize: 15)
        locationLabel.textColor = .systemGray
        locationLabel.pinTop(to: endingDateTextField.bottomAnchor, const: 20)
        locationLabel.pinLeft(to: mainView.leadingAnchor, const: 30)
        locationLabel.setWidth(to: 150)
        locationLabel.setHeight(to: 30)
        
        addSubview(locationTextView)
        locationTextView.pinTop(to: locationLabel.bottomAnchor, const: 0)
        locationTextView.pinLeft(to: mainView.leadingAnchor, const: 20)
        locationTextView.pinRight(to: mainView.trailingAnchor, const: 20)
        locationTextView.setHeight(to: 100)
        locationTextView.delegate = self
    }
    
    /// Формирование части экрана, отображающей информацию о числе участников мероприятия
    private func configParticipantsView() {
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
        
        Styling.styleTextField(maxParticipantsTextField)
        mainView.addSubview(maxParticipantsTextField)
        maxParticipantsTextField.pinCenter(to: maxPartaicipantsLabel.centerYAnchor, const: 0)
        maxParticipantsTextField.pinLeft(to: maxPartaicipantsLabel.trailingAnchor, const: 0)
        maxParticipantsTextField.setWidth(to: 60)
        maxParticipantsTextField.setHeight(to: 30)
        maxParticipantsTextField.delegate = self
        
        Styling.styleFilledButton(addFriendsButton)
        addFriendsButton.setTitle("Добавить участников", for: .normal)
        mainView.addSubview(addFriendsButton)
        addFriendsButton.pinTop(to: maxPartaicipantsLabel.bottomAnchor, const: 20)
        addFriendsButton.pinLeft(to: mainView.leadingAnchor, const: 20)
        addFriendsButton.setHeight(to: 40)
        addFriendsButton.pinRight(to: mainView.trailingAnchor, const: 20)
        // 
    }
}
