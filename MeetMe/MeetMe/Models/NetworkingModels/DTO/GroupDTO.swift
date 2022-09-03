//
//  GroupDTO.swift
//  MeetMe
//
//  Created by Stepan Ostapenko on 29.03.2022.
//

import Foundation

struct GroupDTO: Codable {
    internal init(id: Int64, adminID: Int64, name: String, description: String?, photoURL: String?, isPrivate: Bool, interests: [String]?) {
        self.id = id
        self.adminId = adminID
        self.name = name
        self.description = description
        self.photoUrl = photoURL
        self.isPrivate = isPrivate
        self.interests = interests
    }
    
    let id, adminId: Int64
    let name: String, description: String?
    let photoUrl: String?
    let isPrivate: Bool
    let interests: [String]?
    
    /// Создание эземпляра класса Group из экземпляра класса GroupDTO (перевод из серверной модели данных
    /// в модель, используемую в приложени)
    func createGroupFromDTO() -> Group {
        let group = Group(id: id, groupImage: photoUrl ?? "", groupName: name, groupInfo: description ?? "", interests: InterestsParser.getInterests(interestsString: interests ?? []), meetings: [], participants: [], admins: [adminId])
        return group
    }
}
