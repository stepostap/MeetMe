//
//  FriendsVC.swift
//  MeetMe
//
//  Created by Stepan Ostapenko on 14.03.2022.
//

import UIKit
import CloudKit
import Network

///  Экран списка друзей и списка заявок в друзья
class FriendsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var friendsView: FriendsView!
    /// Список отображаемых аккаунтов
    var currentAccounts = [Account]()
    /// Контроллера поиска
    private var searchController: UISearchController?
    /// Контроллер, отвечающий за отображение результатов поиска
    private let searchAccountsVC = AccountSearchResultsVC()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchController = UISearchController(searchResultsController: searchAccountsVC)
        configNavigationBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        friendsView = FriendsView(navigationController: navigationController!, tableViewDelegate: self, tableviewDataSource: self)
        view = friendsView
        reloadData()
    }
    
    ///  Обновление данных о друзьях и завявках в друзья
    @objc private func reloadData() {
        if friendsView.segmentController.selectedSegmentIndex == 0 {
            if let _  = User.currentUser.friends {
                currentAccounts = User.currentUser.friends!
            } else  {
                currentAccounts = []
                uploadFriends()
            }
        } else  {
            if let _  = User.currentUser.friendsRequests {
                currentAccounts = User.currentUser.friendsRequests!
            } else  {
                currentAccounts = []
                uploadFriends()
            }
        }
        friendsView.friendsTableView.reloadData()
    }
    
    ///  Изменение отображемых данных при смене выбранной секции (друзья и заявки)
    @objc private func segmentChanged() {
        if friendsView.segmentController.selectedSegmentIndex == 0 {
            currentAccounts = User.currentUser.friends!
        } else {
            currentAccounts = User.currentUser.friendsRequests!
        }
       
        friendsView.friendsTableView.reloadData()
    }
    
    /// Загрузка информации о друзьях или заявках пользователя в зависимости от выбранной секции
    @objc private func uploadFriends() {
        friendsView.loader.startAnimating()
        if friendsView.segmentController.selectedSegmentIndex == 0 {
            FriendsReequests.shared.getFriends(completion: {(accounts, error) in
                self.friendsView.loader.stopAnimating()
                self.friendsView.friendsTableView.refreshControl?.endRefreshing()
                if let error = error {
                    let alert = ErrorChecker.handler.getAlertController(error: error)
                    self.present(alert, animated: true, completion: nil)
                    self.friendsView.friendsTableView.refreshControl?.endRefreshing()
                    return
                }
                
                if let accounts = accounts {
                    User.currentUser.friends = accounts
                    self.currentAccounts = accounts
                    self.friendsView.friendsTableView.reloadData()
                }
            })
        } else {
            FriendsReequests.shared.getFriendRequests(completion: {(accounts, error) in
                self.friendsView.loader.stopAnimating()
                self.friendsView.friendsTableView.refreshControl?.endRefreshing()
                if let error = error {
                    let alert = ErrorChecker.handler.getAlertController(error: error)
                    self.present(alert, animated: true, completion: nil)
                    self.friendsView.loader.stopAnimating()
                    self.friendsView.friendsTableView.refreshControl?.endRefreshing()
                    return
                }
                
                if let accounts = accounts {
                    User.currentUser.friendsRequests = accounts
                    self.currentAccounts = accounts
                    self.friendsView.friendsTableView.reloadData()
                }
            })
        }
        
    }
    
    
    // MARK: TableView DataSource
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        var actions = [UIContextualAction]()
        
        if friendsView.segmentController.selectedSegmentIndex == 1 {
            actions.append(ContextualActionService.removeFriendAction(indexPath: indexPath, friendsVC: self))
            actions.append(ContextualActionService.addFriendAction(indexPath: indexPath, friendsVC: self))
        } else {
            actions.append(ContextualActionService.removeFriendAction(indexPath: indexPath, friendsVC: self))
        }
        
        let configuration = UISwipeActionsConfiguration(actions: actions)
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentAccounts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MeetingCell", for: indexPath) as! ViewFriendCell
        cell.account = currentAccounts[indexPath.row]
        cell.backgroundColor = UIColor(named: "BackgroundMain")
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = AccountVC()
        vc.account = currentAccounts[indexPath.row]
        vc.isUserAccount = false
        navigationController?.pushViewController(vc, animated: true)
    }
    
    /// Формирование панели навигации
    private func configNavigationBar()  {
        searchController?.searchBar.sizeToFit()
        searchController?.obscuresBackgroundDuringPresentation = true
        searchController?.searchBar.placeholder = "Искать друзей"
        searchController?.searchResultsUpdater = searchAccountsVC
        
        navigationItem.title = "Друзья"
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.searchController = searchController
    }
}
