//
//  MeetingsVC.swift
//  MeetMe
//
//  Created by Stepan Ostapenko on 24.02.2022.
//

import UIKit
import Network

class MeetingsVC: UIViewController, UISearchResultsUpdating, UITableViewDelegate, UITableViewDataSource {
    

    let searchOptions = MeetingSearchFilter(types: [], online: false, participantsMax: 100,
                                            startingDate: Date.now, endingDate: Date.distantFuture)
    
    let segmentController = UISegmentedControl(items: ["История", "Предстоящие", "Приглашения"])
    let searchController = UISearchController(searchResultsController: nil)
    let meetingTableView = UITableView()
    let activityIndicator = UIActivityIndicatorView(style: .large)
    
    var currentMeetings: [Meeting]? = [Meeting]()
    
    let refreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
                
        meetingTableView.delegate = self
        meetingTableView.dataSource = self
        
        segmentController.selectedSegmentIndex = 1
        getMeetings(showLoader: true)
        //currentMeetings = User.currentUser.plannedMeetings
        //meetingTableView.reloadData()
        
        view.backgroundColor = .systemBackground
        
        configNavigationBar()
        configSegmentController()
        configMeetingTableView()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        reloadData()
    }
    
    
    @objc func reloadData() {
        
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
    
    
    @objc func reloadUserMeetings() {
        getMeetings(showLoader: false)
    }
    
    
    func updateUserMeetingTable(meetingType: String, meetings: [Meeting]?, error: Error?) {
        
        if let error = error {
            let alert = ErrorChecker.handler.getAlertController(error: error)
            self.present(alert, animated: true, completion: nil)
            self.activityIndicator.stopAnimating()
            self.meetingTableView.refreshControl?.endRefreshing()
            return
        }
        
        if let meetings = meetings {
            switch meetingType {
            case "visited":
                User.currentUser.meetingHistory = meetings
                self.currentMeetings = User.currentUser.meetingHistory!
            case "planned":
                User.currentUser.plannedMeetings = meetings
                self.currentMeetings = User.currentUser.plannedMeetings!
            default: break
            }
            self.activityIndicator.stopAnimating()
            self.meetingTableView.refreshControl?.endRefreshing()
            self.meetingTableView.reloadData()
            
        }
    }
    
    
    func updateMeetingInvitations(meetings: UserInvitations?, error: Error?) {
        
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
    
    func getMeetings(showLoader: Bool) {
        if showLoader {
            activityIndicator.startAnimating()
        }
        
        switch segmentController.selectedSegmentIndex {
        case 0:
            MeetingRequests.shared.getUserMeetings(meetingType: "visited", completion: updateUserMeetingTable)
        case 1:
            MeetingRequests.shared.getUserMeetings(meetingType: "planned", completion: updateUserMeetingTable)
        case 2:
            MeetingRequests.shared.getUserInvitations(completion: updateMeetingInvitations)
        default:
            break
        }
    }
    
    
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
        if let currentMeetings = currentMeetings {
            let vc = MeetingInfoVC()
            vc.meeting = currentMeetings[indexPath.row]
            navigationController?.pushViewController(vc, animated: true)
        } else {
            if indexPath.section == 0 {
                let vc = MeetingInfoVC()
                vc.meeting = User.currentUser.meetingInvitations!.personalInvitations[indexPath.row]
                navigationController?.pushViewController(vc, animated: true)
            } else {
                let vc = MeetingInfoVC()
                vc.meeting = User.currentUser.meetingInvitations!.groupInvitations[indexPath.section - 1].meetings[indexPath.row]
                navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    

    private func leaveAction(indexPath: IndexPath) -> UIContextualAction {
        let leaveAction = UIContextualAction(style: .destructive, title: "Покинуть мероприятие") { [weak self] (_, _, _) in
            let alert = UIAlertController(title: "Покинуть мероприятие?", message: "Вы уверены, что хотите покинуть мероприятие? Это действие нельзя отменить.", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
            let removeAction = UIAlertAction(title: "Покинуть", style: .default, handler: {_ in
                MeetingRequests.shared.removeMeeting(meetingID: self!.currentMeetings![indexPath.row].id, completion: {(error) in
                    if let error = error {
                        let alert = ErrorChecker.handler.getAlertController(error: error)
                        self?.present(alert, animated: true, completion: nil)
                        return
                    }
                    self?.currentMeetings!.remove(at: indexPath.row)
                    User.currentUser.plannedMeetings?.remove(at: indexPath.row)
                    self?.meetingTableView.deleteRows(at: [indexPath], with: .automatic)
                    self?.meetingTableView.reloadData()
                })
            })
            alert.addAction(cancelAction)
            alert.addAction(removeAction)
            self?.present(alert, animated: true)
        }
        return leaveAction
    }
    
    
    private func deleteAction(indexPath: IndexPath) -> UIContextualAction {
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Отменить мероприятие") { [weak self] (_, _, _) in
            let alert = UIAlertController(title: "Удалить мероприятие?", message: "Вы уверены, что хотите удалить мероприятие? Это действие нельзя отменить. Мероприятие будет удалено для всех его участников.", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
            let removeAction = UIAlertAction(title: "Удалить", style: .default, handler: {_ in
                MeetingRequests.shared.deleteMeeting(meetingID: self!.currentMeetings![indexPath.row].id, completion: {(error) in
                    if let error = error {
                        let alert = ErrorChecker.handler.getAlertController(error: error)
                        self!.present(alert, animated: true, completion: nil)
                        return
                    }
                    self!.currentMeetings!.remove(at: indexPath.row)
                    User.currentUser.plannedMeetings?.remove(at: indexPath.row)
                    self!.meetingTableView.deleteRows(at: [indexPath], with: .automatic)
                    self!.meetingTableView.reloadData()
                })
            })
            alert.addAction(cancelAction)
            alert.addAction(removeAction)
            self!.present(alert, animated: true)
        }
        return deleteAction
    }
    
    
    private func inviteAction(participate: Bool, indexPath: IndexPath) -> UIContextualAction {
        let participateAction = UIContextualAction(style: (participate ? .normal : .destructive), title: (participate ? "Участвовать" : "Отказаться")) { [weak self] (_, _, _) in
            if indexPath.section == 0 {
                let meeting = User.currentUser.meetingInvitations!.personalInvitations[indexPath.row]
                MeetingRequests.shared.participateInMeeting(accept: participate ,meetingID: meeting.id, completion: {(error) in
                    if let error = error {
                        let alert = ErrorChecker.handler.getAlertController(error: error)
                        self!.present(alert, animated: true, completion: nil)
                        return
                    }
                    
                    meeting.participantsID.append(User.currentUser.account!.id)
                    
                    let index = User.currentUser.meetingInvitations!.personalInvitations.firstIndex(of: meeting)
                    User.currentUser.meetingInvitations!.personalInvitations.remove(at: index!)
                    
                    if participate {
                        User.currentUser.plannedMeetings?.append(meeting)
                    }
                    
                    self!.meetingTableView.reloadData()
                })
            } else {
                let meeting = User.currentUser.meetingInvitations!.groupInvitations[indexPath.section - 1].meetings[indexPath.row]
                GroupRequests.shared.respondMeetingForGroupInvitation(accept: participate, groupID: (User.currentUser.meetingInvitations?.groupInvitations[indexPath.section - 1].group.id)!, meetingID: (User.currentUser.meetingInvitations?.groupInvitations[indexPath.section - 1].meetings[indexPath.row].id)!,
                                                                      completion: {(error) in
                    if let error = error {
                        let alert = ErrorChecker.handler.getAlertController(error: error)
                        self!.present(alert, animated: true, completion: nil)
                        return
                    }
                    
                    let index = User.currentUser.meetingInvitations!.groupInvitations[indexPath.section - 1].meetings.firstIndex(of: meeting)
                    User.currentUser.meetingInvitations!.groupInvitations[indexPath.section - 1].meetings.remove(at: index!)
                    
                    self?.meetingTableView.reloadData()
                })
            }
        }
        return participateAction
    }
    
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        var actions = [UIContextualAction]()
        if let _ = currentMeetings {
            
            let leaveAction = leaveAction(indexPath: indexPath)
            
            let deleteAction = deleteAction(indexPath: indexPath)
            
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
        
        } else {
            let participateAction = inviteAction(participate: true, indexPath: indexPath)
            let declineAction = inviteAction(participate: false, indexPath: indexPath)
            actions.append(participateAction)
            actions.append(declineAction)
        }
        let configuration = UISwipeActionsConfiguration(actions: actions)
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }
    
    
    func updateSearchResults(for searchController: UISearchController) {
        
    }
    
    
    @objc func filterMeetingsSearch() {
        
        let searchFilterVC = SearchFilterVC()
        searchFilterVC.searchOptions = self.searchOptions
        if let sheet = searchFilterVC.sheetPresentationController {
            sheet.detents = [ .medium(), .large() ]
        }
        
        present(searchFilterVC, animated: true)
    }
    
    
    @objc func createMeeting() {
        navigationController?.pushViewController(CreateMeetingVC(), animated: true)
    }

    
    func configSegmentController() {
        view.addSubview(segmentController)
        segmentController.setConstraints(to: view, left: 30, top: 0, right: 30, height: 30)
        segmentController.selectedSegmentIndex = 1
        segmentController.addTarget(self, action: #selector(reloadData), for: .valueChanged)
    }
    
    
    func configNavigationBar()  {
        let filterButton = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(filterMeetingsSearch))
        let createMeetingButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(createMeeting))
        searchController.searchBar.sizeToFit()
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search meetings"
        
        navigationItem.title = "Meetings"
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.searchController = searchController
        navigationItem.leftBarButtonItem = filterButton
        navigationItem.rightBarButtonItem = createMeetingButton
    }
    
    
    func configMeetingTableView() {
        
        refreshControl.addTarget(self, action: #selector(reloadUserMeetings), for: .valueChanged)
        meetingTableView.refreshControl = refreshControl
       
        meetingTableView.backgroundView = activityIndicator
        meetingTableView.register(MeetingCell.self, forCellReuseIdentifier: "MeetingCell")
        view.addSubview(meetingTableView)
        meetingTableView.pinTop(to: segmentController.bottomAnchor, const: 10)
        meetingTableView.pinLeft(to: view.safeAreaLayoutGuide.leadingAnchor, const: 10)
        meetingTableView.pinRight(to: view.safeAreaLayoutGuide.trailingAnchor, const: 10)
        meetingTableView.pinBottom(to: view.safeAreaLayoutGuide.bottomAnchor, const: 10)
    }

}
