//
//  MeetingsVC.swift
//  MeetMe
//
//  Created by Stepan Ostapenko on 24.02.2022.
//

import UIKit
import Network

/// Контроллер, отвечающий за отображение списка мероприятий
class MeetingsVC: UIViewController {
    /// Фильтр для поиска мероприятий
    let searchOptions = MeetingSearchFilter(types: [], online: false, participantsMax: 100)
    /// Контроллер для разделения экрана на секции (история посещенных мероприятий, предстоящие мероприятия и приглашения)
    let segmentController = UISegmentedControl(items: ["История", "Предстоящие", "Приглашения"])
    /// Контроллер поиска
    private var searchController: UISearchController?
    /// Контроллер, отображающий результаты поиска
    private let searchResultsVC = MeetingSearchResultsVC()
    /// UI элемент, отображающий список мероприятий
    let meetingTableView = UITableView()
    /// Индикатор загрузки
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    /// Список текущих просматриваемых пользоваетелем мероприятия
    var currentMeetings: [Meeting]? = [Meeting]()
    /// Индикатор обновления данных
    private let refreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
                
        meetingTableView.delegate = self
        meetingTableView.dataSource = self
        
        segmentController.selectedSegmentIndex = 1
        getMeetings(showLoader: true)
        
        searchController = UISearchController(searchResultsController: searchResultsVC)
        self.addChild(searchResultsVC)
        searchResultsVC.didMove(toParent: self)

        view.backgroundColor = UIColor(named: "BackgroundMain")
        
        configNavigationBar()
        configSegmentController()
        configMeetingTableView()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        reloadData()
    }
    
    ///  Обновление информации о мероприятиях в соответствии с выбранной секцией
    @objc private func reloadData() {
        switch segmentController.selectedSegmentIndex {
        case 0:
            if let meetingHistory = User.currentUser.meetingHistory {
                currentMeetings = meetingHistory
            } else {
                currentMeetings = []
                getMeetings(showLoader: true)
            }
        case 1:
            if let meetingsPlanned = User.currentUser.plannedMeetings {
                currentMeetings = meetingsPlanned
            } else {
                currentMeetings = []
                getMeetings(showLoader: true)
            }
        case 2:
            currentMeetings = nil
            if let _ = User.currentUser.meetingInvitations {
                meetingTableView.reloadData()
            } else {
                currentMeetings = nil
                getMeetings(showLoader: true)
            }
        default:
            break;
        }
        meetingTableView.reloadData()
    }
    
    /// Вызов обновления информации о мероприятиях
    @objc private func reloadUserMeetings() {
        getMeetings(showLoader: false)
    }
    
    /// Провекра наличия информации о мероприятиях пользователя и вызов загрузки информации при ее отсутствии
    private func updateUserMeetingTable(meetingType: MeetingType, meetings: [Meeting]?, error: Error?) {
        if let error = error {
            let alert = ErrorChecker.handler.getAlertController(error: error)
            self.present(alert, animated: true, completion: nil)
            self.activityIndicator.stopAnimating()
            self.meetingTableView.refreshControl?.endRefreshing()
            return
        }
        
        if let meetings = meetings {
            switch meetingType {
            case .visited:
                User.currentUser.meetingHistory = meetings
                self.currentMeetings = User.currentUser.meetingHistory!
            case .planned:
                User.currentUser.plannedMeetings = meetings
                self.currentMeetings = User.currentUser.plannedMeetings!
            default: break
            }
            self.activityIndicator.stopAnimating()
            self.meetingTableView.refreshControl?.endRefreshing()
            self.meetingTableView.reloadData()
            
        }
    }
    
    /// Обновление информации о приглашениях пользователя и его групп
    private func updateMeetingInvitations(meetings: UserInvitations?, error: Error?) {
        if let error = error {
            let alert = ErrorChecker.handler.getAlertController(error: error)
            self.present(alert, animated: true, completion: nil)
            self.activityIndicator.stopAnimating()
            self.meetingTableView.refreshControl?.endRefreshing()
            return
        }
        
        if let meetings = meetings {
            User.currentUser.meetingInvitations = meetings
            self.activityIndicator.stopAnimating()
            self.meetingTableView.refreshControl?.endRefreshing()
            self.meetingTableView.reloadData()
        }
    }
    
    /// Получение информации о мероприятиях в соответсвтии с meetingType (посещенные или запланированные)
    private func getMeetings(showLoader: Bool) {
        if showLoader {
            activityIndicator.startAnimating()
        }
        
        switch segmentController.selectedSegmentIndex {
        case 0:
            MeetingRequests.shared.getUserMeetings(meetingType: MeetingType.visited, completion: updateUserMeetingTable)
        case 1:
            MeetingRequests.shared.getUserMeetings(meetingType: MeetingType.planned, completion: updateUserMeetingTable)
        case 2:
            MeetingRequests.shared.getUserInvitations(completion: updateMeetingInvitations)
        default:
            break
        }
    }
    
    /// Отображение на экране контроллера, отвечающего за создание фильтра для поиска мероприятий
    @objc private func filterMeetingsSearch() {
        let searchFilterVC = SearchFilterVC()
        searchFilterVC.searchOptions = self.searchOptions
        if let sheet = searchFilterVC.sheetPresentationController {
            sheet.detents = [ .medium(), .large() ]
    
        }
        
        present(searchFilterVC, animated: true)
    }
    
    /// Переход на экран создания нового мероприятия
    @objc private func createMeeting() {
        navigationController?.pushViewController(CreateMeetingVC(), animated: true)
    }
    
    
    // MARK: Configs
    /// Формирование контроллера, отвечающего за секции приложения
    private func configSegmentController() {
        view.addSubview(segmentController)
        segmentController.setConstraints(to: view, left: 30, top: 0, right: 30, height: 30)
        segmentController.selectedSegmentIndex = 1
        segmentController.addTarget(self, action: #selector(reloadData), for: .valueChanged)
    }
    
    /// Форормирование панели навигации
    private func configNavigationBar()  {
        let filterButton = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(filterMeetingsSearch))
        let createMeetingButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(createMeeting))
        searchController?.searchBar.sizeToFit()
        searchController?.obscuresBackgroundDuringPresentation = false
        searchController?.searchBar.placeholder = "Искать мероприятия"
        
        navigationItem.title = "Мероприятия"
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.searchController = searchController
        navigationItem.leftBarButtonItem = filterButton
        navigationItem.rightBarButtonItem = createMeetingButton
    }
    
    ///  Формирование UI элемента, отображающего список мероприятий 
    private func configMeetingTableView() {
        
        refreshControl.addTarget(self, action: #selector(reloadUserMeetings), for: .valueChanged)
        meetingTableView.refreshControl = refreshControl
       
        self.searchController?.searchResultsUpdater = searchResultsVC
        meetingTableView.backgroundColor = UIColor(named: "BackgroundMain")
        meetingTableView.backgroundView = activityIndicator
        meetingTableView.register(MeetingCell.self, forCellReuseIdentifier: "MeetingCell")
        view.addSubview(meetingTableView)
        meetingTableView.pinTop(to: segmentController.bottomAnchor, const: 10)
        meetingTableView.pinLeft(to: view.safeAreaLayoutGuide.leadingAnchor, const: 10)
        meetingTableView.pinRight(to: view.safeAreaLayoutGuide.trailingAnchor, const: 10)
        meetingTableView.pinBottom(to: view.safeAreaLayoutGuide.bottomAnchor, const: 0)
    }
}


