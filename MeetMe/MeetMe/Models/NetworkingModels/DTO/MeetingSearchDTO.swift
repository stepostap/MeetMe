//
//  MeetingSearchDTO.swift
//  MeetMe
//
//  Created by Stepan Ostapenko on 01.04.2022.
//

import Foundation

struct MeetingSearchDTO: Codable {
    
    internal init(searchQuery: String, interests: [String]) {
        self.searchQuery = searchQuery
        self.interests = interests
    }
    
    var searchQuery: String
    var interests: [String]
}
