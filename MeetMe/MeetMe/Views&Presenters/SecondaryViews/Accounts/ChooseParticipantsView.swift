//
//  ChooseParticipantsView.swift
//  MeetMe
//
//  Created by Stepan Ostapenko on 01.09.2022.
//

import UIKit

class ChooseParticipantsView: UIView {

    /// Разделитель экрана на секции (друзья и группы)
    let segmentController = UISegmentedControl(items: ["Друзья", "Группы"])
    /// Контроллер поиска
    let searchController = UISearchController(searchResultsController: nil)
    /// Таблица с выбором участников
    let participantTableView = UITableView()
    /// Идентификатор загрузки
    let loader = UIActivityIndicatorView()
    /// Идентификатор обновления данных
    let refresher = UIRefreshControl()
    private let includeGroups: Bool
    private let searchResultDelegate: UISearchResultsUpdating
    private let navigationController: UINavigationController
    private let tableViewDelegate: UITableViewDelegate
    private let tableViewDataSource: UITableViewDataSource
    
    init(includeGroups: Bool = false, searchResultUpdating: UISearchResultsUpdating,
         navigationController: UINavigationController,
         tableViewDelegate: UITableViewDelegate,
         tableviewDataSource: UITableViewDataSource) {
        
        
        participantTableView.backgroundColor = UIColor(named: "BackgroundMain")
        self.includeGroups = includeGroups
        self.searchResultDelegate = searchResultUpdating
        self.navigationController = navigationController
        self.tableViewDataSource = tableviewDataSource
        self.tableViewDelegate = tableViewDelegate
        super.init(frame: .zero)
        configSegmentController()
        configMeetingTableView()
        
        self.backgroundColor = UIColor(named: "BackgroundMain")
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Configs
    /// Формирование и отображение разделителя экрана на секции
    private func configSegmentController() {
        if includeGroups {
            self.addSubview(segmentController)
            segmentController.selectedSegmentIndex = 0
            segmentController.setConstraints(to: self, left: 30, top: 0, right: 30, height: 30)
        }
    }
    
    
    /// Формирование и добавление на экран списка мероприятий
    func configMeetingTableView() {
        participantTableView.register(AddParticipantCell.self, forCellReuseIdentifier: "cell")
        self.addSubview(participantTableView)
        if includeGroups {
            participantTableView.pinTop(to: segmentController.bottomAnchor, const: 10)
        } else {
            participantTableView.pinTop(to: self.safeAreaLayoutGuide.topAnchor, const: 10)
        }
        participantTableView.dataSource = self.tableViewDataSource
        participantTableView.delegate = self.tableViewDelegate
        participantTableView.refreshControl = refresher
        participantTableView.backgroundView = loader
        participantTableView.pinLeft(to: self.safeAreaLayoutGuide.leadingAnchor, const: 10)
        participantTableView.pinRight(to: self.safeAreaLayoutGuide.trailingAnchor, const: 10)
        participantTableView.pinBottom(to: self.safeAreaLayoutGuide.bottomAnchor, const: 10)
    }
}
