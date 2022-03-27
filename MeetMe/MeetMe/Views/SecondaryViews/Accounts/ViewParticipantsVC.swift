//
//  ViewParticipantsVC.swift
//  MeetMe
//
//  Created by Stepan Ostapenko on 24.03.2022.
//

import UIKit

class ViewParticipantsVC: UITableViewController {

    var group: Group?
    var meeting: Meeting?
    var participants = [Account]()
    var admins = [Account]()
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let group = group {
            
        }
        if let meeting = meeting {
            MeetingRequests.shared.getParticipants(meetingID: meeting.id)
        }
        
        admins.append(User.currentUser.account!)
        
        participants.append(Server.shared.romaUser.account!)
        participants.append(Server.shared.secondUser.account!)
        
        setConstraint()
    }
    
    func setConstraint() {
        
        self.tableView.register(ViewFriendCell.self, forCellReuseIdentifier: "accountCell")
        navigationItem.title = "Участники"
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return admins.count
        case 1:
            return participants.count
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Админы"
        case 1:
            return "Участники"
        default:
            return ""
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "accountCell", for: indexPath) as! ViewFriendCell
        if indexPath.section == 0 {
            cell.account = admins[indexPath.row]
        } else {
            cell.account = participants[indexPath.row]
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = AccountVC()
        if indexPath.section == 0 {
            vc.account = admins[indexPath.row]
        } else {
            vc.account = participants[indexPath.row]
        }
        vc.isUserAccount = false
        if vc.account!.id != User.currentUser.account!.id {
            navigationController?.pushViewController(vc, animated: true)
        }
        self.tableView.deselectRow(at: indexPath, animated: false)
    }
}
