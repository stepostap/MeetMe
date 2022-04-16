//
//  MeetingCell.swift
//  MeetMe
//
//  Created by Stepan Ostapenko on 03.03.2022.
//

import UIKit

/// Ячейка, отображающая краткую информацию о мероприятии
class MeetingCell: UITableViewCell {
    /// Мероприятие
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
                meetingImage.kf.setImage(with: url, options: [ .forceRefresh ])
            }
        }
    }
    /// Текстовое поле, содержищее название мероприятия
    var meetingName : UILabel = {
        let label = UILabel()
        //label.setHeight(to: 20)
        label.font = .boldSystemFont(ofSize: 16)
        return label
    }()
    /// UI элемент, содержащий изображение мероприятия
    var meetingImage: UIImageView = {
        let image = UIImageView(frame: .zero)
        image.contentMode = .scaleAspectFit
        image.layer.borderWidth = 0
        return image
    }()
    /// Текстовое поле, содержищее информацию о времени проведения мероприятия
    var dateLabel : UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        return label
    }()
    /// Текстовое поле, содержащее информацию об интересах мероприятия
    var interestsTextView : UITextView = {
        let textView = UITextView()
        //label.setHeight(to: 20)
        textView.font = .systemFont(ofSize: 15)
        textView.isUserInteractionEnabled = false
        return textView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setCostraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Метод, формирующий внешний вид ячейки
    private func setCostraints() {
        
        contentView.addSubview(meetingImage)
        meetingImage.setConstraints(to: contentView, left: 10, top: 10, width: 150, height: 150)
        
        contentView.addSubview(meetingName)
        meetingName.pinTop(to: contentView.topAnchor, const: 10)
        meetingName.pinLeft(to: meetingImage.trailingAnchor, const: 10)
        meetingName.pinRight(to: contentView.trailingAnchor, const: 10)
        meetingName.setHeight(to: 20)
        
        contentView.addSubview(dateLabel)
        dateLabel.pinTop(to: meetingName.bottomAnchor, const: 10)
        dateLabel.pinLeft(to: meetingImage.trailingAnchor, const: 10)
        dateLabel.pinRight(to: contentView.trailingAnchor, const: 10)
        dateLabel.setHeight(to: 20)
        
        contentView.addSubview(interestsTextView)
        interestsTextView.pinTop(to: dateLabel.bottomAnchor, const: 10)
        interestsTextView.pinLeft(to: meetingImage.trailingAnchor, const: 10)
        interestsTextView.pinRight(to: contentView.trailingAnchor, const: 10)
        interestsTextView.setHeight(to: 80)
        
    }

}
