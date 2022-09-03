//
//  AddParticipantCell.swift
//  MeetMe
//
//  Created by Stepan Ostapenko on 21.03.2022.
//

import UIKit

/// Ячейка, позволяющая выбрать участника (пользователя или группу) для получения приглащения
class InterestCell: UITableViewCell {
    var interest: Interests! {
        didSet {
            interestLabel.text = interest.rawValue
        }
    }
    let interestLabel = UILabel()
    /// Чекбокс
    let checkbox = CheckBox()
    var checkboxChanged: ((_ checked: Bool, _ interestt: Interests) -> (Void))?
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(false, animated: false)
        if selected {
            if checkbox.isChecked {
                checkbox.isChecked = false
            } else {
                checkbox.isChecked = true
            }
            if let checkboxChanged = checkboxChanged {
                checkboxChanged(checkbox.isChecked, interest)
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
        contentView.addSubview(checkbox)
        checkbox.borderStyle = .roundedSquare(radius: 5)
        checkbox.isUserInteractionEnabled = false
        checkbox.pinLeft(to: contentView.leadingAnchor, const: 10)
        checkbox.pinTop(to: contentView.topAnchor, const: 5)
        checkbox.setWidth(to: 30)
        checkbox.setHeight(to: 30)
        
        contentView.addSubview(interestLabel)
        interestLabel.pinLeft(to: checkbox.trailingAnchor, const: 5)
        interestLabel.setWidth(to: 250)
        interestLabel.pinCenter(to: checkbox.centerYAnchor, const: 0)
    }

}
