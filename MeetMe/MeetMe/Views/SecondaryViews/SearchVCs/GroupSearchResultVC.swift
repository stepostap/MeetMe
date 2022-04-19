//
//  GroupSearchResultVC.swift
//  MeetMe
//
//  Created by Stepan Ostapenko on 05.04.2022.
//

import UIKit

/// Организация отображения результатов поиска групп
class GroupSearchResultVC: UITableViewController, UISearchResultsUpdating {
    /// ViewController, содержащий данный ViewController
    private var parentVC: GroupsVC {
        return self.presentingViewController as! GroupsVC
    }
    /// Список отображаемых групп
    private var groups = [[Group]]()
    /// Индндикатор загрузки 
    private let loader = UIActivityIndicatorView()

    override func viewDidLoad() {
        super.viewDidLoad()
        confinTableView()
    }
    /// Формирование таблицы с найденными группами
    private func confinTableView() {
        self.tableView.backgroundView = loader
        self.tableView.backgroundColor = UIColor(named: "BackgroundMain")
        self.tableView.register(GroupCell.self, forCellReuseIdentifier: "groupCell")
    }

    func updateSearchResults(for searchController: UISearchController) {
        loader.startAnimating()
        let query = searchController.searchBar.text ?? ""
        if !query.isEmpty {
            GroupRequests.shared.getFilteredGroups(query: query, filter: parentVC.searchFilterInterests, completion: updateTable(groups:error:))
        }
    }
    /// Обновление данных таблицы с найденными группами 
    private func updateTable(groups: [[Group]]?, error: Error?) {
        self.loader.stopAnimating()
        if let error = error {
            let alert = ErrorChecker.handler.getAlertController(error: error)
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        if let groups = groups {
            self.groups = groups
        }
       
        self.tableView.reloadData()
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = GroupScreen()
        vc.group = groups[indexPath.section][indexPath.row]
        parentVC.navigationController?.pushViewController(vc, animated: true)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return groups.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groups[section].count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Мои группы"
        } else {
            return "Глобальный поиск"
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "groupCell", for: indexPath) as! GroupCell
        let group = groups[indexPath.section][indexPath.row]
        cell.nameLabel.text = group.groupName
        cell.backgroundColor = UIColor(named: "BackgroundMain")
        if !group.groupImageURL.isEmpty {
            let url = URL(string: group.groupImageURL)
            cell.groupImage.kf.indicatorType = .activity
            cell.groupImage.kf.setImage(with: url, options: [ .cacheOriginalImage ])
        }

        return cell
    }
}
