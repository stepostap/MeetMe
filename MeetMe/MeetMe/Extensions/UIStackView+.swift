//
//  UIStackView+.swift
//  MeetMe
//
//  Created by Stepan Ostapenko on 13.03.2022.
//

import Foundation
import UIKit

extension UIStackView {
    
    func removeFully(view: UIView) {
        removeArrangedSubview(view)
        view.removeFromSuperview()
    }
    
    func removeFullyAllArrangedSubviews() {
        arrangedSubviews.forEach { (view) in
            removeFully(view: view)
        }
    }
    
}
