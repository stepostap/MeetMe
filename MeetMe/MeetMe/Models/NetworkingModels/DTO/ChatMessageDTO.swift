//
//  ChatMessage.swift
//  MeetMe
//
//  Created by Stepan Ostapenko on 11.04.2022.
//

import Foundation

struct ChatMessageDTO: Codable {
    internal init(avatarUrl: String, content: String, id: Int64, senderFullName: String, senderId: Int64, timestamp: String) {
        self.avatarUrl = avatarUrl
        self.content = content
        self.id = id
        self.senderFullName = senderFullName
        self.senderId = senderId
        self.date = timestamp
    }
    
    
    var avatarUrl: String
    var content: String
    var id: Int64
    var senderFullName: String
    var senderId: Int64
    var date: String
}
