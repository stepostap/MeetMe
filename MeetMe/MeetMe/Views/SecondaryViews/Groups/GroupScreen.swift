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
    /// Высота текстового поля для отображения информации о группе
    private var infoHeight = 0.0
    /// Высота текстового поля для оторажения интересов
    private var interestHeight = 0.0
    /// Кнопка для вступления пользователя в группу
    private let joinGroupButton = UIButton(type: .system)
    /// Идентификатор обновления информации о группе
    private let refresher = UIRefreshControl()
    
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
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.tableHeaderView = configHeaderView()
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
            self.tableView.tableHeaderView = self.configHeaderView()
        })
    }
    
    // MARK: Configs
    /// Формирование раздела экрана с полной информацией о группе
    private func configHeaderView() -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor(named: "BackgroundMain")
        
        let groupImage = UIImageView()
        view.addSubview(groupImage)
        groupImage.setWidth(to: 250)
        groupImage.setHeight(to: 250)
        groupImage.pinTop(to: view.topAnchor, const: 5)
        groupImage.pinCenter(to: view.centerXAnchor, const: 0)
        Styling.styleImageView1(groupImage)
        if group!.groupImageURL.isEmpty {
            groupImage.image = UIImage(named: "placeholder")
        } else {
            groupImage.kf.indicatorType = .activity
            groupImage.kf.setImage(with: URL(string: group!.groupImageURL), options: [.forceRefresh])
        }
        
        let groupName = UITextField(frame: CGRect(x: 0, y: 0, width: 300, height: 30))
        Styling.styleTextField(groupName)
        groupName.text = group?.groupName
        view.addSubview(groupName)
        groupName.pinTop(to: groupImage.bottomAnchor, const: 10)
        groupName.pinCenter(to: view.centerXAnchor, const: 0)
        groupName.setWidth(to: 300)
        groupName.textAlignment = .center
        groupName.font = .boldSystemFont(ofSize: 18)
        
        let viewParticipantsButton = UIButton(type: .system)
        view.addSubview(viewParticipantsButton)
        viewParticipantsButton.pinTop(to: groupName.bottomAnchor, const: 15)
        viewParticipantsButton.pinCenter(to: view.centerXAnchor, const: 0)
        viewParticipantsButton.pinLeft(to: view.leadingAnchor, const: 20)
        viewParticipantsButton.pinRight(to: view.trailingAnchor, const: 20)
        viewParticipantsButton.setHeight(to: 30)
        Styling.styleButton(viewParticipantsButton)
        viewParticipantsButton.setTitle("Участники", for: .normal)
        viewParticipantsButton.addTarget(self, action: #selector(viewParticipants), for: .touchUpInside)
        
        let stackView = UIStackView()
        stackView.axis  = NSLayoutConstraint.Axis.vertical
        
        if !(group?.groupInfo.isEmpty ?? true) {
            stackView.addArrangedSubview(configInfoView())
        }
        
        if !(group?.interests.isEmpty ?? true) {
            stackView.addArrangedSubview(configInterestsView())
        }
        
        var joinHeieght = 0.0
        if !User.currentUser.groups!.contains(group!) {
            stackView.addArrangedSubview(configJoinButton())
            joinHeieght+=60
        }
        
        view.addSubview(stackView)
        stackView.pinTop(to: viewParticipantsButton.bottomAnchor, const: 5)
        stackView.pinLeft(to: view.leadingAnchor, const: 20)
        stackView.pinRight(to: view.trailingAnchor, const: 20)
        stackView.setHeight(to: Int(infoHeight + interestHeight + joinHeieght))
        view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 350 + infoHeight + interestHeight + joinHeieght)
        return view
    }
    
    /// Формирование раздела экрана с кнопкой для вступления в группу
    private func configJoinButton() -> UIView{
        let view = UIView()
        
        Styling.styleFilledButton(joinGroupButton)
        joinGroupButton.setTitle("Вступить в группу", for: .normal)
        joinGroupButton.setHeight(to: 40)
        joinGroupButton.addTarget(self, action: #selector(joinGroup), for: .touchUpInside)
        
        view.addSubview(joinGroupButton)
        joinGroupButton.setConstraints(to: view, left: 0, top: 10, right: 0, bottom: 10)
        view.setHeight(to: 60)
        return view
    }
    
    /// Формирование раздела экрана с информацией о группе
    private func configInfoView() -> UIView {
        let view = UIView()
        var infotextHeight = 0.0
        
        let label = UILabel()
        label.text = "О группе"
        view.addSubview(label)
        label.pinTop(to: view.topAnchor, const: 10)
        label.pinLeft(to: view.leadingAnchor, const: 10)
        label.setHeight(to: 30)
        label.setWidth(to: 170)
        label.textColor = .systemGray
        
        let info = UITextView()
        view.addSubview(info)
        info.text = group?.groupInfo
        info.layer.borderWidth = 1
        info.layer.borderColor = UIColor.systemGray.cgColor
        info.backgroundColor = UIColor(named: "BackgroundDarker")
        info.isScrollEnabled = false
        infotextHeight = info.text.heightWithConstrainedWidth(width: UIScreen.main.bounds.width - 100, font: .systemFont(ofSize: 16))
        info.pinTop(to: label.bottomAnchor, const: 0)
        info.setHeight(to: Int(infotextHeight) +  15)
        info.pinLeft(to: view.leadingAnchor, const: 0)
        info.pinRight(to: view.trailingAnchor, const: 0)
        info.font = .systemFont(ofSize: 16)
        info.layer.cornerRadius = 10
        info.isUserInteractionEnabled = false
        
        infoHeight = infotextHeight + 55
        view.setHeight(to: Int(infoHeight))
        return view
    }
    
    /// Формирование раздела экрана с интересами группы
    private func configInterestsView() -> UIView {
        let view = UIView()
        var intereststextHeight = 0.0
        
        let label = UILabel()
        label.text = "Интересы"
        view.addSubview(label)
        label.pinTop(to: view.topAnchor, const: 10)
        label.pinLeft(to: view.leadingAnchor, const: 10)
        label.setHeight(to: 30)
        label.setWidth(to: 170)
        label.textColor = .systemGray
        
        let interests = UITextView()
        view.addSubview(interests)
        interests.text = Styling.getInterests(interestArray: group?.interests ?? [])
        interests.layer.borderWidth = 1
        interests.layer.borderColor = UIColor.systemGray.cgColor
        interests.backgroundColor = UIColor(named: "BackgroundDarker")
        interests.isScrollEnabled = false
        intereststextHeight = interests.text.heightWithConstrainedWidth(width: UIScreen.main.bounds.width - 40, font: .systemFont(ofSize: 16))
        interests.pinTop(to: label.bottomAnchor, const: 0)
        interests.setHeight(to: Int(intereststextHeight +  15))
        interests.pinLeft(to: view.leadingAnchor, const: 0)
        interests.pinRight(to: view.trailingAnchor, const: 0)
        interests.font = .systemFont(ofSize: 16)
        interests.layer.cornerRadius = 10
        interests.isUserInteractionEnabled = false
        
        interestHeight = 55 + intereststextHeight
        view.setHeight(to: 55 + Int(intereststextHeight))
        return view
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
