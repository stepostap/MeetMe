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
    let groupTableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        configNaviationBar()
    }
    
    func configNaviationBar() {
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
    }
    
    @objc func createGroup() {
        let vc = CreateGroupVC()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc  func filterGroupSearch() {
        
    }
    
}
