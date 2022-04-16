//
//  User.swift
//  MeetMe
//
//  Created by Stepan Ostapenko on 08.03.2022.
//

import Foundation

/// Почта и пароль пользователя
struct LoginInfo: Codable, Hashable {
    internal init(email: String, password: String) {
        self.email = email
        self.password = password
    }
    /// Почта
    var email: String
    /// Пароль
    var password: String
}

/// Текущий пользователь приложения
class User {
    /// Статический экземпляр класса
    static var currentUser = User()
    /// Аккаунт пользователя
    var account: Account?
    /// Список друзей пользователя
    var friends: [Account]?
    /// Список заявок в друзья
    var friendsRequests: [Account]?
    /// Список посещенных мероприятий
    var meetingHistory: [Meeting]?
    /// Список запланированных мероприятий
    var plannedMeetings: [Meeting]?
    /// Список приглашений на мероприятия
    var meetingInvitations: UserInvitations?
    /// Список групп пользователя
    var groups: [Group]?
    
}
