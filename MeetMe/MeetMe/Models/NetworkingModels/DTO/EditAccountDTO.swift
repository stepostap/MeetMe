//
//  EditAccountDTO.swift
//  MeetMe
//
//  Created by Stepan Ostapenko on 31.03.2022.
//

import Foundation

struct EditAccountDTO: Codable {
    internal init(fullName: String, description: String? = nil, links: [String : String]? = nil, interests: [String]? = nil) {
        self.fullName = fullName
        self.description = description
        self.mediaLinks = links
        self.interests = interests
    }    
   
    var fullName: String
    var description: String?
    var mediaLinks: [String:String]?
    var interests: [String]?
}
