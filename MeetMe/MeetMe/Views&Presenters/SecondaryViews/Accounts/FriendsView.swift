//
//  FriendsView.swift
//  MeetMe
//
//  Created by Stepan Ostapenko on 01.09.2022.
//

import UIKit

class FriendsView: UIView {

    /// Разделитель экрана на секции (друзья и запросы)
    let segmentController = UISegmentedControl(items: ["Друзья", "Запросы"])
    
    /// UI элемент, отображающий либо список друзей, либо список запросов в друзья
    let friendsTableView = UITableView()
    /// Идентификатор загрузки
    let loader = UIActivityIndicatorView()
    /// Идентификатор обновления данных
    private let refresher = UIRefreshControl()
    private let navigationController: UINavigationController
    private let tableViewDelegate: UITableViewDelegate
    private let tableViewDataSource: UITableViewDataSource
    
    init(navigationController: UINavigationController,
         tableViewDelegate: UITableViewDelegate,
         tableviewDataSource: UITableViewDataSource) {
        self.navigationController = navigationController
        self.tableViewDataSource = tableviewDataSource
        self.tableViewDelegate = tableViewDelegate
        super.init(frame: .zero)
        
        self.backgroundColor = UIColor(named: "BackgroundMain")
        
        configSegmentController()
        configMeetingTableView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Configs
    /// Формирование  и отображение разделителя экрана на секции
    private func configSegmentController() {
        self.addSubview(segmentController)
        segmentController.setConstraints(to: self, left: 30, top: 0, right: 30, height: 30)
        segmentController.selectedSegmentIndex = 0
    }
    
    
    /// Формирование и добавления на экран таблицы мероприятий
    private func configMeetingTableView() {
        friendsTableView.backgroundColor = UIColor(named: "BackgroundMain")
        friendsTableView.delegate = tableViewDelegate
        friendsTableView.dataSource = tableViewDataSource
        
        friendsTableView.register(ViewFriendCell.self, forCellReuseIdentifier: "MeetingCell")
        self.addSubview(friendsTableView)
        friendsTableView.backgroundView = loader
        friendsTableView.refreshControl = refresher
        friendsTableView.pinTop(to: segmentController.bottomAnchor, const: 10)
        friendsTableView.pinLeft(to: self.safeAreaLayoutGuide.leadingAnchor, const: 10)
        friendsTableView.pinRight(to: self.safeAreaLayoutGuide.trailingAnchor, const: 10)
        friendsTableView.pinBottom(to: self.safeAreaLayoutGuide.bottomAnchor, const: 0)
    }

}
