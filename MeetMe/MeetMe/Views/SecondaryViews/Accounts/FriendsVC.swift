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
    /// Разделитель экрана на секции (друзья и запросы)
    let segmentController = UISegmentedControl(items: ["Друзья", "Запросы"])
    /// Контроллера поиска
    private var searchController: UISearchController?
    /// UI элемент, отображающий либо список друзей, либо список запросов в друзья
    private let friendsTableView = UITableView()
    /// Идентификатор загрузки
    private let loader = UIActivityIndicatorView()
    /// Идентификатор обновления данных
    private let refresher = UIRefreshControl()
    /// Контроллер, отвечающий за отображение результатов поиска
    private let searchAccountsVC = AccountSearchResultsVC()
    /// Список отображаемых аккаунтов
    private var currentAccounts = [Account]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(named: "BackgroundMain")
        friendsTableView.backgroundColor = UIColor(named: "BackgroundMain")
        friendsTableView.delegate = self
        friendsTableView.dataSource = self
        
        searchController = UISearchController(searchResultsController: searchAccountsVC)
        segmentController.selectedSegmentIndex = 0
        
        configNavigationBar()
        configSegmentController()
        configMeetingTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        reloadData()
    }
    
    ///  Обновление данных о друзьях и завявках в друзья
    @objc private func reloadData() {
        if segmentController.selectedSegmentIndex == 0 {
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
        friendsTableView.reloadData()
    }
    
    ///  Изменение отображемых данных при смене выбранной секции (друзья и заявки)
    @objc private func segmentChanged() {
        if segmentController.selectedSegmentIndex == 0 {
            currentAccounts = User.currentUser.friends!
        } else {
            currentAccounts = User.currentUser.friendsRequests!
        }
       
        friendsTableView.reloadData()
    }
    
    /// Загрузка информации о друзьях или заявках пользователя в зависимости от выбранной секции
    @objc private func uploadFriends() {
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
                    self.currentAccounts = accounts
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
                    self.currentAccounts = accounts
                    self.friendsTableView.reloadData()
                }
            })
        }
        
    }
    
    /// Создание UIContextualAction, добавляющего аккаунт в друзья
    private func addFriendAction(indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .normal, title: "Добавить в друзья") {[weak self] (_,_,_) in
            FriendsReequests.shared.makeFriendRequest(recieverId: self!.currentAccounts[indexPath.row].id, completion: {(error) in
                if let error = error {
                    let alert = ErrorChecker.handler.getAlertController(error: error)
                    self?.present(alert, animated: true, completion: nil)
                    return
                }
                
                let index = User.currentUser.friendsRequests?.firstIndex(of: self!.currentAccounts[indexPath.row])
                User.currentUser.friends?.append(User.currentUser.friendsRequests![index!])
                User.currentUser.friendsRequests?.remove(at: index!)
                self?.currentAccounts.remove(at: index!)
                self?.friendsTableView.deleteRows(at: [indexPath], with: .automatic)
                self?.friendsTableView.reloadData()
            })
        }
        action.backgroundColor = .systemGreen
        return action
    }
    
    /// Создание UIContextualAction, удаляющего аккаунт из списка друзей 
    private func removeFriendAction(indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .destructive, title: "Удалить") {[weak self] (_,_,_) in
            FriendsReequests.shared.deleteFriend(recieverId: self!.currentAccounts[indexPath.row].id, completion: {(error) in
                if let error = error {
                    let alert = ErrorChecker.handler.getAlertController(error: error)
                    self?.present(alert, animated: true, completion: nil)
                    return
                }
                var index: Int?
                if User.currentUser.friends!.contains(self!.currentAccounts[indexPath.row]) {
                    index = User.currentUser.friends?.firstIndex(of: self!.currentAccounts[indexPath.row])
                    User.currentUser.friends?.remove(at: index!)
                } else {
                    index = User.currentUser.friendsRequests?.firstIndex(of: self!.currentAccounts[indexPath.row])
                    User.currentUser.friendsRequests?.remove(at: index!)
                }
                self?.currentAccounts.remove(at: index!)
                self?.friendsTableView.deleteRows(at: [indexPath], with: .automatic)
                self?.friendsTableView.reloadData()
            })
        }
        
        return action
    }
    
    // MARK: TableView DataSource
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
    
   // MARK: Configs
    /// Формирование  и отображение разделителя экрана на секции
    private func configSegmentController() {
        view.addSubview(segmentController)
        segmentController.setConstraints(to: view, left: 30, top: 0, right: 30, height: 30)
        segmentController.selectedSegmentIndex = 0
        segmentController.addTarget(self, action: #selector(reloadData), for: .valueChanged)
    }
    
    /// Формирование панели навигации
    private func configNavigationBar()  {
        searchController?.searchBar.sizeToFit()
        searchController?.obscuresBackgroundDuringPresentation = true
        searchController?.searchBar.placeholder = "Search meetings"
        searchController?.searchResultsUpdater = searchAccountsVC
        
        navigationItem.title = "Друзья"
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.searchController = searchController
    }
    
    /// Формирование и добавления на экран таблицы мероприятий
    private func configMeetingTableView() {
        friendsTableView.register(ViewFriendCell.self, forCellReuseIdentifier: "MeetingCell")
        view.addSubview(friendsTableView)
        friendsTableView.backgroundView = loader
        refresher.addTarget(self, action: #selector(uploadFriends), for: .valueChanged)
        friendsTableView.refreshControl = refresher
        friendsTableView.pinTop(to: segmentController.bottomAnchor, const: 10)
        friendsTableView.pinLeft(to: view.safeAreaLayoutGuide.leadingAnchor, const: 10)
        friendsTableView.pinRight(to: view.safeAreaLayoutGuide.trailingAnchor, const: 10)
        friendsTableView.pinBottom(to: view.safeAreaLayoutGuide.bottomAnchor, const: 0)
    }

}
