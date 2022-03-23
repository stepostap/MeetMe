//
//  Participant.swift
//  MeetMe
//
//  Created by Stepan Ostapenko on 21.03.2022.
//

import Foundation

struct Participant {
    internal init(name: String, id: Int64, imageURL: URL) {
        self.name = name
        self.id = id
        self.imageURL = imageURL
    }
    
    var name: String
    var id: Int64
    var imageURL: URL
}
