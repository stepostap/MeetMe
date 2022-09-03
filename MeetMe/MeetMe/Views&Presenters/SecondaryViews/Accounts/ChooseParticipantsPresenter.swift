//
//  ChooseParticipantsVC.swift
//  MeetMe
//
//  Created by Stepan Ostapenko on 21.03.2022.
//

import UIKit
import Network

/// Организация выбора друзей и групп пользователя для рассылки приглашений
class ChooseParticipantsVC: UIViewController {

    
    /// Идентификаторы выбранных друзей
    var chosenFriendIDs = [Int64]()
    /// Идентификаторы выбранных групп
    var chosenGroupIDs = [Int64]()
    /// Следует ли предлагать пользователю выбирать группы
    var includeGroups = false
    /// Идентификаторы уже приглашенных друзей
    var alreadyAddedFriends = [Int64]()
    /// Список текущих друзей пользователя
    private var currentUserFriends: [Account]?
    /// Список текущих групп пользователя
    private var currentUserGroups: [Group]?
    /// Метод, который будет вызван при закрытии данного экрана, для передачи данных о выбранных друзьях и группах
    var passData: ((_ friendIDs: [Int64], _ groupIDs: [Int64]) -> (Void))?
    
    var participantView: ChooseParticipantsView!
    
    override func viewWillAppear(_ animated: Bool) {
        configView()
        uploadInfo()
        
        if let friends = User.currentUser.friends {
            currentUserFriends = friends
        }
        
        if let groups = User.currentUser.groups {
            currentUserGroups = groups
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        passData?(chosenFriendIDs, chosenGroupIDs)
    }
    
    private func configView() {
        participantView = ChooseParticipantsView(includeGroups: includeGroups, searchResultUpdating: self, navigationController: navigationController!, tableViewDelegate: self, tableviewDataSource: self)
        participantView.refresher.addTarget(self, action: #selector(refreshInfo), for: .valueChanged)
        participantView.segmentController.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        self.view = participantView
        configNavigationBar()
    }
    
    /// Формирование панели навигации
    private func configNavigationBar()  {
        participantView.searchController.searchBar.sizeToFit()
        participantView.searchController.searchResultsUpdater = self
        participantView.searchController.obscuresBackgroundDuringPresentation = false
        participantView.searchController.searchBar.placeholder = "Искать участников"
        
        navigationItem.title = "Участники"
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.searchController = participantView.searchController
    }
    
    /// Обновление информации о друзьях и группах пользователя
    @objc private func refreshInfo() {
        if participantView.segmentController.selectedSegmentIndex == 1 {
            GroupRequests.shared.getUserGroups(completion: {(groups, error) in
                self.participantView.loader.stopAnimating()
                self.participantView.refresher.endRefreshing()
                if let error = error {
                    let alert = ErrorChecker.handler.getAlertController(error: error)
                    self.present(alert, animated: true, completion: nil)
                    return
                }
                if let groups = groups {
                    User.currentUser.groups = groups
                    self.currentUserGroups = groups
                    self.participantView.participantTableView.reloadData()
                }
                self.participantView.participantTableView.reloadData()
            })
        } else {
            FriendsReequests.shared.getFriends(completion: {(friends, error) in
                self.participantView.loader.stopAnimating()
                self.participantView.refresher.endRefreshing()
                if let error = error {
                    let alert = ErrorChecker.handler.getAlertController(error: error)
                    self.present(alert, animated: true, completion: nil)
                    return
                }
                if let friends = friends {
                    User.currentUser.friends = friends
                    self.currentUserFriends = friends
                }
                self.participantView.participantTableView.reloadData()
            })
        }
    }
    
    /// Проверка наличия данных о текующих друзьях и группах пользователя, при их отсутствии вызывается метод refreshInfo, обновляющий данную информацию
    private func uploadInfo() {
        if User.currentUser.groups == nil {
            participantView.loader.startAnimating()
            refreshInfo()
        } else {
            currentUserGroups = User.currentUser.groups!
        }
        if User.currentUser.friends == nil {
            participantView.loader.startAnimating()
            refreshInfo()
        } else {
            currentUserFriends = User.currentUser.friends!
        }
    }
    
    /// Добавление или удаление из списка выбранных друзей друга с ID
    private func friendIDChanged(checked: Bool, ID: Int64) {
        if checked {
            chosenFriendIDs.append(ID)
        } else {
            let index = chosenFriendIDs.firstIndex(of: ID)
            if let index = index {
                chosenFriendIDs.remove(at: index)
            }
        }
        
    }
    
    /// Добавление или удаление из списка выбранных групп группы с ID
    private func groupIDChanged(checked: Bool, ID: Int64) {
        if checked {
            chosenGroupIDs.append(ID)
        } else {
            let index = chosenGroupIDs.firstIndex(of: ID)
            if let index = index {
                chosenGroupIDs.remove(at: index)
            }
        }
    }
    
    /// Отобрадение новой информации после изменения пользователем выбранной секции (друзья,  группы)
    @objc private func segmentChanged() {
        uploadInfo()
        participantView.participantTableView.reloadSections(IndexSet(integer: 0), with: .none)
    }
}

// MARK: TableView DataSource
extension ChooseParticipantsVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if participantView.segmentController.selectedSegmentIndex == 1 {
            return currentUserGroups?.count ?? 0
        } else {
            return currentUserFriends?.count ??  0
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! AddParticipantCell
        cell.backgroundColor = UIColor(named: "BackgroundMain")
        if participantView.segmentController.selectedSegmentIndex == 1 {
            let group = currentUserGroups![indexPath.row]
            cell.nameLabel.text = group.groupName
            cell.participantID = group.id
            cell.checkboxChanged = groupIDChanged
            if chosenGroupIDs.contains(cell.participantID!) {
                cell.checkbox.isChecked = true
            } else {
                cell.checkbox.isChecked = false
            }
            if !group.groupImageURL.isEmpty {
                let url = URL(string: group.groupImageURL)
                cell.participantImage.kf.indicatorType = .activity
                cell.participantImage.kf.setImage(with: url, options: [ .cacheOriginalImage ])
            }
        } else {
            let account = currentUserFriends![indexPath.row]
            cell.nameLabel.text = account.name
            cell.participantID = account.id
            cell.checkboxChanged = friendIDChanged
            if chosenFriendIDs.contains(cell.participantID!) {
                cell.checkbox.isChecked = true
            } else {
                cell.checkbox.isChecked = false
            }
            if !account.imageDataURL.isEmpty {
                let url = URL(string: account.imageDataURL)
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
}

// MARK: SearchConontroller Delegate
extension ChooseParticipantsVC: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if participantView.segmentController.selectedSegmentIndex == 1 {
            GroupRequests.shared.getFilteredGroups(query: searchController.searchBar.text ?? "", filter: [], completion: {(groups, error) in
                if let groups = groups {
                    self.currentUserGroups = groups[0]
                    self.participantView.participantTableView.reloadData()
                }
            })
        } else {
            FriendsReequests.shared.searchFriends(query: searchController.searchBar.text ?? "", completion: {(accounts, error) in
                if let accounts = accounts {
                    self.currentUserFriends = accounts[0]
                    self.participantView.participantTableView.reloadData()
                }
            })
        }
    }
}
