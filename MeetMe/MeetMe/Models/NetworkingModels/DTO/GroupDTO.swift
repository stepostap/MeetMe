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
        self.photoURL = photoURL
        self.isPrivate = isPrivate
        self.interests = interests
    }
    
    let id, adminId: Int64
    let name: String, description: String?
    let photoURL: String?
    let isPrivate: Bool
    let interests: [String]?
}
