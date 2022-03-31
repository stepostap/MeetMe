//
//  GroupScreen.swift
//  MeetMe
//
//  Created by Stepan Ostapenko on 23.03.2022.
//

import UIKit

class GroupScreen: UITableViewController {

    var group: Group?
    
    var groupMeetings = [Meeting]()
    
    var infoHeight = 0.0
    var interestHeight = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let optionsButton = UIBarButtonItem(title: ". . .", style: .plain, target: self, action: #selector(showGroupActions))
        navigationItem.rightBarButtonItem = optionsButton
        
        let meeting1 = Meeting(id: 1, creatorID: 1, name: "Настолки", types: [.tabletopGames], info: "Собираемся играть в настолки, в первую очередь в ДНД", online: false, isPrivate: false, participants: [1], groups: [], participantsMax: 10, Location: "ETO кофейня", startingDate: Date.distantFuture, endingDate: Date.distantFuture, currentParticipantNumber: 1)
        
        let meeting2 = Meeting(id: 2, creatorID: 1, name: "ДР Коли", types: [.tabletopGames, .bar, .cinema, .photography], info: "Отмечать будем у меня на даче, всех жду!", online: false, isPrivate: true, participants: [1, 2], groups: [], participantsMax: 20, Location: "Улица Пушкина, дом Калатушкина dks jhdfbv sjdhb vskjdbv sjdkfh bvjskdfhb vsdjfhb vsjkdf bvsjkd fhbv sdj kfhbvjsdhf bvsjdhfbvjs kdfhbvsjd khfbvj sdhfbvjsdhfb vsjdhf bvsjdfhbvjsk dhfbvsj kdhfbvsjdhfbv", startingDate: Date.distantFuture, endingDate: Date.distantFuture, currentParticipantNumber: 5)
        self.tableView.register(ExtendedMeetingCell.self, forCellReuseIdentifier: "meetingCell")
        groupMeetings.append(meeting1)
        groupMeetings.append(meeting2)
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.tableHeaderView = configHeaderView()
        
        GroupRequests.shared.getGroupMeetings(groupID: group!.id, completion: {(meetings, error) in
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
    
    func leaveGroup(action: UIAlertAction) {
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
    
    func editGroup(action: UIAlertAction) {
        let vc = CreateGroupVC()
        vc.group = group
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func deleteGoup(action: UIAlertAction) {
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
    
    @objc func showGroupActions() {
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
    
    @objc func viewParticipants()  {
        let vc = ViewParticipantsVC()
        vc.group = group
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func configHeaderView() -> UIView {
        let view = UIView()
        view.backgroundColor = .systemGray4
        
        let groupImage = UIImageView()
        view.addSubview(groupImage)
        groupImage.setWidth(to: 250)
        groupImage.setHeight(to: 250)
        groupImage.pinTop(to: view.topAnchor, const: 5)
        groupImage.pinCenter(to: view.centerXAnchor, const: 0)
        groupImage.image = UIImage(named: "placeholder")
        
        let groupName = UILabel()
        groupName.text = group?.groupName
        view.addSubview(groupName)
        groupName.pinTop(to: groupImage.bottomAnchor, const: 10)
        groupName.pinCenter(to: view.centerXAnchor, const: 0)
        groupName.pinLeft(to: view.leadingAnchor, const: 20)
        groupName.pinRight(to: view.trailingAnchor, const: 20)
        groupName.textAlignment = .center
        groupName.font = .boldSystemFont(ofSize: 18)
        
        let viewParticipantsButton = UIButton()
        view.addSubview(viewParticipantsButton)
        viewParticipantsButton.pinTop(to: groupName.bottomAnchor, const: 5)
        viewParticipantsButton.pinCenter(to: view.centerXAnchor, const: 0)
        viewParticipantsButton.pinLeft(to: view.leadingAnchor, const: 0)
        viewParticipantsButton.pinRight(to: view.trailingAnchor, const: 0)
        viewParticipantsButton.setHeight(to: 30)
        viewParticipantsButton.layer.borderWidth = 1
        viewParticipantsButton.layer.borderColor = UIColor.systemGray.cgColor
        viewParticipantsButton.setTitle("Участники", for: .normal)
        viewParticipantsButton.setTitleColor(.darkGray, for: .normal)
        viewParticipantsButton.addTarget(self, action: #selector(viewParticipants), for: .touchUpInside)
        
        let stackView = UIStackView()
        //stackView.distribution = .equalSpacing
        stackView.axis  = NSLayoutConstraint.Axis.vertical
        
        
        if !(group?.groupInfo.isEmpty ?? true) {
            stackView.addArrangedSubview(configInfoView())
        }
        
        if !(group?.interests.isEmpty ?? true) {
            stackView.addArrangedSubview(configInterestsView())
            
        }
        
        view.addSubview(stackView)
        stackView.pinTop(to: viewParticipantsButton.bottomAnchor, const: 5)
        stackView.pinLeft(to: view.leadingAnchor, const: 20)
        stackView.pinRight(to: view.trailingAnchor, const: 20)
        stackView.setHeight(to: Int(infoHeight + interestHeight))
        view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 350 + infoHeight + interestHeight)
        return view
    }
    
    func configInfoView() -> UIView {
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
        info.isScrollEnabled = false
        infotextHeight = info.text.heightWithConstrainedWidth(width: UIScreen.main.bounds.width - 40, font: .systemFont(ofSize: 16))
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
    
    func configInterestsView() -> UIView {
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
        interests.text = Utilities.getInterests(interestArray: group?.interests ?? [])
        interests.layer.borderWidth = 1
        interests.layer.borderColor = UIColor.systemGray.cgColor
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
        let interestsText = Utilities.getInterests(interestArray: groupMeetings[indexPath.row].types)
        let interestsHeight = interestsText.heightWithConstrainedWidth(width: width, font: .systemFont(ofSize: 15))
        return 150 + locationHeight + interestsHeight
    }
}
