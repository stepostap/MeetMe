//
//  MeetingSearchFilter.swift
//  MeetMe
//
//  Created by Stepan Ostapenko on 03.03.2022.
//

import Foundation

/// Фильтр для поиска мероприятий 
class MeetingSearchFilter {
    
    internal init(types: [Interests], online: Bool, participantsMax: Int, startingDate: Date? = nil, endingDate: Date? = nil) {
        self.types = types
        self.online = online
        self.participantsMax = participantsMax
        self.startingDate = startingDate
        self.endingDate = endingDate
    }
    /// Хэштеги мероприятия
    var types: [Interests]
    /// Проводится ли мероприятие онлайн
    var online: Bool
    /// Максимальное число участников
    var participantsMax: Int
    /// Дата начала проведения мероприятия
    var startingDate: Date?
    /// Дата конца проведения мероприятия
    var endingDate: Date?
}
