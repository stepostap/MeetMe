//
//  AccountSearchResultsVC.swift
//  MeetMe
//
//  Created by Stepan Ostapenko on 05.04.2022.
//

import UIKit

/// Организация отображения результатов поиска аккаунтов
class AccountSearchResultsVC: UITableViewController, UISearchResultsUpdating {
    /// ViewController, содержащий данный ViewController
    private var parentVC: FriendsVC {
        return self.presentingViewController as! FriendsVC
    }
    /// Список отображаемых аккаунтов
    private var accounts = [[Account]]()
    /// Индикатор загрузки
    private let loader = UIActivityIndicatorView()

    override func viewDidLoad() {
        super.viewDidLoad()
        confinTableView()
    }
    
    /// Формирование таблицы найденных аккаунтов
    private func confinTableView() {
        self.tableView.backgroundView = loader
        self.tableView.backgroundColor = UIColor(named: "BackgroundMain")
        self.tableView.register(ViewFriendCell.self, forCellReuseIdentifier: "accountCell")
    }

    func updateSearchResults(for searchController: UISearchController) {
        loader.startAnimating()
        let query = searchController.searchBar.text ?? ""
        if !query.isEmpty {
            FriendsReequests.shared.searchFriends(query: query, completion: updateTable(accounts:error:))
        }
    }
    
    /// Обновление таблицы с найденными аккаунтами
    private func updateTable(accounts: [[Account]]?, error: Error?) {
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
        cell.backgroundColor = UIColor(named: "BackgroundMain")
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
