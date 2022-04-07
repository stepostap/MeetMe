//
//  FriendsVC.swift
//  MeetMe
//
//  Created by Stepan Ostapenko on 14.03.2022.
//

import UIKit
import CloudKit
import Network

class FriendsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let segmentController = UISegmentedControl(items: ["Друзья", "Запросы"])
    var searchController: UISearchController?
    let friendsTableView = UITableView()
    let loader = UIActivityIndicatorView()
    let refresher = UIRefreshControl()
    let searchAccountsVC = AccountSearchResultsVC()
    
    var currentFriends = [Account]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        friendsTableView.delegate = self
        friendsTableView.dataSource = self
        
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.backgroundColor = .systemBackground
        searchController = UISearchController(searchResultsController: searchAccountsVC)
        segmentController.selectedSegmentIndex = 0
        
        configNavigationBar()
        configSegmentController()
        configMeetingTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        reloadData()
    }
    
    
    @objc func reloadData() {
        if segmentController.selectedSegmentIndex == 0 {
            if let _  = User.currentUser.friends {
                currentFriends = User.currentUser.friends!
            } else  {
                currentFriends = []
                uploadFriends()
            }
        } else  {
            if let _  = User.currentUser.friendsRequests {
                currentFriends = User.currentUser.friendsRequests!
            } else  {
                currentFriends = []
                uploadFriends()
            }
        }
        friendsTableView.reloadData()
    }
    
    
    @objc func uploadFriends() {
        loader.startAnimating()
        if segmentController.selectedSegmentIndex == 0 {
            FriendsReequests.shared.getFriends(completion: {(accounts, error) in
                self.loader.stopAnimating()
                self.friendsTableView.refreshControl?.endRefreshing()
                if let error = error {
                    let alert = ErrorChecker.handler.getAlertController(error: error)
                    self.present(alert, animated: true, completion: nil)
                    self.friendsTableView.refreshControl?.endRefreshing()
                    return
                }
                
                if let accounts = accounts {
                    User.currentUser.friends = accounts
                    self.currentFriends = accounts
                    self.friendsTableView.reloadData()
                }
            })
        } else {
            FriendsReequests.shared.getFriendRequests(completion: {(accounts, error) in
                self.loader.stopAnimating()
                self.friendsTableView.refreshControl?.endRefreshing()
                if let error = error {
                    let alert = ErrorChecker.handler.getAlertController(error: error)
                    self.present(alert, animated: true, completion: nil)
                    self.loader.stopAnimating()
                    self.friendsTableView.refreshControl?.endRefreshing()
                    return
                }
                
                if let accounts = accounts {
                    User.currentUser.friendsRequests = accounts
                    self.currentFriends = accounts
                    self.friendsTableView.reloadData()
                }
            })
        }
        
    }
    
    
    func addFriendAction(indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .normal, title: "Добавить в друзья") {[weak self] (_,_,_) in
            FriendsReequests.shared.makeFriendRequest(recieverId: self!.currentFriends[indexPath.row].id, completion: {(error) in
                if let error = error {
                    let alert = ErrorChecker.handler.getAlertController(error: error)
                    self?.present(alert, animated: true, completion: nil)
                    return
                }
                
                let index = User.currentUser.friendsRequests?.firstIndex(of: self!.currentFriends[indexPath.row])
                User.currentUser.friends?.append(User.currentUser.friendsRequests![index!])
                User.currentUser.friendsRequests?.remove(at: index!)
                self?.friendsTableView.reloadData()
            })
        }
        action.backgroundColor = .systemGreen
        return action
    }
    
    
    func removeFriendAction(indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .destructive, title: "Удалить") {[weak self] (_,_,_) in
            FriendsReequests.shared.deleteFriend(recieverId: self!.currentFriends[indexPath.row].id, completion: {(error) in
                if let error = error {
                    let alert = ErrorChecker.handler.getAlertController(error: error)
                    self?.present(alert, animated: true, completion: nil)
                    return
                }
                
                if User.currentUser.friends!.contains(self!.currentFriends[indexPath.row]) {
                    let index = User.currentUser.friends?.firstIndex(of: self!.currentFriends[indexPath.row])
                    User.currentUser.friends?.remove(at: index!)
                } else {
                    let index = User.currentUser.friendsRequests?.firstIndex(of: self!.currentFriends[indexPath.row])
                    User.currentUser.friendsRequests?.remove(at: index!)
                }
                
                self?.friendsTableView.reloadData()
            })
        }
        
        return action
    }
    
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        var actions = [UIContextualAction]()
        
        if segmentController.selectedSegmentIndex == 1 {
            actions.append(removeFriendAction(indexPath: indexPath))
            actions.append(addFriendAction(indexPath: indexPath))
        } else {
            actions.append(removeFriendAction(indexPath: indexPath))
        }
        
        let configuration = UISwipeActionsConfiguration(actions: actions)
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentFriends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MeetingCell", for: indexPath) as! ViewFriendCell
        cell.account = currentFriends[indexPath.row]
       
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = AccountVC()
        vc.account = currentFriends[indexPath.row]
        vc.isUserAccount = false
        navigationController?.pushViewController(vc, animated: true)
    }
    
   
    @objc func segmentChanged() {
        if segmentController.selectedSegmentIndex == 0 {
            currentFriends = User.currentUser.friends!
        } else {
            currentFriends = User.currentUser.friendsRequests!
        }
       
        friendsTableView.reloadData()
    }
    
    func configSegmentController() {
        view.addSubview(segmentController)
        segmentController.setConstraints(to: view, left: 30, top: 0, right: 30, height: 30)
        segmentController.selectedSegmentIndex = 0
        segmentController.addTarget(self, action: #selector(reloadData), for: .valueChanged)
    }
    
    func configNavigationBar()  {
       
        searchController?.searchBar.sizeToFit()
        searchController?.obscuresBackgroundDuringPresentation = false
        searchController?.searchBar.placeholder = "Search meetings"
        searchController?.searchResultsUpdater = searchAccountsVC
        
        navigationItem.title = "Друзья"
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.searchController = searchController
       
    }
    
    func configMeetingTableView() {
        
        friendsTableView.register(ViewFriendCell.self, forCellReuseIdentifier: "MeetingCell")
        view.addSubview(friendsTableView)
        friendsTableView.backgroundView = loader
        refresher.addTarget(self, action: #selector(uploadFriends), for: .valueChanged)
        friendsTableView.refreshControl = refresher
        friendsTableView.pinTop(to: segmentController.bottomAnchor, const: 10)
        friendsTableView.pinLeft(to: view.safeAreaLayoutGuide.leadingAnchor, const: 10)
        friendsTableView.pinRight(to: view.safeAreaLayoutGuide.trailingAnchor, const: 10)
        friendsTableView.pinBottom(to: view.safeAreaLayoutGuide.bottomAnchor, const: 10)
    }

}
