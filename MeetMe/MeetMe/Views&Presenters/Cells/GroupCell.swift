//
//  GroupCell.swift
//  MeetMe
//
//  Created by Stepan Ostapenko on 23.03.2022.
//

import UIKit

/// Ячейка группы
class GroupCell: UITableViewCell {
    /// Текстовое поле с названием группы
    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 17)
        return label
    }()
    /// UI элемент, отображающий картинку группы
    let groupImage: UIImageView = {
        let image = UIImageView(frame: .zero)
        image.contentMode = .scaleAspectFit
        image.layer.borderWidth = 0
        return image
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
        contentView.setHeight(to: 50)
        contentView.addSubview(groupImage)
        groupImage.setConstraints(to: contentView, left: 20, top: 5, width: 45, height: 45)
        groupImage.image = UIImage(named:"placeholder")
        
        contentView.addSubview(nameLabel)
        nameLabel.pinLeft(to: groupImage.trailingAnchor, const: 10)
        nameLabel.pinCenter(to: contentView.centerYAnchor, const: 0)
        nameLabel.pinRight(to: contentView.trailingAnchor, const: 10)
    }
    
    override func prepareForReuse() {
        groupImage.image = UIImage(named: "placeholder")
    }

}
