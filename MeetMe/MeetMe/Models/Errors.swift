//
//  Errors.swift
//  MeetMe
//
//  Created by Stepan Ostapenko on 10.03.2022.
//

import Foundation

enum NetworkerError: Error {
    case noConnection
    case badResponse
    case badStatusCode(Int)
    case badData
}

enum JSONError: Error {
    case decodingError
    case encodingError
}

enum LoginErrors: Error {
    case invalidEmail
    case invalidPassword
    case noSuchUser
    case emptyLogin
    case emptyPassword
}

enum RegisterErrors: Error {
    case weakPassword
    case emailRegistered
    case passwordsDontMatch
    case emptyName
}

enum CreateMeetingError : Error {
    case noName
    case noStartingDate
    case startEndDateError
    case noMaxUser
    case noParticipants
}

enum createGroupError: Error {
    case noName
    case noInfo
    case noInterests
    case noParticipants
}
