//
//  Meeting.swift
//  MeetMe
//
//  Created by Stepan Ostapenko on 02.03.2022.
//

import Foundation

enum MeetingType: String {
    case visited = "visited"
    case planned = "planned"
    case invitations = "invites"
}

class Meeting: Codable, Equatable {
    static func == (lhs: Meeting, rhs: Meeting) -> Bool {
        return lhs.id == rhs.id
    }
    
    
    internal init(id: Int64, creatorID: Int64, name: String, types: [Interests], info: String, online: Bool, isPrivate: Bool, isParticipant: Bool, groups: [Int64], participantsMax: Int, Location: String, startingDate: Date, endingDate: Date? = nil, currentParticipantNumber: Int, imageURL: String = "") {
        self.id = id
        self.creatorID = creatorID
        self.currentParticipantNumber = currentParticipantNumber
        self.name = name
        self.types = types
        self.info = info
        self.isOnline = online
        self.isUserParticipant = isParticipant
        self.participantsMax = participantsMax
        self.Location = Location
        self.startingDate = startingDate
        self.endingDate = endingDate
        self.participantsGroupsID = groups
        self.isPrivate = isPrivate
        self.imageURL = imageURL
    }
    
    var id: Int64
    var creatorID: Int64
    var imageURL:  String
    var name: String
    var types: [Interests]
    var info:  String
    var isOnline: Bool
    var isUserParticipant: Bool
    //var participantsID: [Int64]
    var participantsGroupsID: [Int64]
    var currentParticipantNumber: Int
    var participantsMax: Int
    var Location: String
    var startingDate: Date
    var endingDate: Date?
    var isPrivate: Bool
    
    func loadParticipants(id: String) {
        
    }
    
    func getDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM HH:mm"
        if let endingDate = endingDate {
            return formatter.string(from: (endingDate)) + " - " + formatter.string(from: (startingDate))
        } else {
            return formatter.string(from: (startingDate))
        }
    }
    
    func getInterests() -> String {
        var interests = ""
        for interest in types {
            interests += interest.rawValue + ", "
        }
        return interests
    }
}
