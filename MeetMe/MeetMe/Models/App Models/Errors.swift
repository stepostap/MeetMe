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
    case emptyLogin
    case emptyPassword
}

enum RegisterErrors: Error {
    case weakPassword
    case emailRegistered
    case wrongEmailCode
    case accountNotActive
    case passwordsDontMatch
    case emptyName
    case emptyEmail
    case emptyPassword
}

enum CreateMeetingError : Error {
    case noName
    case noStartingDate
    case startEndDateError
    case startDateError
    case noMaxUser
    case noParticipants
    case unableToCreateMeeting
    case unableToEdit
}

enum MeetingError : Error {
    case maxMeetingParticipants
    case meetingDeleted
    case userAlreadyParticipant
}

enum CreateGroupError: Error {
    case noName
    case unableToCreateGroup
    case unableToEditGroup
    case userAlreadyParticipant
}

enum FriendError: Error {
    case alreadyFriend
    case unableToSendRequest
}

enum ImageStoreError: Error {
    case unableToUploadImage
    case unableToLoadImage
}

enum ChatError: Error {
    case unableToSendMessage
    case unableToLoadMessages
}

class ServerError: Error {
    internal init(message: String) {
        self.message = message
    }
    
    let message: String
}
