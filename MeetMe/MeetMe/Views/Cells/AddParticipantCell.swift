//
//  AddParticipantCell.swift
//  MeetMe
//
//  Created by Stepan Ostapenko on 21.03.2022.
//

import UIKit

class AddParticipantCell: UITableViewCell {

    var participantID: Int64?
    let nameLabel = UILabel()
    var checkboxChanged: ((_ checked: Bool, _ id: Int64) -> (Void))?
    
    let participantImage: UIImageView = {
        let image = UIImageView(frame: .zero)
        image.contentMode = .scaleAspectFit
        image.layer.borderWidth = 0
        return image
    }()
    
    let checkbox = CheckBox()
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(false, animated: false)
        if selected {
            if checkbox.isChecked {
                checkbox.isChecked = false
            } else {
                checkbox.isChecked = true
            }
            if let checkboxChanged = checkboxChanged {
                checkboxChanged(checkbox.isChecked, participantID!)
            }
        }
        
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setCostraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    private func setCostraints() {
        
        contentView.setHeight(to: 50)
        contentView.addSubview(participantImage)
        participantImage.setConstraints(to: contentView, left: 20, top: 5, width: 45, height: 45)
        participantImage.image = UIImage(named:"placeholder")
        
        contentView.addSubview(nameLabel)
        nameLabel.pinLeft(to: participantImage.trailingAnchor, const: 10)
        nameLabel.pinCenter(to: contentView.centerYAnchor, const: 0)
        nameLabel.setWidth(to: 250)
        
        contentView.addSubview(checkbox)
        checkbox.style = .tick
        checkbox.borderStyle = .roundedSquare(radius: 5)
        checkbox.isChecked = false
        checkbox.isUserInteractionEnabled = false
        checkbox.pinLeft(to: nameLabel.trailingAnchor, const: 10)
        checkbox.pinCenter(to: contentView.centerYAnchor, const: 0)
        checkbox.setWidth(to: 30)
        checkbox.setHeight(to: 30)
    }

}
