//
//  SearchVC.swift
//  MeetMe
//
//  Created by Stepan Ostapenko on 03.03.2022.
//

import UIKit

class SearchVC: UIPresentationController {
    override func containerViewWillLayoutSubviews() {
        self.presentedView?.backgroundColor = .systemRed
    }
}
