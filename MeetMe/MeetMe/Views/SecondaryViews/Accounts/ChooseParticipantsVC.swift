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
    let loader = UIActivityIndicatorView()
    let refresher = UIRefreshControl()
    
    var passData: ((_ friendIDs: [Int64], _ groupIDs: [Int64]) -> (Void))?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        participantTableView.delegate = self
        participantTableView.dataSource = self
        
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.backgroundColor = .systemBackground
        
        configNavigationBar()
        configSegmentController()
        uploadInfo()
        
        configMeetingTableView()
    }
    
    @objc func refreshInfo() {
        if segmentController.selectedSegmentIndex == 1 {
            GroupRequests.shared.getUserGroups(completion: {(groups, error) in
                self.loader.stopAnimating()
                self.refresher.endRefreshing()
                if let error = error {
                    let alert = ErrorChecker.handler.getAlertController(error: error)
                    self.present(alert, animated: true, completion: nil)
                    return
                }
                if let groups = groups {
                    User.currentUser.groups = groups
                    self.participantTableView.reloadData()
                }
                self.participantTableView.reloadData()
            })
        } else {
            FriendsReequests.shared.getFriends(completion: {(friends, error) in
                self.loader.stopAnimating()
                self.refresher.endRefreshing()
                if let error = error {
                    let alert = ErrorChecker.handler.getAlertController(error: error)
                    self.present(alert, animated: true, completion: nil)
                    return
                }
                if let friends = friends {
                    User.currentUser.friends = friends
                }
                self.participantTableView.reloadData()
            })
        }
    }
    
    func uploadInfo() {
        
        if User.currentUser.groups == nil {
            loader.startAnimating()
            refreshInfo()
        }
        
        if User.currentUser.friends == nil {
            loader.startAnimating()
            refreshInfo()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        passData?(chosenFriendIDs, chosenGroupIDs)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if segmentController.selectedSegmentIndex == 1 {
            return User.currentUser.groups?.count ?? 0
        } else {
            return User.currentUser.friends?.count ?? 0
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
    
    
    func groupIDChanged(checked: Bool, ID: Int64) {
        if checked {
            chosenGroupIDs.append(ID)
        } else {
            let index = chosenGroupIDs.firstIndex(of: ID)
            if let index = index {
                chosenGroupIDs.remove(at: index)
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! AddParticipantCell
        
        if segmentController.selectedSegmentIndex == 1 {
            let group = User.currentUser.groups![indexPath.row]
            cell.nameLabel.text = group.groupName
            cell.participantID = group.id
            cell.checkboxChanged = groupIDChanged
            if chosenGroupIDs.contains(cell.participantID!) {
                cell.checkbox.isChecked = true
            }
            if !group.groupImageURL.isEmpty {
                let url = URL(string: group.groupImageURL)
                cell.participantImage.kf.indicatorType = .activity
                cell.participantImage.kf.setImage(with: url, options: [ .cacheOriginalImage ])
            }
            
        } else {
            let meeting = User.currentUser.friends![indexPath.row]
            cell.nameLabel.text = meeting.name
            cell.participantID = meeting.id
            cell.checkboxChanged = friendIDChanged
            if chosenFriendIDs.contains(cell.participantID!) {
                cell.checkbox.isChecked = true
            }
            if !meeting.imageDataURL.isEmpty {
                let url = URL(string: meeting.imageDataURL)
                cell.participantImage.kf.indicatorType = .activity
                cell.participantImage.kf.setImage(with: url, options: [ .cacheOriginalImage ])
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
        uploadInfo()
        participantTableView.reloadSections(IndexSet(integer: 0), with: .none)
    }
    
    func configSegmentController() {
        if includeGroups {
            view.addSubview(segmentController)
            segmentController.selectedSegmentIndex = 0
            segmentController.setConstraints(to: view, left: 30, top: 0, right: 30, height: 30)
            segmentController.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        }
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
        refresher.addTarget(self, action: #selector(refreshInfo), for: .valueChanged)
        participantTableView.refreshControl = refresher
        participantTableView.backgroundView = loader
        participantTableView.pinLeft(to: view.safeAreaLayoutGuide.leadingAnchor, const: 10)
        participantTableView.pinRight(to: view.safeAreaLayoutGuide.trailingAnchor, const: 10)
        participantTableView.pinBottom(to: view.safeAreaLayoutGuide.bottomAnchor, const: 10)
    }
}
