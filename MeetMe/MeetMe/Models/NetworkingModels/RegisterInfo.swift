//
//  RegisterInfo.swift
//  MeetMe
//
//  Created by Stepan Ostapenko on 24.03.2022.
//

import Foundation
/// Информация для регистрации пользователя
struct RegisterInfo: Codable {
    /// Почта
    var email: String
    /// Пароль
    var password: String
    /// Полное имя
    var fullName: String
}