extension MeetingsVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        if let _ = currentMeetings {
            return 1
        }
        return User.currentUser.meetingInvitations?.count() ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let _ = currentMeetings {
            return currentMeetings!.count
        } else {
            if section == 0 {
                return User.currentUser.meetingInvitations?.personalInvitations.count ??  0
            }
            
            return User.currentUser.meetingInvitations!.groupInvitations[section - 1].meetings.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let _ = currentMeetings {
            return ""
        }
        if section == 0 {
            return "Мои приглашения"
        }
       
        return User.currentUser.meetingInvitations!.groupInvitations[section - 1].group.name
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 170
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let currentMeetings = currentMeetings {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MeetingCell", for: indexPath) as! MeetingCell
            cell.meeting = currentMeetings[indexPath.row]
            return cell
        }
        else {
            if indexPath.section == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "MeetingCell", for: indexPath) as! MeetingCell
                cell.meeting = User.currentUser.meetingInvitations!.personalInvitations[indexPath.row]
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "MeetingCell", for: indexPath) as! MeetingCell
                cell.meeting = User.currentUser.meetingInvitations!.groupInvitations[indexPath.section - 1].meetings[indexPath.row]
                return cell
            }
            
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch segmentController.selectedSegmentIndex {
        case 0:
            let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout.init()
            layout.scrollDirection = UICollectionView.ScrollDirection.vertical
            let vc = PhotoGalleryVC(collectionViewLayout: layout)
            vc.meeting = currentMeetings![indexPath.row]
            navigationController?.pushViewController(vc, animated: true)
        case 1:
            let vc = ChatVC()
            vc.meeting = currentMeetings![indexPath.row]
            navigationController?.pushViewController(vc, animated: true)
        case 2:
            if indexPath.section == 0 {
                let vc = MeetingInfoVC()
                vc.meeting = User.currentUser.meetingInvitations!.personalInvitations[indexPath.row]
                navigationController?.pushViewController(vc, animated: true)
            } else {
                let vc = MeetingInfoVC()
                vc.meeting = User.currentUser.meetingInvitations!.groupInvitations[indexPath.section - 1].meetings[indexPath.row]
                navigationController?.pushViewController(vc, animated: true)
            }
        default: break
        }
    }
    
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        var actions = [UIContextualAction]()
        switch segmentController.selectedSegmentIndex {
        case 0:
            let leaveAction = ContextualActionService.leaveMeetingAction(meetingType: .visited, indexPath: indexPath, meetingsVC: self)
            actions.append(leaveAction)
            
        case 1:
            let leaveAction = ContextualActionService.leaveMeetingAction(meetingType: .planned, indexPath: indexPath, meetingsVC: self)
            let deleteAction = ContextualActionService.deleteMeetingAction(indexPath: indexPath, meetingsVC: self)
            let editAction = UIContextualAction(style: .normal, title: "Редактировать") { _, _, complete in
                let vc = CreateMeetingVC()
                vc.meeting = self.currentMeetings![indexPath.row]
                self.navigationController?.pushViewController(vc, animated: true)
            }
            if currentMeetings![indexPath.row].creatorID == User.currentUser.account!.id {
                actions.append(editAction)
                actions.append(deleteAction)
            } else {
                actions.append(leaveAction)
            }
            
        case 2:
            let participateAction = ContextualActionService.inviteMeetingAction(participate: true, indexPath: indexPath, meetingsVC: self)
            let declineAction = ContextualActionService.inviteMeetingAction(participate: false, indexPath: indexPath, meetingsVC: self)
            actions.append(participateAction)
            actions.append(declineAction)
            
        default: break
        }
        
        let configuration = UISwipeActionsConfiguration(actions: actions)
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }
}
