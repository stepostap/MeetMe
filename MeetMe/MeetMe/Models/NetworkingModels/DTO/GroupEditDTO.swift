//
//  File.swift
//  MeetMe
//
//  Created by Stepan Ostapenko on 11.04.2022.
//

import Foundation

struct GroupEditDTO: Codable {
    internal init(name: String, description: String?, isPrivate: Bool, interests: [String]?) {
        self.name = name
        self.description = description
        self.isPrivate = isPrivate
        self.interests = interests
    }
    
    
    let name: String
    let description: String?
    let isPrivate: Bool
    let interests: [String]?
}
