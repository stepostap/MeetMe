//
//  Account.swift
//  MeetMe
//
//  Created by Stepan Ostapenko on 02.03.2022.
//

import Foundation
import UIKit


class Account: Codable {
    
    internal init(id: Int64, name: String, info: String, imageDataURL: String, interests: [Interests] = [Interests](), socialMediaLinks: [String] = [String]()) {
        self.id = id
        self.name = name
        self.info = info
        self.imageDataURL = imageDataURL
        self.interests = interests
        self.socialMediaLinks = socialMediaLinks
    }
    
    var id: Int64
    var name: String
    var info: String
    var imageDataURL: String
    var interests = [Interests]()
    var socialMediaLinks = [String]()
    
}
