//
//  User.swift
//  MeetMe
//
//  Created by Stepan Ostapenko on 08.03.2022.
//

import Foundation

struct loginInfo: Codable, Hashable {
    internal init(email: String, password: String) {
        self.email = email
        self.password = password
    }
    
    var email: String
    var password: String
}

class User {
    
    static var currentUser = User()
    
    var account: Account?
    
    var friends = [Account]()
    var meetingHistory = [Meeting]()
    var plannedMeetings = [Meeting]()
    var meetingInvitations = [Meeting]()
    var groups = [Group]()
    
    public func loadMeetings() {
        
    }
    
    public func loadGroups() {
        
    }
}
