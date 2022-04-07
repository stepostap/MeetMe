//
//  AccountSearchResultsVC.swift
//  MeetMe
//
//  Created by Stepan Ostapenko on 05.04.2022.
//

import UIKit

class AccountSearchResultsVC: UITableViewController, UISearchResultsUpdating {
    
    var parentVC: FriendsVC {
        return self.presentingViewController as! FriendsVC
    }
    
    var accounts = [[Account]]()
    let loader = UIActivityIndicatorView()

    override func viewDidLoad() {
        super.viewDidLoad()

        
        confinTableView()
    }
    
    func confinTableView() {
        self.tableView.backgroundView = loader
        self.tableView.backgroundColor = .systemBackground
        self.tableView.register(ViewFriendCell.self, forCellReuseIdentifier: "accountCell")
    }

    func updateSearchResults(for searchController: UISearchController) {
        loader.startAnimating()
        let query = searchController.searchBar.text ?? ""
        print(parentVC.segmentController.selectedSegmentIndex)
        if !query.isEmpty {
            FriendsReequests.shared.searchFriends(query: query, completion: updateTable(accounts:error:))
        }
    }
    
    func updateTable(accounts: [[Account]]?, error: Error?) {
        self.loader.stopAnimating()
        if let error = error {
            let alert = ErrorChecker.handler.getAlertController(error: error)
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        if let accounts = accounts {
            self.accounts = accounts
            print(self.accounts.count)
        }
        self.tableView.reloadData()
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return accounts.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return accounts[section].count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "accountCell", for: indexPath) as! ViewFriendCell
        cell.account = accounts[indexPath.section][indexPath.row]
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Друзья"
        } else {
            return "Глобальный поиск"
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = AccountVC()
        vc.account = accounts[indexPath.section][indexPath.row]
        vc.isUserAccount = false
        parentVC.navigationController!.pushViewController(vc, animated: true)
    }
}
