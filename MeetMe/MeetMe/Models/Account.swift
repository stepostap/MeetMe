//
//  Account.swift
//  MeetMe
//
//  Created by Stepan Ostapenko on 02.03.2022.
//

import Foundation
import UIKit


class Account: Codable, Equatable {
    
    static func == (lhs: Account, rhs: Account) -> Bool {
        return lhs.id == rhs.id
    }
    
    
    internal init(id: Int64, name: String, info: String, imageDataURL: String, interests: [Interests] = [Interests](), socialMediaLinks: [String:String] = [String:String]()) {
        self.id = id
        self.name = name
        self.info = info
        self.imageDataURL = imageDataURL
        self.interests = interests
        self.socialMediaLinks = socialMediaLinks
    }
    
    internal init(account: Account) {
        self.id = account.id
        self.name = account.name
        self.info = account.info
        self.imageDataURL = account.imageDataURL
        self.interests = account.interests
        self.socialMediaLinks = account.socialMediaLinks
    }
    
    var id: Int64
    var name: String
    var info: String
    var imageDataURL: String
    var interests = [Interests]()
    var socialMediaLinks:[String:String] = [:]
    
    func getInterests() -> String {
        var interests = ""
        for interest in self.interests {
            interests += interest.rawValue + ", "
        }
        return interests
    }
}
