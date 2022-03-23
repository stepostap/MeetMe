//
//  FriendsVC.swift
//  MeetMe
//
//  Created by Stepan Ostapenko on 14.03.2022.
//

import UIKit

class FriendsVC: UIViewController, UISearchResultsUpdating, UITableViewDelegate, UITableViewDataSource {
    
    let segmentController = UISegmentedControl(items: ["Друзья", "Запросы"])
    let searchController = UISearchController(searchResultsController: nil)
    let friendsTableView = UITableView()
    
    var currentFriends = [Account]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        friendsTableView.delegate = self
        friendsTableView.dataSource = self
        
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
        currentFriends = User.currentUser.friends
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentFriends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MeetingCell", for: indexPath) as! ViewFriendCellTableViewCell
        cell.account = currentFriends[indexPath.row]
       
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = AccountVC()
        vc.account = currentFriends[indexPath.row]
        vc.isUserAccount = false
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
    func updateSearchResults(for searchController: UISearchController) {
        
    }
    
    
    @objc func segmentChanged() {
        if segmentController.selectedSegmentIndex == 0 {
            currentFriends = User.currentUser.friends
        } else {
            currentFriends = User.currentUser.friendsRequests
        }
       
        friendsTableView.reloadData()
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
        
        friendsTableView.register(ViewFriendCellTableViewCell.self, forCellReuseIdentifier: "MeetingCell")
        view.addSubview(friendsTableView)
        friendsTableView.pinTop(to: segmentController.bottomAnchor, const: 10)
        friendsTableView.pinLeft(to: view.safeAreaLayoutGuide.leadingAnchor, const: 10)
        friendsTableView.pinRight(to: view.safeAreaLayoutGuide.trailingAnchor, const: 10)
        friendsTableView.pinBottom(to: view.safeAreaLayoutGuide.bottomAnchor, const: 10)
    }

}
