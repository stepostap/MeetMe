//
//  GroupScreen.swift
//  MeetMe
//
//  Created by Stepan Ostapenko on 23.03.2022.
//

import UIKit
import SwiftUI

/// Контроллер, отвечающий за отображение информации и мероприятий группы
class GroupScreen: UITableViewController {
    /// Группа
    var group: Group?
    /// Меероприя группы
    private var groupMeetings = [Meeting]()
    /// Идентификатор обновления информации о группе
    private let refresher = UIRefreshControl()
    private var groupScreenHeaderView: GroupScreenHeaderView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "BackgroundMain")
        let optionsButton = UIBarButtonItem(title: ". . .", style: .plain, target: self, action: #selector(showGroupActions))
        navigationItem.rightBarButtonItem = optionsButton
        self.navigationController?.navigationBar.barTintColor = UIColor(named: "BackgroundDarker")
        self.tableView.register(ExtendedMeetingCell.self, forCellReuseIdentifier: "meetingCell")
        refresher.addTarget(self, action: #selector(getGroupMeetings), for: .valueChanged)
        self.tableView.refreshControl = refresher
    }
    
    func configHeaderView() {
        if let group = group {
            groupScreenHeaderView = GroupScreenHeaderView(group: group)
            groupScreenHeaderView.viewParticipantsButton.addTarget(self, action: #selector(viewParticipants), for: .touchUpInside)
            groupScreenHeaderView.joinGroupButton.addTarget(self, action: #selector(joinGroup), for: .touchUpInside)
            self.tableView.tableHeaderView = groupScreenHeaderView
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        configHeaderView()
        getGroupMeetings()
    }
    
    /// Получение данных о мероприятиях группы
    @objc private func getGroupMeetings() {
        GroupRequests.shared.getGroupMeetings(groupID: group!.id, completion: {(meetings, error) in
            self.refresher.endRefreshing()
            if let error = error {
                let alert = ErrorChecker.handler.getAlertController(error: error)
                self.present(alert, animated: true, completion: nil)
                return
            }
            if let meetings = meetings {
                self.groupMeetings = meetings
                self.tableView.reloadData()
            }
        })
    }
    
    /// Отписка пользователя от группы
    private func leaveGroup(action: UIAlertAction) {
        GroupRequests.shared.leaveGroup(groupID: group!.id, completion: {(error) in
            if let error = error {
                let alert = ErrorChecker.handler.getAlertController(error: error)
                self.present(alert, animated: true, completion: nil)
                return
            }
            let index = User.currentUser.groups!.firstIndex(of: self.group!)
            if let index = index {
                User.currentUser.groups!.remove(at: index)
            }
            self.navigationController?.popViewController(animated: true)
        })
    }
    
    /// Переход на экран редактирования группы
    private func editGroup(action: UIAlertAction) {
        let vc = CreateGroupVC()
        vc.group = group
        vc.completion = { (group) in
            self.group = group
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    /// Удаление группы
    private func deleteGoup(action: UIAlertAction) {
        GroupRequests.shared.deleteGroup(groupID: group!.id, completion: {(error) in
            if let error = error {
                let alert = ErrorChecker.handler.getAlertController(error: error)
                self.present(alert, animated: true, completion: nil)
                return
            }
            let index = User.currentUser.groups!.firstIndex(of: self.group!)
            if let index = index {
                User.currentUser.groups!.remove(at: index)
            }
            self.navigationController?.popViewController(animated: true)
        })
    }
    
    /// Отображение вариантов действий с группой (отписка, удаление, редактирование)
    @objc private func showGroupActions() {
        let alert = UIAlertController(title: group?.groupName, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Отменить", style: .cancel, handler: nil))
        
        let leaveAction = UIAlertAction(title: "Покинуть группу", style: .destructive, handler: leaveGroup)
        let editAction = UIAlertAction(title: "Редактировать группу", style: .default, handler: editGroup)
        let deleteAction = UIAlertAction(title: "Удалить группу", style: .destructive, handler: deleteGoup)
        
        if group!.admins.contains(User.currentUser.account!.id) {
            alert.addAction(editAction)
            alert.addAction(deleteAction)
        } else {
            alert.addAction(leaveAction)
        }
        present(alert, animated: true)
    }
    
    /// Просмотр участников группы
    @objc private func viewParticipants()  {
        let vc = ViewParticipantsVC()
        vc.group = group
        navigationController?.pushViewController(vc, animated: true)
    }
    
    /// Подписка на группу
    @objc private func joinGroup() {
        GroupRequests.shared.addNewGroupParticipants(participants: [User.currentUser.account!.id], groupID: group!.id, completion: {(error) in
            if let error = error {
                let alert = ErrorChecker.handler.getAlertController(error: error)
                self.present(alert, animated: true, completion: nil)
                return
            }
            User.currentUser.groups!.append(self.group!)
            self.configHeaderView()
            // self.tableView.tableHeaderView = self.configHeaderView()
        })
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return groupMeetings.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "meetingCell", for: indexPath) as! ExtendedMeetingCell
        cell.meeting = groupMeetings[indexPath.row]
        cell.backgroundColor = UIColor(named: "BackgroundDarker")
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = MeetingInfoVC()
        vc.meeting = groupMeetings[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
        self.tableView.deselectRow(at: indexPath, animated: false)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let width = UIScreen.main.bounds.width - 20
        let locationHeight = groupMeetings[indexPath.row].Location
            .heightWithConstrainedWidth(width: width, font: .systemFont(ofSize: 15))
        let interestsText = Styling.getInterests(interestArray: groupMeetings[indexPath.row].types)
        let interestsHeight = interestsText.heightWithConstrainedWidth(width: width, font: .systemFont(ofSize: 15))
        return 170 + locationHeight + interestsHeight
    }
}
