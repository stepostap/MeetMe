//
//  GetChatDTO.swift
//  MeetMe
//
//  Created by Stepan Ostapenko on 11.04.2022.
//

import Foundation

struct GetChatDTO: Codable {
    internal init(anchor: Int64, messagesNumber: Int, chatId: Int64) {
        self.anchor = anchor
        self.messagesNumber = messagesNumber
        self.chatId = chatId
    }
    
    var anchor: Int64
    var messagesNumber: Int
    var chatId: Int64
}
