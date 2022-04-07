//
//  PhotoCell.swift
//  MeetMe
//
//  Created by Stepan Ostapenko on 07.04.2022.
//

import UIKit
import Kingfisher

class PhotoCell: UICollectionViewCell {
    var image = UIImageView()
    var imageURL: URL!
    
//    override init(frame: CGRect) {
//        image.contentMode = .scaleAspectFill
//        image.clipsToBounds = true
//        super.init(frame:frame)
//        contentView.addSubview(image)
//        image.pin(to: self.contentView)
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("error")
//    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        image.kf.indicatorType = .activity
        image.kf.setImage(with: imageURL)
        //image.image = UIImage(named: "placeholder")
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
        contentView.addSubview(image)
        image.pin(to: self.contentView)
    }
}
