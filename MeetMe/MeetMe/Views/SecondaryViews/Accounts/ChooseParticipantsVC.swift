//
//  ChooseParticipantsVC.swift
//  MeetMe
//
//  Created by Stepan Ostapenko on 21.03.2022.
//

import UIKit
import Network

class ChooseParticipantsVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating {

    let segmentController = UISegmentedControl(items: ["Друзья", "Группы"])
    let searchController = UISearchController(searchResultsController: nil)
    let participantTableView = UITableView()
    var chosenFriendIDs = [Int64]()
    var chosenGroupIDs = [Int64]()
    var includeGroups = false
    var alreadyAddedFriends = [Int64]()
    
    var passData: ((_ friendIDs: [Int64], _ groupIDs: [Int64]) -> (Void))?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        participantTableView.delegate = self
        participantTableView.dataSource = self
        
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.backgroundColor = .systemBackground
        
        configNavigationBar()
        if includeGroups {
            configSegmentController()
        }
        configMeetingTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        FriendsReequests.shared.getFriends(userID: User.currentUser.account!.id)
        FriendsReequests.shared.getFriendRequests()
        
        User.currentUser = Server.shared.users[LoginInfo(email: "Stepostap@gmail.com", password: "12345")]!
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        passData?(chosenFriendIDs, chosenGroupIDs)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if segmentController.selectedSegmentIndex == 1 {
            return User.currentUser.groups.count
        } else {
            return User.currentUser.friends.count
        }
    }
    
    func friendIDChanged(checked: Bool, ID: Int64) {
        if checked {
            chosenFriendIDs.append(ID)
        } else {
            let index = chosenFriendIDs.firstIndex(of: ID)
            if let index = index {
                chosenFriendIDs.remove(at: index)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! AddParticipantCell
        
        if segmentController.selectedSegmentIndex == 1 {
            cell.nameLabel.text = User.currentUser.groups[indexPath.row].groupName
            cell.participantID = User.currentUser.groups[indexPath.row].id
            if chosenGroupIDs.contains(cell.participantID!) {
                cell.checkbox.isChecked = true
            }
            
        } else {
            cell.nameLabel.text = User.currentUser.friends[indexPath.row].name
            cell.participantID = User.currentUser.friends[indexPath.row].id
            cell.checkboxChanged = friendIDChanged
            if chosenFriendIDs.contains(cell.participantID!) {
                cell.checkbox.isChecked = true
            }
            if alreadyAddedFriends.contains(cell.participantID!) {
                cell.canBeSelected = false
                cell.checkbox.isChecked = true
                cell.backgroundColor = .systemGray4
            }
        }
        
        return cell
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        
    }

    @objc func segmentChanged() {
        participantTableView.reloadData()
    }
    
    func configSegmentController() {
        view.addSubview(segmentController)
        segmentController.selectedSegmentIndex = 0
        segmentController.setConstraints(to: view, left: 30, top: 0, right: 30, height: 30)
        segmentController.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
    }
    
    func configNavigationBar()  {
       
        searchController.searchBar.sizeToFit()
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search meetings"
        
        navigationItem.title = "Друзья"
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.searchController = searchController
    }
    
    func configMeetingTableView() {
        participantTableView.register(AddParticipantCell.self, forCellReuseIdentifier: "cell")
        view.addSubview(participantTableView)
        if includeGroups {
            participantTableView.pinTop(to: segmentController.bottomAnchor, const: 10)
        } else {
            participantTableView.pinTop(to: view.safeAreaLayoutGuide.topAnchor, const: 10)
        }
        participantTableView.pinLeft(to: view.safeAreaLayoutGuide.leadingAnchor, const: 10)
        participantTableView.pinRight(to: view.safeAreaLayoutGuide.trailingAnchor, const: 10)
        participantTableView.pinBottom(to: view.safeAreaLayoutGuide.bottomAnchor, const: 10)
    }
}
