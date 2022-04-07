//
//  SearchResultsVC.swift
//  MeetMe
//
//  Created by Stepan Ostapenko on 04.04.2022.
//

import UIKit

class MeetingSearchResultsVC: UITableViewController, UISearchResultsUpdating {
    
    var parentVC: MeetingsVC {
        return self.presentingViewController as! MeetingsVC
    }
    
    var meetings = [(sectionHeader: String, meetings: [Meeting])]()
    let loader = UIActivityIndicatorView()

    override func viewDidLoad() {
        super.viewDidLoad()

        
        confinTableView()
    }
    
    func confinTableView() {
        self.tableView.backgroundView = loader
        self.tableView.backgroundColor = .systemBackground
        self.tableView.register(MeetingCell.self, forCellReuseIdentifier: "meetingCell")
    }

    func updateSearchResults(for searchController: UISearchController) {
        loader.startAnimating()
        let filter = parentVC.searchOptions
        let query = searchController.searchBar.text ?? ""
        print(parentVC.segmentController.selectedSegmentIndex)
        if !query.isEmpty {
            switch parentVC.segmentController.selectedSegmentIndex {
            case 0: MeetingRequests.shared.getFilteredMeetings(meetingType: .visited, query: query, filter: filter, completion: updateTable(meetings:error:))
            case 1: MeetingRequests.shared.getFilteredMeetings(meetingType: .planned, query: query, filter: filter, completion: updateTable(meetings:error:))
            case 2: MeetingRequests.shared.getFilteredMeetings(meetingType: .invitations, query: query, filter: filter, completion: updateTable(meetings:error:))
            default: break
            }
        }
    }
    
    func updateTable(meetings: [(sectionHeader: String, meetings: [Meeting])]?, error: Error?) {
        self.loader.stopAnimating()
        if let error = error {
            let alert = ErrorChecker.handler.getAlertController(error: error)
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        if let meetings = meetings {
            self.meetings = meetings
            self.tableView.reloadData()
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return meetings.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return meetings[section].meetings.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return meetings[section].sectionHeader
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "meetingCell", for: indexPath) as! MeetingCell
        cell.meeting = meetings[indexPath.section].meetings[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 170
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = MeetingInfoVC()
        vc.meeting = meetings[indexPath.section].meetings[indexPath.row]
        
        parentVC.navigationController?.pushViewController(vc, animated: true)
        //parentVC.searchController?.isActive = false
    }
}
