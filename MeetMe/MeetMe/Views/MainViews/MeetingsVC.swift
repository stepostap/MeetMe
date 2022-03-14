//
//  MeetingsVC.swift
//  MeetMe
//
//  Created by Stepan Ostapenko on 24.02.2022.
//

import UIKit

class MeetingsVC: UIViewController, UISearchResultsUpdating, UITableViewDelegate, UITableViewDataSource {
    

    let searchOptions = MeetingSearchFilter(types: [], online: false, participantsMax: 100,
                                            startingDate: Date.now, endingDate: Date.distantFuture)
    
    let segmentController = UISegmentedControl(items: ["История", "Предстоящие", "Приглашения"])
    let searchController = UISearchController(searchResultsController: nil)
    let meetingTableView = UITableView()
    
    var currentMeetings = [Meeting]()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        meetingTableView.delegate = self
        meetingTableView.dataSource = self
        
        view.backgroundColor = .systemBackground
        
        configNavigationBar()
        configSegmentController()
        configMeetingTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        Networker.shared.getUserMeetings(completion: {(meetings, error) in
            if let error = error {
                let alert = ErrorChecker.handler.getAlertController(error: error)
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            if let meetings = meetings {
                User.currentUser.meetingInvitations.removeAll()
                User.currentUser.meetingHistory.removeAll()
                User.currentUser.plannedMeetings.removeAll()
                for meeting in meetings {
                    if meeting.startingDate < Date.now {
                        User.currentUser.meetingHistory.append(meeting)
                    }
                    else if meeting.participantsID.contains(User.currentUser.account!.id) {
                        User.currentUser.plannedMeetings.append(meeting)
                    }
                    else {
                        User.currentUser.meetingInvitations.append(meeting)
                    }
                }
                self.currentMeetings = User.currentUser.plannedMeetings
                self.meetingTableView.reloadData()
            }
            self.segmentController.selectedSegmentIndex = 1
        })
        
        currentMeetings = User.currentUser.plannedMeetings
        meetingTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentMeetings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MeetingCell", for: indexPath) as! MeetingCell
        cell.meeting = currentMeetings[indexPath.row]
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = MeetingInfoVC()
        vc.meeting = currentMeetings[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
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
    
    @objc func segmentChanged() {
        
        switch segmentController.selectedSegmentIndex {
        case 0: currentMeetings = User.currentUser.meetingHistory
        case 1: currentMeetings = User.currentUser.plannedMeetings
        case 2: currentMeetings = User.currentUser.meetingInvitations
        default:
            break;
        }
        
        meetingTableView.reloadData()
    }
    
    func configSegmentController() {
        view.addSubview(segmentController)
        segmentController.setConstraints(to: view, left: 30, top: 0, right: 30, height: 30)
        segmentController.selectedSegmentIndex = 1
        segmentController.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
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
        
        meetingTableView.register(MeetingCell.self, forCellReuseIdentifier: "MeetingCell")
        view.addSubview(meetingTableView)
        meetingTableView.pinTop(to: segmentController.bottomAnchor, const: 10)
        meetingTableView.pinLeft(to: view.safeAreaLayoutGuide.leadingAnchor, const: 10)
        meetingTableView.pinRight(to: view.safeAreaLayoutGuide.trailingAnchor, const: 10)
        meetingTableView.pinBottom(to: view.safeAreaLayoutGuide.bottomAnchor, const: 10)
    }

}
