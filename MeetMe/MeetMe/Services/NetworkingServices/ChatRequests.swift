//
//  ChatRequests.swift
//  MeetMe
//
//  Created by Stepan Ostapenko on 11.04.2022.
//

import Foundation

/// Создание, отправка и обработка запросов,  связанных с чатом мероприятия
class ChatRequests: MeetMeRequests {
    /// Статический экзмепляр класса
    static let shared = ChatRequests()
    /// Базовая часть URL дла запросов
    let chatURL = "http://localhost:8080/api/v1/chat/messages/"
    
    // Создание и отправка запроса на получение списка сообщений в чате + обработка ответа сервера
    func getMessages(anchor: Int64, messageNumber: Int, chatId: Int64, completion: @escaping ([ChatMessage]?, Error?) -> (Void)) {
        if !NetworkMonitor.shared.isConnected {
            DispatchQueue.main.async { completion(nil, NetworkerError.noConnection)}
        }
        
        var request = URLRequest(url: URL(string: chatURL + "get")!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(MeetMeRequests.JWTToken)", forHTTPHeaderField: "Authorization")
        request.httpBody = try! encoder.encode(GetChatDTO(anchor: anchor, messagesNumber: messageNumber, chatId: chatId))
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = session.dataTask(with: request, completionHandler: ({ data, responce, error in
            do {
                try self.errorCheck(data: data, response: responce, error: error)
            } catch let error {
                DispatchQueue.main.async { completion(nil, error) }
            }
            if let data = data {
                do {
                    self.formatter.dateFormat = "MM-dd-yyyy HH:mm"
                    let messagesData : [ChatMessageDTO] = try self.getData(data: data)
                    var messages = [ChatMessage]()
                    for message in messagesData {
                        let date = self.formatter.date(from: message.date)
                        messages.append(ChatMessage(sender: MessageSender(senderId: message.senderId.description, displayName: message.senderFullName, avatarURL: message.avatarUrl), messageId: message.id.description, sentDate: date!, content: message.content))
                    }
                    DispatchQueue.main.async { completion(messages, nil) }
                } catch let error {
                    DispatchQueue.main.async { completion(nil, error) }
                }
            }
        }))
        task.resume()
    }
    
    /// Создание и отправка запроса на отправление нового сообщения в чате chatId  + обработка ответа сервера
    func sendMessage(content: String, chatId: Int64, senderId: Int64, completion: @escaping (Int64?, Error?) -> (Void)) {
        if !NetworkMonitor.shared.isConnected {
            DispatchQueue.main.async { completion(nil, NetworkerError.noConnection)}
        }
        
        var request = URLRequest(url: URL(string: chatURL)!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(MeetMeRequests.JWTToken)", forHTTPHeaderField: "Authorization")
        request.httpBody = try! encoder.encode(ChatSendMessageDTO(content: content, chatId: chatId, senderId: senderId))
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = session.dataTask(with: request, completionHandler: ({ data, responce, error in
            do {
                try self.errorCheck(data: data, response: responce, error: error)
            } catch let error {
                DispatchQueue.main.async { completion(nil, error) }
            }
            if let data = data {
                do {
                    let MessageID : Int64 = try self.getData(data: data)
                    DispatchQueue.main.async { completion(MessageID, nil) }
                } catch let error {
                    DispatchQueue.main.async { completion(nil, error) }
                }
            }
        }))
        task.resume()
    }
}
