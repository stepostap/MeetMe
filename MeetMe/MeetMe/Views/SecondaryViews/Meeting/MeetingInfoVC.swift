//
//  MeetingInfoVC.swift
//  MeetMe
//
//  Created by Stepan Ostapenko on 14.03.2022.
//

import UIKit

class MeetingInfoVC: UIViewController {

    var meeting: Meeting?
    
    let formatter = DateFormatter()
    let scrollView = UIScrollView()
    let mainStackView = UIStackView()
    
    let onlineSwitch = UISwitch()
    let privateSwitch = UISwitch()
    
    let participateButton = UIButton()
    
    let startingDateTextField : UITextField = {
        let textField = UITextField(frame: CGRect(x: 0, y: 0, width: 150, height: 30))
        textField.borderStyle = UITextField.BorderStyle.roundedRect
        textField.clearButtonMode = UITextField.ViewMode.whileEditing;
        textField.isUserInteractionEnabled = false
        return textField
    }()
    
    let endingDateTextField : UITextField = {
        let textField = UITextField(frame: CGRect(x: 0, y: 0, width: 150, height: 30))
        textField.borderStyle = UITextField.BorderStyle.roundedRect
        textField.clearButtonMode = UITextField.ViewMode.whileEditing;
        textField.isUserInteractionEnabled = false
        return textField
    }()
    
    let maxParticipantsTextField : UITextField = {
        let textField = UITextField(frame: CGRect(x: 0, y: 0, width: 60, height: 30))
        textField.textAlignment = .left
        textField.keyboardType = UIKeyboardType.numberPad
        textField.isUserInteractionEnabled = false
        return textField
    }()
    
    let currentParticipantsTextField : UITextField = {
        let textField = UITextField(frame: CGRect(x: 0, y: 0, width: 60, height: 30))
        textField.textAlignment = .left
        textField.isUserInteractionEnabled = false
        return textField
    }()
    
    let nameTextField : UITextField = {
        let textField = UITextField(frame: CGRect(x: 0, y: 0, width: 300, height: 30))
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
        textView.isUserInteractionEnabled = false
        return textView
    }()
    
