//
//  ViewFriendCellTableViewCell.swift
//  MeetMe
//
//  Created by Stepan Ostapenko on 19.03.2022.
//

import UIKit

class ViewFriendCell: UITableViewCell {

    var account: Account? {
        didSet {
            nameLabel.text = account?.name
            if !account!.imageDataURL.isEmpty {
                let url = URL(string: account!.imageDataURL)
                accountImage.kf.indicatorType = .activity
                accountImage.kf.setImage(with: url, options: [ .cacheOriginalImage ])
            }
        }
    }
    
    let nameLabel = UILabel()
    
    let accountImage: UIImageView = {
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
    
    private func setCostraints() {
        contentView.setHeight(to: 50)
        contentView.addSubview(accountImage)
        accountImage.setConstraints(to: contentView, left: 20, top: 5, width: 45, height: 45)
        accountImage.image = UIImage(named:"placeholder")
        
        contentView.addSubview(nameLabel)
        nameLabel.pinLeft(to: accountImage.trailingAnchor, const: 10)
        nameLabel.pinCenter(to: contentView.centerYAnchor, const: 0)
        nameLabel.pinRight(to: contentView.trailingAnchor, const: 10)
    }


}
