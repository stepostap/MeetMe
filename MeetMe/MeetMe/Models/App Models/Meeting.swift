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

/// Информация о мероприятии 
class Meeting: Codable, Equatable {
    static func == (lhs: Meeting, rhs: Meeting) -> Bool {
        return lhs.id == rhs.id
    }
        
    internal init(id: Int64, creatorID: Int64, chatID: Int64, name: String, types: [Interests], info: String, online: Bool, isPrivate: Bool, isParticipant: Bool, groups: [Int64], participantsMax: Int, Location: String, startingDate: Date, endingDate: Date? = nil, currentParticipantNumber: Int, imageURL: String = "") {
        self.chatID = chatID
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
    /// Идентификатор мероприятия
    var id: Int64
    /// Идентификатор создателя мероприятия
    var creatorID: Int64
    /// Идентификатор чата мероприятия
    var chatID: Int64
    /// Ссылка на изображение мероприятия
    var imageURL:  String
    /// Название мероприятия
    var name: String
    /// Хэштеги мероприятия
    var types: [Interests]
    /// Информация о мероприятии
    var info:  String
    /// Проводится ли мероприятие онлайн
    var isOnline: Bool
    /// Участвует ли текущий пользователь в данном мероприятии
    var isUserParticipant: Bool
    /// Идентификаторы участвующих в мероприятии групп
    var participantsGroupsID: [Int64]
    /// Текущее количество участников
    var currentParticipantNumber: Int
    /// Максимальное количество участников
    var participantsMax: Int
    /// Информация о месте проведения мероприятия
    var Location: String
    /// Дата начала проведения мероприятия
    var startingDate: Date
    /// Дата конца проведения мероприятия
    var endingDate: Date?
    /// Приватное ли данное мероприятие
    var isPrivate: Bool
    
    /// Строковое представление о дате начала и дате конца проведения мероприятия
    func getDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM HH:mm"
        if let endingDate = endingDate {
            return formatter.string(from: (startingDate)) + " - " + formatter.string(from: (endingDate))
        } else {
            return formatter.string(from: (startingDate))
        }
    }
    
    /// Строковое представление о хэштегах мероприятия 
    func getInterests() -> String {
        var interests = ""
        for interest in types {
            interests += interest.rawValue + ", "
        }
        return interests
    }
}
