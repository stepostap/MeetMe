//
//  MeetingDTO.swift
//  MeetMe
//
//  Created by Stepan Ostapenko on 27.03.2022.
//

import Foundation

struct MeetingDTO: Codable {
    internal init(id: Int64, adminID: Int64, name: String, startDate: String, endDate: String? = nil, description: String? = nil, location: String? = nil, imageURL: String? = nil, isPrivate: Bool, isOnline: Bool, maxNumberOfParticipants: Int, numberOfParticipants: Int, interests: [String]?) {
        self.id = id
        self.adminId = adminID
        self.name = name
        self.startDate = startDate
        self.endDate = endDate
        self.description = description
        self.location = location
        self.imageURL = imageURL
        self.isPrivate = isPrivate
        self.isOnline = isOnline
        self.maxNumberOfParticipants = maxNumberOfParticipants
        self.numberOfParticipants = numberOfParticipants
        self.interests = interests
    }
    
    let id, adminId: Int64
    let name: String
    let startDate: String
    var endDate: String?
    let description, location, imageURL: String?
    let isPrivate, isOnline: Bool
    let maxNumberOfParticipants, numberOfParticipants: Int
    let interests: [String]?
}
