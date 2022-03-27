//
//  GroupsVC.swift
//  MeetMe
//
//  Created by Stepan Ostapenko on 24.02.2022.
//

import UIKit

class GroupsVC: UITableViewController, UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        
    }
    let searchController = UISearchController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        User.currentUser = Server.shared.users[LoginInfo(email: "Stepostap@gmail.com", password: "12345")]!
        view.backgroundColor = .systemBackground
        configView()
    }
    
    func configView() {
        let filterButton = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(filterGroupSearch))
        let createMeetingButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(createGroup))
        searchController.searchBar.sizeToFit()
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Groups"
        
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.searchController = searchController
        navigationItem.leftBarButtonItem = filterButton
        navigationItem.rightBarButtonItem = createMeetingButton
        
        self.tableView.register(GroupCell.self, forCellReuseIdentifier: "groupCell")
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "groupCell", for: indexPath) as! GroupCell
        cell.nameLabel.text = User.currentUser.groups[indexPath.row].groupName
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return User.currentUser.groups.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = GroupScreen()
        vc.group = User.currentUser.groups[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }
    
//    override func tableView(_ tableView: UITableView,
//                            trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
//        var actions = [UIContextualAction]()
//        let leaveAction = UIContextualAction(style: .destructive, title: "Покинуть группу") { _, _, complete in
//            let alert = UIAlertController(title: "Покинуть группу?", message: "Вы уверены, что хотите покинуть группу? Это действие нельзя отменить.", preferredStyle: .alert)
//            let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
//            let removeAction = UIAlertAction(title: "Покинуть", style: .default, handler: {_ in
//                // GroupRequests.shared.resignGroup
//                User.currentUser.groups.remove(at: indexPath.row)
//                tableView.deleteRows(at: [indexPath], with: .automatic)
//                tableView.reloadData()
//            })
//            alert.addAction(cancelAction)
//            alert.addAction(removeAction)
//            self.present(alert, animated: true)
//        }
//
//        let editAction = UIContextualAction(style: .normal, title: "Редактировать") { _, _, complete in
//            let vc = CreateMeetingVC()
//            vc.meeting = self.currentMeetings[indexPath.row]
//            self.navigationController?.pushViewController(vc, animated: true)
//        }
//
//        let participateAction = UIContextualAction(style: .normal, title: "Участвовать") { _, _, complete in
//            MeetingRequests.shared.participateInMeeting(meetingID: self.currentMeetings[indexPath.row].id)
//        }
//
//        if currentMeetings[indexPath.row].creatorID == User.currentUser.account!.id {
//            actions.append(editAction)
//            actions.append(deleteAction)
//        } else {
//            actions.append(leaveAction)
//        }
//
//        if segmentController.selectedSegmentIndex == 2 {
//            actions.append(participateAction)
//        }
//
//        let configuration = UISwipeActionsConfiguration(actions: actions)
//        configuration.performsFirstActionWithFullSwipe = false
//        return configuration
//    }
    
    @objc func createGroup() {
        let vc = CreateGroupVC()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func filterGroupSearch() {
        
    }
    
}
