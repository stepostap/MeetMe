//
//  MeetingDTO.swift
//  MeetMe
//
//  Created by Stepan Ostapenko on 27.03.2022.
//

import Foundation

struct MeetingDTO: Codable {
    internal init(id: Int64, adminID: Int64, chatId: Int64, name: String, startDate: String, endDate: String? = nil, description: String? = nil, location: String? = nil, imageURL: String? = nil, isPrivate: Bool, isOnline: Bool, maxNumberOfParticipants: Int, numberOfParticipants: Int, interests: [String]?, isParticipant: Bool?) {
        self.chatId = chatId
        self.id = id
        self.adminId = adminID
        self.name = name
        self.startDate = startDate
        self.endDate = endDate
        self.description = description
        self.location = location
        self.imageUrl = imageURL
        self.isPrivate = isPrivate
        self.isOnline = isOnline
        self.maxNumberOfParticipants = maxNumberOfParticipants
        self.numberOfParticipants = numberOfParticipants
        self.interests = interests
        self.isParticipant = isParticipant
    }
    
    let id, adminId, chatId: Int64
    let name: String
    let startDate: String
    var endDate: String?
    let description, location, imageUrl: String?
    let isPrivate, isOnline: Bool
    let maxNumberOfParticipants, numberOfParticipants: Int
    let interests: [String]?
    let isParticipant: Bool?
    
    /// Создание эземпляра класса Meeting из экземпляра класса MeetingDTO (перевод из серверной модели данныхданных
    /// в модель, используемую в приложени)
    func createMeetingFromDTO() -> Meeting {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd-yyyy HH:mm"
        let recievedMeeting = Meeting(id: id, creatorID: adminId, chatID: chatId, name: name, types: InterestsParser.getInterests(interestsString: interests ?? []), info: description ?? "", online: isOnline, isPrivate: isPrivate, isParticipant: isParticipant ?? false, groups: [], participantsMax: maxNumberOfParticipants, Location: location ?? "", startingDate: formatter.date(from: startDate)!, endingDate: nil, currentParticipantNumber: numberOfParticipants, imageURL: imageUrl ?? "")
        if let endingDate = endDate {
            recievedMeeting.endingDate = formatter.date(from: endingDate)
        }
        return recievedMeeting
    }
}
