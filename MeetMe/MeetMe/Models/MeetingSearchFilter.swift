//
//  MeetingSearchFilter.swift
//  MeetMe
//
//  Created by Stepan Ostapenko on 03.03.2022.
//

import Foundation

class MeetingSearchFilter {
    
    internal init(types: [Interests], online: Bool, participantsMax: Int, startingDate: Date, endingDate: Date? = nil) {
        self.types = types
        self.online = online
        self.participantsMax = participantsMax
        self.startingDate = startingDate
        self.endingDate = endingDate
    }
    
    var types: [Interests]
    var online: Bool
    var participantsMax: Int
    var startingDate: Date?
    var endingDate: Date?
}
