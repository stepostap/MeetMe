//
//  GroupsVC.swift
//  MeetMe
//
//  Created by Stepan Ostapenko on 24.02.2022.
//

import UIKit

/// Контроллер, отвечающий за отображение списка групп пользователя
class GroupsVC: UITableViewController {
    /// Контроллер, отвечающий за отображение разультата поиска групп
    private let searchResultVC = GroupSearchResultVC()
    /// Контроллер поиска
    private var searchController: UISearchController?
    /// Идентификатор загрузки
    private let loader = UIActivityIndicatorView()
    /// Идентификатор обновления данных
    private let refresher = UIRefreshControl()
    /// Список-фильтр интересов для поиска групп
    var searchFilterInterests = [Interests]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "BackgroundMain")
        searchController = UISearchController(searchResultsController: searchResultVC)
        configView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateGroups()
    }
    
    /// Обновление информации о группах пользователя
    private func updateGroups() {
        if let _  = User.currentUser.groups {
            self.loader.stopAnimating()
            self.tableView.reloadData()
        } else {
            getGroups()
        }
    }
    
    /// Загрузка информации о группах пользователя
    @objc private func getGroups() {
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
    
    /// Переход на экран создания новой группы
    @objc private func createGroup() {
        let vc = CreateGroupVC()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    /// Отображение контроллера для создания фильтра поиска групп
    @objc private func filterGroupSearch() {
        let searchFilterVC = InterestsVC()
        searchFilterVC.interests = searchFilterInterests
        searchFilterVC.completion = {(interests) in
            self.searchFilterInterests = interests
        }
        if let sheet = searchFilterVC.sheetPresentationController {
            sheet.detents = [ .medium(), .large() ]
        }
        
        present(searchFilterVC, animated: true)
    }
    
    // MARK: Configs
    /// Формирование экрана групп
    private func configView() {
        let filterButton = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(filterGroupSearch))
        let createMeetingButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(createGroup))
        searchController?.searchBar.sizeToFit()
        
        searchController?.searchResultsUpdater = searchResultVC
        searchController?.obscuresBackgroundDuringPresentation = false
        searchController?.searchBar.placeholder = "Искать группы"
        
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
    
    // MARK: TableView Datasource
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "groupCell", for: indexPath) as! GroupCell
        let group = User.currentUser.groups![indexPath.row]
        cell.nameLabel.text = group.groupName
        cell.backgroundColor = UIColor(named: "BackgroundMain")
        if !group.groupImageURL.isEmpty {
            let url = URL(string: group.groupImageURL)
            cell.groupImage.kf.indicatorType = .activity
            cell.groupImage.kf.setImage(with: url, options: [.forceRefresh ])
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
}
