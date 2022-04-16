//
//  Group.swift
//  MeetMe
//
//  Created by Stepan Ostapenko on 08.03.2022.
//

import Foundation

/// Краткая информация о приглашении
struct InvitationShortInfo: Hashable, Comparable {
    static func < (lhs: InvitationShortInfo, rhs: InvitationShortInfo) -> Bool {
        if lhs.id == User.currentUser.account?.id {
            return false
        } else {
            return lhs.name < rhs.name
        }
    }
    /// Адресат приглашения (группа или текущий пользователь)
    var name: String
    /// Идентификатор приглашения
    var id: Int64
}

/// Информация о группе
class Group: Codable, Equatable {
    static func == (lhs: Group, rhs: Group) -> Bool {
        return lhs.id == rhs.id
    }
    
    internal init(id: Int64, groupImage: String, groupName: String, groupInfo: String, interests: [Interests], meetings: [Int64]? = nil, participants: [Int64]? = nil, admins: [Int64]) {
        self.id = id
        self.groupImageURL = groupImage
        self.groupName = groupName
        self.groupInfo = groupInfo
        self.interests = interests
        self.meetingsID = meetings
        self.participants = participants
        self.admins = admins
    }
    /// Идентификатор группы
    var id: Int64
    /// Ссылка на изображение группы
    var groupImageURL: String
    /// Название группы
    var groupName: String
    /// Информация о группе
    var groupInfo: String
    /// Хэштеги (интересы) группы
    var interests: [Interests]
    /// Приватная ли группа
    var isPrivate = false
    /// Идентификаторы мероприятий группы
    var meetingsID: [Int64]?
    /// Идентификаторы администраторов группы
    var admins: [Int64]
    /// Идентификаторы участников группы
    var participants: [Int64]?
}
