//
//  InterestsVC.swift
//  MeetMe
//
//  Created by Stepan Ostapenko on 11.03.2022.
//

import UIKit

class InterestsVC: UIViewController {
    
    var interests = [Interests]()
    var meetingTypeCheckboxes = [CheckBox]()
    var completion: (([Interests]) -> (Void))?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createCheckboxArray()
        
        for checkbox in meetingTypeCheckboxes {
            checkbox.isChecked = interests.contains(Interests.allCases[checkbox.index])
        }
        
        let checkboxStack = createCheckboxStackview()
        view.backgroundColor = .systemBackground
        view.addSubview(checkboxStack)
        checkboxStack.setConstraints(to: view, left: 5, top: 5, right: 5, bottom: 5)
        // Do any additional setup after loading the view.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        completion?(interests)
    }

    func createCheckboxStackview() -> UIStackView {
        let checkboxStack = UIStackView()
        checkboxStack.axis = NSLayoutConstraint.Axis.vertical
        checkboxStack.alignment = UIStackView.Alignment.leading
        checkboxStack.spacing = 10
        
        for checkbox in meetingTypeCheckboxes {
            checkboxStack.addArrangedSubview(createCheckboxWithLabel(checkbox: checkbox,
                                                                     text: Interests.allCases[checkbox.index].rawValue))
        }
        
        return checkboxStack
    }
    
    func createCheckboxArray(){
        var i = 0
        for _ in Interests.allCases {
            let checkbox = CheckBox.init()
            checkbox.style = .tick
            checkbox.borderStyle = .roundedSquare(radius: 5)
            checkbox.index = i
            checkbox.addTarget(self, action: #selector(syncCheckbox(_:)), for: .valueChanged)
            i += 1
            meetingTypeCheckboxes.append(checkbox)
        }
    }
    
    @objc func syncCheckbox(_ sender: CheckBox)  {
        let type = Interests.allCases[sender.index]
        if sender.isChecked {
            interests.append(type)
        } else {
            if let index = interests.firstIndex(of: type){
                interests.remove(at: index)
            }
        }
    }

    func createCheckboxWithLabel(checkbox: CheckBox, text: String) -> UIView {
        let container = UIView()
        container.setHeight(to: 30)
        container.setWidth(to: 250)
        
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 15)
        
        container.addSubview(checkbox)
        container.addSubview(label)
        
        checkbox.setConstraints(to: container, left: 5, top: 5, width: 30, height: 30)
        label.pinLeft(to: checkbox.trailingAnchor, const: 10)
        label.pinTop(to: container.topAnchor, const: 10)
        label.setWidth(to: 200)
        label.setHeight(to: 20)
        
        return container
    }
}
