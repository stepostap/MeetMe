//
//  Account.swift
//  MeetMe
//
//  Created by Stepan Ostapenko on 02.03.2022.
//

import Foundation
import UIKit

/// Иннформация об аккаунте пользователя приложения
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
    /// Идентификатор пользователя
    var id: Int64
    /// Имя пользователя
    var name: String
    /// Информация о пользователе
    var info: String
    /// Ссылка на картинку пользователя
    var imageDataURL: String
    /// Хэштеги (интересы) пользователя
    var interests = [Interests]()
    /// Ссылки на социальные сети пользователя
    var socialMediaLinks:[String:String] = [:]
    
    /// Проверка на наличие ссылок на социальные сети у пользователя
    func isLinksEmpty() -> Bool {
        if socialMediaLinks.isEmpty {
            return true
        }
        
        var noValue = true
        for link in socialMediaLinks {
            if !link.value.isEmpty {
                noValue = false
            }
        }
        return noValue
    }
    
    /// Получение строкового представления об интересах пользователя
    func getInterests() -> String {
        var interests = ""
        for interest in self.interests {
            interests += interest.rawValue + ", "
        }
        return interests
    }
}
