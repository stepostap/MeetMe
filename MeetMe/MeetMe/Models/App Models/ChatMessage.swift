//
//  ChatMessage.swift
//  MeetMe
//
//  Created by Stepan Ostapenko on 11.04.2022.
//

import Foundation
import MessageKit

/// Информация об отправителе сообщения
struct MessageSender: SenderType {
    internal init(senderId: String, displayName: String, avatarURL: String) {
        self.senderId = senderId
        self.displayName = displayName
        self.avatarURL = avatarURL
    }
    /// Идентификатор отправителя сообщения
    var senderId: String
    /// Имя отправителя сообщения
    var displayName: String
    /// Ссылка на картинку (аватар) отправителя
    var avatarURL: String
}

/// Сообщение из чата
struct ChatMessage :  MessageType {
    internal init(sender: SenderType, messageId: String, sentDate: Date, content: String) {
        self.sender = sender
        self.messageId = messageId
        self.sentDate = sentDate
        self.content = content
    }
    /// Отправитель сообщения
    var sender: SenderType
    /// Идентификатор сообщения
    var messageId: String
    /// Дата отправки сообщения
    var sentDate: Date
    /// Текста сообщения
    var content: String
    /// Тип сообщения
    var kind: MessageKind {
        return .text(content)
    }
}
