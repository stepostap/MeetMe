//
//  Meeting.swift
//  MeetMe
//
//  Created by Stepan Ostapenko on 02.03.2022.
//


import Foundation

class Meeting: Codable {
    
    internal init(id: Int64, name: String, types: [Interests], info: String, online: Bool, isPrivate: Bool, participants: [Int64], groups: [Int64], participantsMax: Int, Location: String? = nil, startingDate: Date, endingDate: Date? = nil, currentParticipantNumber: Int) {
        self.id = id
        self.currentParticipantNumber = currentParticipantNumber
        self.name = name
        self.types = types
        self.info = info
        self.isOnline = online
        self.participantsID = participants
        self.participantsMax = participantsMax
        self.Location = Location
        self.startingDate = startingDate
        self.endingDate = endingDate
        self.participantsGroupsID = groups
        self.isPrivate = isPrivate
    }
    
    var id: Int64
    var imageURL: String?
    var name: String
    var types: [Interests]
    var info:  String
    var isOnline: Bool
    var participantsID: [Int64]
    var participantsGroupsID: [Int64]
    var currentParticipantNumber: Int
    var participantsMax: Int
    var Location: String?
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
