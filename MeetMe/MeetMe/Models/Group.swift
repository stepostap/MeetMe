//
//  Group.swift
//  MeetMe
//
//  Created by Stepan Ostapenko on 08.03.2022.
//

import Foundation

class Group: Codable, Equatable {
    static func == (lhs: Group, rhs: Group) -> Bool {
        return lhs.id == rhs.id
    }
    
    
    internal init(id: Int64, groupImage: String, groupName: String, groupInfo: String, interests: [Interests], meetings: [Int64]? = nil, participants: [Int64]? = nil, admins: [Int64]) {
        self.id = id
        self.groupImageURL = groupImage
        self.groupName = groupName
        self.groupInfo = groupInfo
        self.interests = interests
        self.meetingsID = meetings
        self.participants = participants
        self.admins = admins
    }
    
    var id: Int64
    var groupImageURL: String
    var groupName: String
    var groupInfo: String
    var interests: [Interests]
    var isPrivate = false
    var meetingsID: [Int64]?
    var admins: [Int64]
    var participants: [Int64]?
    
    
    public func loadParticipants() {
        
    }
    
    public func loadMeeting(id: String) {
        
    }
}
