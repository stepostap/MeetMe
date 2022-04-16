//
//  ExtendedMeetingCell.swift
//  MeetMe
//
//  Created by Stepan Ostapenko on 23.03.2022.
//

import UIKit

/// Ячейка с подробной информацией о мероприятии
class ExtendedMeetingCell: UITableViewCell {
    /// Мероприятие, информацию о котором отображает ячейка
    var meeting: Meeting? {
        didSet {
            meetingName.text = meeting?.name
            dateLabel.text = meeting?.getDate()
            interestsTextView.text = Styling.getInterests(interestArray: meeting?.types ?? [])
            if meeting!.imageURL.isEmpty {
                meetingImage.image = UIImage(named: "placeholder")
            } else {
                let url = URL(string: meeting!.imageURL)
                meetingImage.kf.indicatorType = .activity
                meetingImage.kf.setImage(with: url, options: [ .cacheOriginalImage ])
            }
            participantsLabel.text = "Участников: \(meeting!.currentParticipantNumber)/\(meeting!.participantsMax)"
            locationTextView.text = meeting?.Location
            setCostraints()
        }
    }
    /// Текстовое поле с названием мероприятия
    let meetingName : UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 16)
        return label
    }()
    /// UI элемент,  отображающий картинку мероприятия
    let meetingImage: UIImageView = {
        let image = UIImageView(frame: .zero)
        image.contentMode = .scaleAspectFit
        image.layer.borderWidth = 0
        return image
    }()
    /// Текстовое поле с датой проведения мероприятия
    let dateLabel : UILabel = {
        let label = UILabel()
        //label.setHeight(to: 20)
        label.font = .systemFont(ofSize: 15)
        return label
    }()
    /// Текстовое поле с местом проведения мероприятия
    let locationTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 15)
        textView.autocorrectionType = UITextAutocorrectionType.no
        textView.isUserInteractionEnabled = false
        textView.isScrollEnabled = false
        return textView
    }()
    /// Текстовое поле с интересами мероприятия
    let interestsTextView : UITextView = {
        let textView = UITextView()
        textView.font = .boldSystemFont(ofSize: 15)
        textView.isUserInteractionEnabled = false
        textView.isScrollEnabled = false
        return textView
    }()
    /// Текстовое поле с число участников
    let participantsLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        //setCostraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    /// Метод, формирующий внешний вид ячейки
    private func setCostraints() {
        
        contentView.addSubview(meetingImage)
        meetingImage.setConstraints(to: contentView, left: 10, top: 10, width: 100, height: 100)
        
        contentView.addSubview(meetingName)
        meetingName.pinTop(to: contentView.topAnchor, const: 5)
        meetingName.pinLeft(to: meetingImage.trailingAnchor, const: 10)
        meetingName.pinRight(to: contentView.trailingAnchor, const: 10)
        meetingName.setHeight(to: 20)
        
        contentView.addSubview(dateLabel)
        dateLabel.pinTop(to: meetingName.bottomAnchor, const: 5)
        dateLabel.pinLeft(to: meetingImage.trailingAnchor, const: 10)
        dateLabel.pinRight(to: contentView.trailingAnchor, const: 10)
        dateLabel.setHeight(to: 20)
        
        contentView.addSubview(participantsLabel)
        participantsLabel.pinTop(to: dateLabel.bottomAnchor, const: 5)
        participantsLabel.pinLeft(to: meetingImage.trailingAnchor, const: 10)
        participantsLabel.pinRight(to: contentView.trailingAnchor, const: 10)
        participantsLabel.setHeight(to: 20)
        
        contentView.addSubview(interestsTextView)
        interestsTextView.pinTop(to: meetingImage.bottomAnchor, const: 5)
        interestsTextView.pinLeft(to: contentView.leadingAnchor, const: 10)
        interestsTextView.pinRight(to: contentView.trailingAnchor, const: 10)
        
        
        contentView.addSubview(locationTextView)
        locationTextView.pinTop(to: interestsTextView.bottomAnchor, const: 5)
        locationTextView.pinLeft(to: contentView.leadingAnchor, const: 10)
        locationTextView.pinRight(to: contentView.trailingAnchor, const: 10)
    }
}
