//
//  MeetingsVC.swift
//  MeetMe
//
//  Created by Stepan Ostapenko on 24.02.2022.
//

import UIKit

class MeetingsVC: UIViewController {
    
    let segmentController = UISegmentedControl(items: ["История", "Предстоящие", "Приглашения"])

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
    }
    

}
