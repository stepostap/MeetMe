//
//  GroupsVC.swift
//  MeetMe
//
//  Created by Stepan Ostapenko on 24.02.2022.
//

import UIKit

class GroupsVC: UITableViewController {
    
    let searchResultVC = GroupSearchResultVC()
    var searchController:  UISearchController?
    let loader = UIActivityIndicatorView()
    let refresher = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        searchController = UISearchController(searchResultsController: searchResultVC)
        configView()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateGroups()
    }
    
    
    func updateGroups() {
        if let _  = User.currentUser.groups {
            self.loader.stopAnimating()
            self.tableView.reloadData()
        } else {
            getGroups()
        }
    }
    

    @objc func getGroups() {
        GroupRequests.shared.getUserGroups(completion: {(groups, error) in
            self.loader.stopAnimating()
            self.refreshControl?.endRefreshing()
            if let error = error {
                let alert = ErrorChecker.handler.getAlertController(error: error)
                self.present(alert, animated: true, completion: nil)
                return
            }
            if let groups = groups {
                User.currentUser.groups = groups
                self.tableView.reloadData()
            }
        })
    }
    
    
    func configView() {
        let filterButton = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(filterGroupSearch))
        let createMeetingButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(createGroup))
        searchController?.searchBar.sizeToFit()
        
        searchController?.searchResultsUpdater = searchResultVC
        searchController?.obscuresBackgroundDuringPresentation = false
        searchController?.searchBar.placeholder = "Search Groups"
        
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.searchController = searchController
        navigationItem.leftBarButtonItem = filterButton
        navigationItem.rightBarButtonItem = createMeetingButton
        
        self.tableView.register(GroupCell.self, forCellReuseIdentifier: "groupCell")
        loader.startAnimating()
        self.tableView.backgroundView = loader
        refresher.addTarget(self, action: #selector(getGroups), for: .valueChanged)
        self.tableView.refreshControl = refresher
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "groupCell", for: indexPath) as! GroupCell
        let group = User.currentUser.groups![indexPath.row]
        cell.nameLabel.text = group.groupName
        if !group.groupImageURL.isEmpty {
            let url = URL(string: group.groupImageURL)
            cell.groupImage.kf.indicatorType = .activity
            cell.groupImage.kf.setImage(with: url, options: [ .cacheOriginalImage ])
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return User.currentUser.groups?.count ??  0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = GroupScreen()
        vc.group = User.currentUser.groups?[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
    
//    override func tableView(_ tableView: UITableView,
//                            trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
//        var actions = [UIContextualAction]()
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
