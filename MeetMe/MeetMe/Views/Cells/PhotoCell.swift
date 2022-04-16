//
//  PhotoCell.swift
//  MeetMe
//
//  Created by Stepan Ostapenko on 07.04.2022.
//

import UIKit
import Kingfisher

/// Ячейка, отображающая фотографию в PhotoGalleryVC
class PhotoCell: UICollectionViewCell {
    ///  UI элемент для отображения фотографии
    var image = UIImageView()
    
    /// Метод, формирующий внешний вид ячейки
    func configure() {
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
        contentView.addSubview(image)
        image.pin(to: self.contentView)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        image.image = nil
    }
}
