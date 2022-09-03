//
//  GroupScreenHeaderView.swift
//  MeetMe
//
//  Created by Stepan Ostapenko on 02.09.2022.
//

import UIKit

class GroupScreenHeaderView: UIView {

    /// Кнопка для вступления пользователя в группу
    let joinGroupButton = UIButton(type: .system)
    let viewParticipantsButton = UIButton(type: .system)
    /// Высота текстового поля для отображения информации о группе
    private var infoHeight = 0.0
    /// Высота текстового поля для оторажения интересов
    private var interestHeight = 0.0
    /// Группа
    var group: Group?
    
    init(group: Group) {
        super.init(frame: .zero)
        self.group = group
        self.backgroundColor = UIColor(named: "BackgroundMain")
        configView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configView() {
        backgroundColor = UIColor(named: "BackgroundMain")
        
        let groupImage = UIImageView()
        addSubview(groupImage)
        groupImage.setWidth(to: 250)
        groupImage.setHeight(to: 250)
        groupImage.pinTop(to: self.topAnchor, const: 5)
        groupImage.pinCenter(to: self.centerXAnchor, const: 0)
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
        self.addSubview(groupName)
        groupName.pinTop(to: groupImage.bottomAnchor, const: 10)
        groupName.pinCenter(to: self.centerXAnchor, const: 0)
        groupName.setWidth(to: 300)
        groupName.textAlignment = .center
        groupName.font = .boldSystemFont(ofSize: 18)
        
        self.addSubview(viewParticipantsButton)
        viewParticipantsButton.pinTop(to: groupName.bottomAnchor, const: 15)
        viewParticipantsButton.pinCenter(to: self.centerXAnchor, const: 0)
        viewParticipantsButton.pinLeft(to: self.leadingAnchor, const: 20)
        viewParticipantsButton.pinRight(to: self.trailingAnchor, const: 20)
        viewParticipantsButton.setHeight(to: 30)
        Styling.styleButton(viewParticipantsButton)
        viewParticipantsButton.setTitle("Участники", for: .normal)
        // viewParticipantsButton.addTarget(self, action: #selector(viewParticipants), for: .touchUpInside)
        
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
        
        self.addSubview(stackView)
        stackView.pinTop(to: viewParticipantsButton.bottomAnchor, const: 5)
        stackView.pinLeft(to: self.leadingAnchor, const: 20)
        stackView.pinRight(to: self.trailingAnchor, const: 20)
        stackView.setHeight(to: Int(infoHeight + interestHeight + joinHeieght))
        self.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 350 + infoHeight + interestHeight + joinHeieght)
        
    }
    
    /// Формирование раздела экрана с кнопкой для вступления в группу
    private func configJoinButton() -> UIView{
        let view = UIView()
        
        Styling.styleFilledButton(joinGroupButton)
        joinGroupButton.setTitle("Вступить в группу", for: .normal)
        joinGroupButton.setHeight(to: 40)
        // joinGroupButton.addTarget(self, action: #selector(joinGroup), for: .touchUpInside)
        
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

}
