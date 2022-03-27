//
//  ExtendedMeetingCell.swift
//  MeetMe
//
//  Created by Stepan Ostapenko on 23.03.2022.
//

import UIKit

class ExtendedMeetingCell: UITableViewCell {

    var meeting: Meeting? {
        didSet {
            meetingName.text = meeting?.name
            dateLabel.text = meeting?.getDate()
            interestsTextView.text = Utilities.getInterests(interestArray: meeting?.types ?? [])
            if meeting!.imageURL.isEmpty {
                meetingImage.image = UIImage(named: "placeholder")
            }
            participantsLabel.text = "Участников: \(meeting!.currentParticipantNumber)/\(meeting!.participantsMax)"
            locationTextView.text = meeting?.Location
            setCostraints()
        }
    }
    
    let meetingName : UILabel = {
        let label = UILabel()
        //label.setHeight(to: 20)
        label.font = .boldSystemFont(ofSize: 16)
        return label
    }()
    
    let meetingImage: UIImageView = {
        let image = UIImageView(frame: .zero)
        image.contentMode = .scaleAspectFit
        image.layer.borderWidth = 0
        return image
    }()
    
    let dateLabel : UILabel = {
        let label = UILabel()
        //label.setHeight(to: 20)
        label.font = .systemFont(ofSize: 15)
        return label
    }()
    
    let locationTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 15)
        textView.autocorrectionType = UITextAutocorrectionType.no
        textView.isUserInteractionEnabled = false
        textView.isScrollEnabled = false
        return textView
    }()
    
    let interestsTextView : UITextView = {
        let textView = UITextView()
        //label.setHeight(to: 20)
        textView.font = .boldSystemFont(ofSize: 15)
        textView.isUserInteractionEnabled = false
        textView.isScrollEnabled = false
        return textView
    }()

    let participantsLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        //setCostraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
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
        
        
        //contentView.setHeight(to: 170 + interestsHeight + locationHeight)
        //locationTextView.setHeight(to: 60)
        
    }
}
