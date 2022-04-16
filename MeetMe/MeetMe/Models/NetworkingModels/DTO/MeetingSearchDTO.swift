//
//  MeetingSearchDTO.swift
//  MeetMe
//
//  Created by Stepan Ostapenko on 01.04.2022.
//

import Foundation

struct MeetingSearchDTO: Codable {
    internal init(searchQuery: String, interests: [String], maxNumberOfParticipants: Int, startDate: String? = nil, enddate: String? = nil) {
        self.searchQuery = searchQuery
        self.interests = interests
        self.maxNumberOfParticipants = maxNumberOfParticipants
        self.startDate = startDate
        self.endDate = enddate
    }
    
    var searchQuery: String
    var interests: [String]
    var maxNumberOfParticipants: Int
    var startDate: String?
    var endDate: String?
}

struct GroupSearchDTO: Codable {
    internal init(searchQuery: String, interests: [String]) {
        self.searchQuery = searchQuery
        self.interests = interests
    }
    
    var searchQuery: String
    var interests: [String]
}
