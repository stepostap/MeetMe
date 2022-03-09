//
//  User.swift
//  MeetMe
//
//  Created by Stepan Ostapenko on 08.03.2022.
//

import Foundation

class User {
    
    static let currentUser = User()
    
    var account: Account?
    
    var meetingHistory = [Meeting]()
    var plannedMeetings = [Meeting]()
    var meetingInvitations = [Meeting]()
    var groups = [Group]()
    
    public func loadMeetings() {
        
    }
    
    public func loadGroups() {
        
    }
}
