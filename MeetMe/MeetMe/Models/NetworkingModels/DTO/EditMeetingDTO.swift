//
//  EditMeetingDTO.swift
//  MeetMe
//
//  Created by Stepan Ostapenko on 28.03.2022.
//

import Foundation

struct EditMeetingDTO: Codable {
    internal init(name: String, description: String, startDate: String, endDate: String? = nil, isOnline: Bool, locate: String, maxNumberOfParticipants: Int) {
        self.name = name
        self.description = description
        self.startDate = startDate
        self.endDate = endDate
        self.isOnline = isOnline
        self.locate = locate
        self.maxNumberOfParticipants = maxNumberOfParticipants
    }
    
    var name: String
    var description: String
    var startDate: String
    var endDate: String?
    var isOnline: Bool
    var locate: String
    var maxNumberOfParticipants: Int
}
