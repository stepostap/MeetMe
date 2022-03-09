//
//  MeetingCell.swift
//  MeetMe
//
//  Created by Stepan Ostapenko on 03.03.2022.
//

import UIKit

class MeetingCell: UITableViewCell {
    
    var meeting: Meeting? {
        didSet {
            meetingName.text = meeting?.name
            if let imageData = meeting?.image {
                meetingImage.image = UIImage(data: imageData)
            } else {
                meetingImage.image = UIImage(named: "placeholder")
            }
            dateLabel.text = meeting?.getDate()
            interestsLabel.text = meeting?.getInterests()
        }
    }
    
    let labelStack = UIStackView()
    
    var meetingName : UILabel = {
        let label = UILabel()
        //label.setHeight(to: 20)
        label.font = .systemFont(ofSize: 15)
        return label
    }()
    
    var meetingImage: UIImageView = {
        let image = UIImageView(frame: .zero)
        image.contentMode = .scaleAspectFit
        image.layer.borderWidth = 0
        return image
    }()
    
    var dateLabel : UILabel = {
        let label = UILabel()
        //label.setHeight(to: 20)
        label.font = .systemFont(ofSize: 15)
        return label
    }()
    
    var interestsLabel : UILabel = {
        let label = UILabel()
        //label.setHeight(to: 20)
        label.font = .systemFont(ofSize: 15)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setCostraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setCostraints() {
        contentView.setHeight(to: 200)
        contentView.addSubview(meetingImage)
        meetingImage.setConstraints(to: contentView, left: 10, top: 10, width: 150, height: 150)
        
        labelStack.addArrangedSubview(meetingName)
        labelStack.addArrangedSubview(dateLabel)
        labelStack.addArrangedSubview(interestsLabel)
        labelStack.axis = NSLayoutConstraint.Axis.vertical
        labelStack.alignment = UIStackView.Alignment.leading
        labelStack.spacing = 10
        
        contentView.addSubview(labelStack)
        labelStack.pinLeft(to: meetingImage.trailingAnchor, const: 10)
        labelStack.pinTop(to: contentView.topAnchor, const: 10)
        labelStack.pinBottom(to: contentView.bottomAnchor, const: 10)
        labelStack.pinRight(to: contentView.trailingAnchor, const: 10)
        
    }

}
