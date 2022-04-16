//
//  AddParticipantCell.swift
//  MeetMe
//
//  Created by Stepan Ostapenko on 21.03.2022.
//

import UIKit

/// Ячейка, позволяющая выбрать участника (пользователя или группу) для получения приглащения
class AddParticipantCell: UITableViewCell {
    /// Идентификатор участника
    var participantID: Int64?
    /// Имя участника
    let nameLabel = UILabel()
    /// Метод,  который вызывается при изменении значение чекбокса
    var checkboxChanged: ((_ checked: Bool, _ id: Int64) -> (Void))?
    /// Можно ли менять значение чекбокса
    var canBeSelected = true
    ///  UI элемент, отображающий картинку участника
    let participantImage: UIImageView = {
        let image = UIImageView(frame: .zero)
        image.contentMode = .scaleAspectFit
        image.layer.borderWidth = 0
        return image
    }()
    /// Чекбокс
    let checkbox = CheckBox()
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(false, animated: false)
        if selected, canBeSelected {
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
        
    /// Метод, формирующий внешний вид ячейки
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
        //checkbox.style = .tick
        checkbox.borderStyle = .roundedSquare(radius: 5)
        //checkbox.isChecked = false
        checkbox.isUserInteractionEnabled = false
        checkbox.pinLeft(to: nameLabel.trailingAnchor, const: 10)
        checkbox.pinCenter(to: contentView.centerYAnchor, const: 0)
        checkbox.setWidth(to: 30)
        checkbox.setHeight(to: 30)
    }

}
