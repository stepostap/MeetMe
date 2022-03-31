//
//  Group.swift
//  MeetMe
//
//  Created by Stepan Ostapenko on 08.03.2022.
//

import Foundation


struct InvitationShortInfo: Hashable, Comparable {
    static func < (lhs: InvitationShortInfo, rhs: InvitationShortInfo) -> Bool {
        if lhs.id == User.currentUser.account?.id {
            return false
        } else {
            return lhs.name < rhs.name
        }
    }
    
    var name: String
    var id: Int64
}


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
