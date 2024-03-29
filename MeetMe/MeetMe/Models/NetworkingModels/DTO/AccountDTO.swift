//
//  AccountDTO.swift
//  MeetMe
//
//  Created by Stepan Ostapenko on 27.03.2022.
//

import Foundation

struct AccountDTO: Codable {
    internal init(id: Int64, fullName: String, description: String?, links: [String : String]? = nil, interests: [String]? = nil, photoUrl: String? = nil, email: String? = nil, telephone: String? = nil) {
        self.id = id
        self.fullName = fullName
        self.description = description
        self.links = links
        self.interests = interests
        self.photoUrl = photoUrl
        self.email = email
        self.telephone = telephone
    }
    
    var id: Int64
    var fullName: String
    var description: String?
    var links: [String:String]?
    var interests: [String]?
    var photoUrl: String?
    var email: String?
    var telephone: String?
    
    func createAccountFromDTO() -> Account {
        let account = Account(id: id, name: fullName, info: description ?? "", imageDataURL: photoUrl ?? "", interests: InterestsParser.getInterests(interestsString: interests ?? []), socialMediaLinks: links ?? [:])
        return account
    }
}
