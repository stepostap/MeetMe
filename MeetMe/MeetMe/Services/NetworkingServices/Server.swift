////
////  Server.swift
////  MeetMe
////
////  Created by Stepan Ostapenko on 10.03.2022.
////
//
//import Foundation
//
//
//enum ServerResponce: Int {
//    case success = 0
//    case noSuchUser = 1
//
//}
//
//class Server {
//    static var shared = Server()
//    
//    public var users = [LoginInfo: User]()
//
//    var user = User()
//    var secondUser = User()
//    var romaUser = User()
//
//    init() {
//        let me = LoginInfo(email: "Stepostap@gmail.com", password: "12345")
//        let notMe = LoginInfo(email: "stepan@ostapenko.net", password: "1")
//        //let roma = loginInfo(email: "roma@gmail.com", password: "1")
//
//        user.account = Account(id: 1, name: "Степан Остапенко", info: "Студент из Москвы, 20 лет.", imageDataURL: "", interests: [.photography, .tabletopGames, .cinema, .bar], socialMediaLinks: [:])
//
//        secondUser.account = Account(id: 2, name: "Степа розовая попа", info: "ихааааааааааа", imageDataURL: "", interests: [.club, .gaming], socialMediaLinks: [:])
//
//        romaUser.account = Account(id: 3, name: "Роман Ренатович", info: "Насзмуъдтиновъ", imageDataURL: "", interests: [.club, .gaming], socialMediaLinks: [:])
//
////        user.friends.append(secondUser.account!)
////        user.friends.append(romaUser.account!)
////        secondUser.friends.append(user.account!)
//
//
////        let meeting1 = Meeting(id: 1, creatorID: user.account!.id, name: "Настолки", types: [.tabletopGames], info: "Собираемся играть в настолки, в первую очередь в ДНД", online: false, isPrivate: false, participants: [1], groups: [], participantsMax: 10, Location: "ETO кофейня", startingDate: Date.distantFuture, endingDate: Date.distantFuture, currentParticipantNumber: 1)
////
////        let meeting2 = Meeting(id: 2, creatorID: secondUser.account!.id, name: "ДР Коли", types: [.tabletopGames], info: "Отмечать будем у меня на даче, всех жду!", online: false, isPrivate: true, participants: [1, 2], groups: [], participantsMax: 20, Location: "Улица Пушкина, дом Калатушкина", startingDate: Date.distantFuture, endingDate: Date.distantFuture, currentParticipantNumber: 5)
//
//        let firstGroup = Group(id: 1, groupImage: "", groupName: "Group1", groupInfo: "", interests: [.cinema, .bar, .photography, .club, .dancing, .gaming], meetings: [], participants: [user.account!.id, secondUser.account!.id, romaUser.account!.id], admins: [user.account!.id])
//        let secondGroup = Group(id: 2, groupImage: "", groupName: "Group2", groupInfo: "Группа группа группочка 2", interests: [.cinema, .bar], meetings: [], participants: [user.account!.id, secondUser.account!.id, romaUser.account!.id], admins: [user.account!.id])
//
//        //user.groups.append(firstGroup)
//        //user.groups.append(secondGroup)
////        user.plannedMeetings.append(meeting1)
////        user.plannedMeetings.append(meeting2)
//
//        users[me] = user
//        users[notMe] = user
//
//    }
//
//    public func getUser(data: Data) -> Data? {
//        let decoder = JSONDecoder()
//        let userLoginInfo = try! decoder.decode(LoginInfo.self, from: data)
//
//        if let user = users[userLoginInfo] {
//            let userJSON = try! JSONEncoder().encode(user.account)
//            return userJSON
//        }
//
//        return nil
//    }
//
//    public func getUserFromId(id: Int64) -> Account? {
//        var selectedUser: Account?
//        for user in users {
//            if user.value.account?.id == id {
//                selectedUser = user.value.account
//            }
//        }
//        return selectedUser
//    }
//
////    public func registerUser(data: Data) -> Data? {
////        let info = try! JSONDecoder().decode([String].self, from: data)
////
////        for loginInfo in users.keys {
////            if loginInfo.email.elementsEqual(info[0]) {
////                return try! JSONEncoder().encode(ServerResponce.noSuchUser.rawValue)
////            }
////        }
////
////        let newUserLoginInfo = LoginInfo(email: info[0], password: info[1])
////        //let newUserAccount = Account(id: Int64.random(in: 0..<Int64.max), name: info[2], info: "", imageDataURL: "")
////        let newUser = User()
////        //newUser.account = newUserAccount
////        //users[newUserLoginInfo] = newUser
////
////        //let newUserJSON = try! JSONEncoder().encode(newUserAccount)
////        return newUserJSON
////    }
//
//    public func updateUser(data: Data) -> Data? {
//        let updatedUser = try! JSONDecoder().decode(Account.self, from: data)
//
//        for user in users {
//            if user.value.account?.id == updatedUser.id {
//                users[user.key]?.account = updatedUser
//                return try! JSONEncoder().encode(ServerResponce.success.rawValue)
//            }
//        }
//
//        return try! JSONEncoder().encode(ServerResponce.noSuchUser.rawValue)
//    }
//
//    public func newMeeting(data: Data) -> Data {
//        let meeting = try! JSONDecoder().decode(Meeting.self, from: data)
//
//        meeting.id = Int64.random(in: 0..<Int64.max)
//
//        for user in users {
//            if meeting.isUserParticipant {
//                //user.value.plannedMeetings.append(meeting)
//            }
//        }
//
//        return try! JSONEncoder().encode(meeting)
//    }
//
//    public func getUserMeetings(data: Data) -> Data? {
//        let userId = try! JSONDecoder().decode(Int64.self, from: data)
//
////        for user in users {
////            if user.value.account?.id == userId {
////                var meetings = [Meeting]()
////                for meeting in user.value.plannedMeetings {
////                    meetings.append(meeting)
////                }
////                for meeting in user.value.meetingHistory {
////                    meetings.append(meeting)
////                }
////                for meeting in user.value.meetingInvitations {
////                    meetings.append(meeting)
////                }
////                return try! JSONEncoder().encode(meetings)
////            }
////        }
//
//        return nil
//    }
//
//    public func participateInMeeting(data: Data) {
//        let info = try! JSONDecoder().decode([Int64].self, from: data)
//        let userId = info[0]
//        let meetingId = info[1]
//
//        for user in users {
//            if user.value.account?.id == userId {
//                var invitetionMeetings = [Meeting]()
//                var meeting: Meeting?
////                for meetingInv in user.value.meetingInvitations {
////                    if meetingInv.id == meetingId {
////                        meeting = meetingInv
////                    } else {
////                        invitetionMeetings.append(meetingInv)
////                    }
////                }
////                meeting?.currentParticipantNumber += 1
////                meeting?.participantsID.append(userId)
////                user.value.meetingInvitations.removeAll()
////                user.value.meetingInvitations = invitetionMeetings
////                user.value.plannedMeetings.append(meeting!)
//
//            }
//        }
//    }
//}
