//
//  ChatSendMessageDTO.swift
//  MeetMe
//
//  Created by Stepan Ostapenko on 11.04.2022.
//

import Foundation

struct ChatSendMessageDTO:  Codable {
    internal init(content: String, chatId: Int64, senderId: Int64) {
        self.content = content
        self.chatId = chatId
        self.senderId = senderId
    }
    
    var content: String
    var chatId: Int64
    var senderId: Int64
}
