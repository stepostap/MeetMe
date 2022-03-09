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
    var meetingHistory = [Meeting]()
    var plannedMeetings = [Meeting]()
    var meetingInvitations = [Meeting]()
    var currentMeetings = [Meeting]()
    
    let meeting1 = Meeting(id: "", name: "1", types: [.bar], info: "Тусовка в баре", online: false, participants: [], participantsMax: 10, Location: "", image: nil, startingDate: Date.now, endingDate: Date.distantFuture, currentParticipantNumber: 1)
    let meeting2 = Meeting(id: "", name: "2", types: [.club, .dancing], info: "Бухаем и танцуем в клубе", online: false, participants: [], participantsMax: 10, Location: "", image: nil, startingDate: Date.distantPast, endingDate: Date.distantPast, currentParticipantNumber: 1)
    let meeting3 = Meeting(id: "", name: "3", types: [.tabletopGames], info: "Играем в настолки", online: false, participants: [], participantsMax: 10, Location: "", image: nil, startingDate: Date.now, endingDate: Date.distantFuture, currentParticipantNumber: 1)
    let meeting4 = Meeting(id: "", name: "4", types: [.tabletopGames], info: "Играем в настолки", online: false, participants: [], participantsMax: 10, Location: "", image: nil, startingDate: Date.now, endingDate: Date.distantFuture, currentParticipantNumber: 1)


    override func viewDidLoad() {
        super.viewDidLoad()
        
        meetingHistory.append(meeting2)
        plannedMeetings.append(meeting3)
        plannedMeetings.append(meeting4)
        meetingInvitations.append(meeting1)
        currentMeetings = plannedMeetings
        
        meetingTableView.delegate = self
        meetingTableView.dataSource = self
        
        
        view.backgroundColor = .systemBackground
    }
    
    override func viewWillLayoutSubviews() {
        configNavigationBar()
        configSegmentController()
        configMeetingTableView()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentMeetings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MeetingCell", for: indexPath) as! MeetingCell
        cell.meeting = currentMeetings[indexPath.row]
        
        
        return cell
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
        
    }
    
    @objc func segmentChanged() {
        
        switch segmentController.selectedSegmentIndex {
        case 0: currentMeetings = meetingHistory
        case 1: currentMeetings = plannedMeetings
        case 2: currentMeetings = meetingInvitations
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