    let interestsTextView : UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 15)
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.systemGray.cgColor
        textView.layer.cornerRadius = 5
        textView.isUserInteractionEnabled = false
        return textView
    }()
    
    let meetingImage : UIImageView = {
        let image = UIImageView(frame: .zero)
        image.contentMode = .scaleAspectFit
        image.layer.borderWidth = 0
        return image
    }()
    
    let locationTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 15)
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.systemGray.cgColor
        textView.layer.cornerRadius = 5
        textView.autocorrectionType = UITextAutocorrectionType.no
        return textView
    }()
    
    let nameAndImageHeight = 280
    let onlinePrivateHeight = 100
    let infoViewHeight = 120
    let interestsViewHeight = 120
    var dateViewHeight = 100
    let locationViewHeight = 140
    var participantViewHeight = 120
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        let viewParticipantsButton = UIBarButtonItem(barButtonSystemItem: .organize, target: self, action: #selector(viewParticipants))
        navigationItem.rightBarButtonItem = viewParticipantsButton
        configView()
        setViewInfo()
        // Do any additional setup after loading the view.
    }
    
    @objc func viewParticipants() {
        let vc = ViewParticipantsVC()
        vc.meeting = meeting
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func setViewInfo() {
        if let meeting = meeting {
            var height = 0
            mainStackView.addArrangedSubview(configNameAndImageView())
            nameTextField.text = meeting.name
            height += nameAndImageHeight
            
            mainStackView.addArrangedSubview(configOnlinePrivateView())
            height += onlinePrivateHeight
            onlineSwitch.isOn = meeting.isOnline
            privateSwitch.isOn = meeting.isPrivate
            
            if !meeting.info.isEmpty {
                mainStackView.addArrangedSubview(configInfoView())
                height += infoViewHeight
                infoTextView.text = meeting.info
            }
            
            if !meeting.types.isEmpty {
                mainStackView.addArrangedSubview(configInterestsView())
                height += interestsViewHeight
                interestsTextView.text = Utilities.getInterests(interestArray: meeting.types)
            }
            
            mainStackView.addArrangedSubview(configDateView())
            height += dateViewHeight
            
            if !meeting.Location.isEmpty {
                mainStackView.addArrangedSubview(configLocationView())
                locationTextView.text = meeting.Location
                height += locationViewHeight
            }
            
            mainStackView.addArrangedSubview(configParticipantsView())
            height += participantViewHeight
            maxParticipantsTextField.text = meeting.participantsMax.description
            currentParticipantsTextField.text = meeting.currentParticipantNumber.description
            mainStackView.setHeight(to: height)
        }
    }
    
    func configView() {
        view.addSubview(scrollView)
        scrollView.addSubview(mainStackView)
        
        scrollView.isScrollEnabled = true
        scrollView.isUserInteractionEnabled = true
        scrollView.isPagingEnabled = false
        
        scrollView.pinCenter(to: view.safeAreaLayoutGuide.centerXAnchor, const: 0)
        scrollView.pinWidth(to: view.widthAnchor, mult: 1)
        scrollView.pinTop(to: view.topAnchor, const: 0)
        scrollView.pinBottom(to: view.bottomAnchor, const: 0)
        mainStackView.pin(to: scrollView)
        mainStackView.pinWidth(to: view.widthAnchor, mult: 1)
        
        mainStackView.spacing = 0
        mainStackView.axis  = NSLayoutConstraint.Axis.vertical
    }
    
    
    func configNameAndImageView() -> UIView {
        
        let view = UIView()
        view.setHeight(to: nameAndImageHeight)
        view.addSubview(meetingImage)
        meetingImage.pinTop(to: view.topAnchor, const: 10)
        meetingImage.pinCenter(to: view.safeAreaLayoutGuide.centerXAnchor, const: 0)
        meetingImage.setHeight(to: 220)
        meetingImage.setWidth(to: 220)
        meetingImage.image = UIImage(named: "placeholder")
        
        Utilities.styleTextField(nameTextField)
        view.addSubview(nameTextField)
        nameTextField.pinCenter(to: view.safeAreaLayoutGuide.centerXAnchor, const: 0)
        nameTextField.pinTop(to: meetingImage.bottomAnchor, const: 10)
        nameTextField.setWidth(to: 300)
        nameTextField.setHeight(to: 30)
       
        return view
    }
    
    
    func configOnlinePrivateView() -> UIView {
        let view = UIView()
        view.setHeight(to: onlinePrivateHeight)
        
        let onlineLabel = UILabel()
        onlineLabel.text = "Онлайн"
        view.addSubview(onlineLabel)
        onlineLabel.pinTop(to: view.topAnchor, const: 10)
        onlineLabel.pinLeft(to: view.leadingAnchor, const: 30)
        onlineLabel.setHeight(to: 30)
        onlineLabel.setWidth(to: 100)
        
        view.addSubview(onlineSwitch)
        onlineSwitch.pinCenter(to: onlineLabel.centerYAnchor, const: 0)
        onlineSwitch.pinRight(to: view.trailingAnchor, const: 30)
        onlineSwitch.isUserInteractionEnabled = false
        
        let privateLabel = UILabel()
        privateLabel.text = "Приватное"
        view.addSubview(privateLabel)
        privateLabel.pinTop(to: onlineLabel.bottomAnchor, const: 10)
        privateLabel.pinLeft(to: view.leadingAnchor, const: 30)
        privateLabel.setHeight(to: 30)
        privateLabel.setWidth(to: 100)
        
        view.addSubview(privateSwitch)
        privateSwitch.pinCenter(to: privateLabel.centerYAnchor, const: 0)
        privateSwitch.pinRight(to: view.trailingAnchor, const: 30)
        privateSwitch.isUserInteractionEnabled = false
        
        return view
    }
    
    
    func configInfoView() -> UIView {
        
        let view = UIView()
        view.setHeight(to: infoViewHeight)
        let infoLabel = UILabel()
        infoLabel.font = UIFont.boldSystemFont(ofSize: 15)
        infoLabel.textColor = .systemGray
        infoLabel.text = "О мероприятии"
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
        
       return view
    }
    
    func configInterestsView() -> UIView {
        
        let view = UIView()
        view.setHeight(to: interestsViewHeight)
        
        let interestsLabel = UILabel()
        interestsLabel.font = UIFont.boldSystemFont(ofSize: 15)
        interestsLabel.textColor = .systemGray
        interestsLabel.text = "Теги мероприятия"
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
        interestsTextView.isUserInteractionEnabled = false
        
        return view
    }

    func configDateView() -> UIView {
        let view = UIView()
        formatter.dateFormat = "dd.MM HH:mm"
        
        let datesLabel = UILabel()
        datesLabel.font = UIFont.boldSystemFont(ofSize: 15)
        datesLabel.textColor = .systemGray
        datesLabel.text = "Время проведения"
        view.addSubview(datesLabel)
        datesLabel.pinTop(to: view.topAnchor, const: 20)
        datesLabel.pinLeft(to: view.safeAreaLayoutGuide.leadingAnchor, const: 30)
        datesLabel.setWidth(to: 150)
        datesLabel.setHeight(to: 30)
        
        let startingDateLabel = UILabel()
        startingDateLabel.text = "Начало:"
        view.addSubview(startingDateLabel)
        startingDateLabel.pinTop(to: datesLabel.bottomAnchor, const: 10)
        startingDateLabel.pinLeft(to: view.leadingAnchor, const: 20)
        startingDateLabel.setHeight(to: 30)
        startingDateLabel.setWidth(to: 80)
        
        Utilities.styleTextField(startingDateTextField)

        view.addSubview(startingDateTextField)
        startingDateTextField.pinLeft(to: startingDateLabel.trailingAnchor, const: 10)
        startingDateTextField.pinCenter(to: startingDateLabel.centerYAnchor, const: 0)
        startingDateTextField.setWidth(to: 150)
        startingDateTextField.setHeight(to: 30)
        startingDateTextField.text = formatter.string(from: meeting!.startingDate)
       
        if let endingDate = meeting?.endingDate {
            let endingDateLabel = UILabel()
            endingDateLabel.text = "Конец:"
            view.addSubview(endingDateLabel)
            endingDateLabel.pinTop(to: startingDateLabel.bottomAnchor, const: 10)
            endingDateLabel.pinLeft(to: view.leadingAnchor, const: 20)
            endingDateLabel.setHeight(to: 30)
            endingDateLabel.setWidth(to: 80)
            
            Utilities.styleTextField(endingDateTextField)
            
            view.addSubview(endingDateTextField)
            endingDateTextField.pinLeft(to: endingDateLabel.trailingAnchor, const: 10)
            endingDateTextField.pinCenter(to: endingDateLabel.centerYAnchor, const: 0)
            endingDateTextField.setWidth(to: 150)
            endingDateTextField.setHeight(to: 30)
            endingDateTextField.text = formatter.string(from: endingDate)
            
            dateViewHeight += 60
        }
        
        view.setHeight(to: dateViewHeight)
        return view
    }
    
    func configLocationView() -> UIView {
        let view = UIView()
        
        let locationLabel = UILabel()
        view.addSubview(locationLabel)
        locationLabel.text = "Место проведения"
        locationLabel.font = UIFont.boldSystemFont(ofSize: 15)
        locationLabel.textColor = .systemGray
        locationLabel.pinTop(to: view.topAnchor, const: 0)
        locationLabel.pinLeft(to: view.leadingAnchor, const: 30)
        locationLabel.setWidth(to: 150)
        locationLabel.setHeight(to: 30)
        
        view.addSubview(locationTextView)
        locationTextView.pinTop(to: locationLabel.bottomAnchor, const: 0)
        locationTextView.pinLeft(to: view.leadingAnchor, const: 20)
        locationTextView.pinRight(to: view.trailingAnchor, const: 20)
        locationTextView.setHeight(to: 100)
        
        return view
    }
    
    func configParticipantsView() -> UIView {
        
        let view = UIView()
        
        
        let participantsLabel = UILabel()
        participantsLabel.font = UIFont.boldSystemFont(ofSize: 15)
        participantsLabel.textColor = .systemGray
        participantsLabel.text = "Участники"
        view.addSubview(participantsLabel)
        participantsLabel.pinTop(to: view.topAnchor, const: 10)
        participantsLabel.pinLeft(to: view.safeAreaLayoutGuide.leadingAnchor, const: 30)
        participantsLabel.setWidth(to: 150)
        participantsLabel.setHeight(to: 30)
        
        let maxPartaicipantsLabel = UILabel()
        maxPartaicipantsLabel.text = "Макс. участников:"
        view.addSubview(maxPartaicipantsLabel)
        maxPartaicipantsLabel.pinTop(to: participantsLabel.bottomAnchor, const: 0)
        maxPartaicipantsLabel.pinLeft(to: view.leadingAnchor, const: 20)
        maxPartaicipantsLabel.setHeight(to: 30)
        maxPartaicipantsLabel.setWidth(to: 180)
        
        Utilities.styleTextField(maxParticipantsTextField)
        view.addSubview(maxParticipantsTextField)
        maxParticipantsTextField.pinCenter(to: maxPartaicipantsLabel.centerYAnchor, const: 0)
        maxParticipantsTextField.pinLeft(to: maxPartaicipantsLabel.trailingAnchor, const: 0)
        maxParticipantsTextField.setWidth(to: 60)
        maxParticipantsTextField.setHeight(to: 30)
        maxParticipantsTextField.text = meeting?.participantsMax.description
       
        let currentPartaicipantsLabel = UILabel()
        currentPartaicipantsLabel.text = "Текущее кол-во:"
        view.addSubview(currentPartaicipantsLabel)
        currentPartaicipantsLabel.pinTop(to: maxPartaicipantsLabel.bottomAnchor, const: 10)
        currentPartaicipantsLabel.pinLeft(to: view.leadingAnchor, const: 20)
        currentPartaicipantsLabel.setHeight(to: 30)
        currentPartaicipantsLabel.setWidth(to: 180)
        
        Utilities.styleTextField(currentParticipantsTextField)
        view.addSubview(currentParticipantsTextField)
        currentParticipantsTextField.pinCenter(to: currentPartaicipantsLabel.centerYAnchor, const: 0)
        currentParticipantsTextField.pinLeft(to: currentPartaicipantsLabel.trailingAnchor, const: 0)
        currentParticipantsTextField.setWidth(to: 60)
        currentParticipantsTextField.setHeight(to: 30)
        currentParticipantsTextField.text = meeting?.currentParticipantNumber.description
        
        if !meeting!.participantsID.contains(User.currentUser.account!.id) {
            view.addSubview(participateButton)
            Utilities.styleFilledButton(participateButton)
            participateButton.pinTop(to: currentParticipantsTextField.bottomAnchor, const: 20)
            participateButton.addTarget(self, action: #selector(participate), for: .touchUpInside)
            participateButton.pinLeft(to: view.leadingAnchor, const: 20)
            participateButton.pinRight(to: view.trailingAnchor, const: 20)
            participateButton.setTitle("Участвовать", for: .normal)
            participateButton.setHeight(to: 30)
            participantViewHeight += 60
        }
        
        view.setHeight(to: participantViewHeight)
        
        return view
    }

    @objc func participate() {
        
        MeetingRequests.shared.participateInMeeting(accept: true, meetingID: meeting!.id, completion: {(error) in
            if let error = error {
                let alert = ErrorChecker.handler.getAlertController(error: error)
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            self.meeting?.participantsID.append(User.currentUser.account!.id)
            if User.currentUser.meetingInvitations!.personalInvitations.contains(self.meeting!) {
                let index = User.currentUser.meetingInvitations!.personalInvitations.firstIndex(of: self.meeting!)
                User.currentUser.meetingInvitations!.personalInvitations.remove(at: index!)
                User.currentUser.plannedMeetings?.append(self.meeting!)
            }
            self.navigationController?.popViewController(animated: true)
        })
    }
    
}
