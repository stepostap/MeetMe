//
//  Responce.swift
//  MeetMe
//
//  Created by Stepan Ostapenko on 24.03.2022.
//

import Foundation

struct Responce<T: Codable>: Codable {
    var message: String
    var appCode: Int
    var data: T?
}

