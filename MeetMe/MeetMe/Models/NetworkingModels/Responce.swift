//
//  Responce.swift
//  MeetMe
//
//  Created by Stepan Ostapenko on 24.03.2022.
//

import Foundation
/// Ответ сервера
struct Responce<T: Codable>: Codable {
    /// Сообщение сервера
    var message: String
    /// Код ответа сервера
    var appCode: Int
    /// Данные ответа сервера
    var data: T?
}

