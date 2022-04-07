//
//  JWTBullshit.swift
//  MeetMe
//
//  Created by Stepan Ostapenko on 31.03.2022.
//

import Foundation

struct JWTBullshit: Codable, Hashable {
    internal init(email: String, password: String) {
        self.username = email
        self.password = password
    }
    
    var username: String
    var password: String
}
