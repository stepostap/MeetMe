//
//  MeetingInvitationsDTO.swift
//  MeetMe
//
//  Created by Stepan Ostapenko on 06.04.2022.
//

import Foundation

struct MeetingInvitationsDTO: Codable {
    
    internal init(users: [Int64], groups: [Int64]) {
        self.users = users
        self.groups = groups
    }
    
    let users: [Int64]
    let groups: [Int64]
}
