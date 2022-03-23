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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        participantTableView.delegate = self
        participantTableView.dataSource = self
        
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.backgroundColor = .systemBackground
        
        configNavigationBar()
        configSegmentController()
        configMeetingTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        FriendsReequests.shared.getFriends(userID: User.currentUser.account!.id)
        FriendsReequests.shared.getFriendRequests()
        
        User.currentUser = Server.shared.users[loginInfo(email: "Stepostap@gmail.com", password: "12345")]!
        
        segmentController.selectedSegmentIndex = 0
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if segmentController.selectedSegmentIndex == 0 {
            return User.currentUser.friends.count
        } else {
            return User.currentUser.groups.count
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
            
        } else {
            cell.nameLabel.text = User.currentUser.friends[indexPath.row].name
            cell.participantID = User.currentUser.friends[indexPath.row].id
            cell.checkboxChanged = friendIDChanged
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
        segmentController.setConstraints(to: view, left: 30, top: 0, right: 30, height: 30)
        segmentController.selectedSegmentIndex = 1
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
        //participantTableView.allowsSelection = false
        participantTableView.register(AddParticipantCell.self, forCellReuseIdentifier: "cell")
        view.addSubview(participantTableView)
        participantTableView.pinTop(to: segmentController.bottomAnchor, const: 10)
        participantTableView.pinLeft(to: view.safeAreaLayoutGuide.leadingAnchor, const: 10)
        participantTableView.pinRight(to: view.safeAreaLayoutGuide.trailingAnchor, const: 10)
        participantTableView.pinBottom(to: view.safeAreaLayoutGuide.bottomAnchor, const: 10)
    }
}
