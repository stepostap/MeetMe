//
//  PhotoCollectionFooter.swift
//  MeetMe
//
//  Created by Stepan Ostapenko on 07.04.2022.
//

import UIKit

class PhotoCollectionFooter: UICollectionReusableView {
    let addButton = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(addButton)
        Utilities.styleFilledButton(addButton)
        addButton.pinLeft(to: self.leadingAnchor, const: 20)
        addButton.pinRight(to: self.trailingAnchor, const: 20)
        addButton.pinTop(to: self.topAnchor, const: 5)
        addButton.pinBottom(to: self.bottomAnchor, const: 5)
        addButton.setTitle("Добавить фотографии", for: .normal)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
