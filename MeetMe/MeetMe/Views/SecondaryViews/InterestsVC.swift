//
//  InterestsVC.swift
//  MeetMe
//
//  Created by Stepan Ostapenko on 11.03.2022.
//

import UIKit

/// Контроллер, отвечающий за выбор интересов
class InterestsVC: UITableViewController {
    /// Список выбранных интересов
    var interests = [Interests]()
    /// Метод, который вызывается при закрытии данного контроллера, для передачи данных о выбранных интересах 
    var completion: (([Interests]) -> (Void))?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(InterestCell.self, forCellReuseIdentifier: "interestCell")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        completion?(interests)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Interests.allCases.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "interestCell", for: indexPath) as! InterestCell
        cell.interest = Interests.allCases[indexPath.row]
        if self.interests.contains(cell.interest) {
            cell.checkbox.isChecked = true
        } else {
            cell.checkbox.isChecked = false
        }
        cell.checkboxChanged = {(checked, interest) in
            if checked {
                self.interests.append(interest)
            } else {
                if let index = self.interests.firstIndex(of: interest) {
                    self.interests.remove(at: index)
                }
            }
        }
        return cell
    }
}
