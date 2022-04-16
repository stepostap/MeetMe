//
//  MeetingRequests.swift
//  MeetMe
//
//  Created by Stepan Ostapenko on 20.03.2022.
//

import Foundation
import UIKit

/// Создание, отправка и обработка запросов для взаимодействия с мероприятиями 
class MeetingRequests: MeetMeRequests {
    /// Статический экзмепляр класса
    static let shared = MeetingRequests()
    /// Базовая часть URL дла запросов
    let meetingURL = "http://localhost:8080/api/v1/meetings/"
    
    /// Создание и отправка запроса на создание нового мероприятия и обработка полученного ответа
    func createMeeting(image: UIImage?, meeting: Meeting, completion: @escaping (Meeting?, Error?) -> (Void)) {
        if !NetworkMonitor.shared.isConnected {
            DispatchQueue.main.async { completion(nil, NetworkerError.noConnection)}
        }
        
        do {
            formatter.dateFormat = "MM-dd-yyyy HH:mm"
            
            var meetingData = MeetingDTO(id: meeting.id, adminID: meeting.creatorID, chatId: meeting.chatID, name: meeting.name, startDate: formatter.string(from: meeting.startingDate), endDate: nil, description: meeting.info, location: meeting.Location, imageURL: meeting.imageURL, isPrivate: meeting.isPrivate, isOnline: meeting.isOnline, maxNumberOfParticipants: meeting.participantsMax, numberOfParticipants: meeting.currentParticipantNumber, interests: InterestsParser.getInterestsString(interests: meeting.types), isParticipant: nil)
            if let endingDate = meeting.endingDate {
                meetingData.endDate = formatter.string(from: endingDate)
            }
            let meetingInfo = try encoder.encode(meetingData)
            
            var request = URLRequest(url: URL(string: meetingURL + "create")!)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "POST"
            request.httpBody = meetingInfo
            request.setValue("Bearer \(MeetMeRequests.JWTToken)", forHTTPHeaderField: "Authorization")
            
            let task = session.dataTask(with: request, completionHandler: ({ data, responce, error in
                do {
                    try self.errorCheck(data: data, response: responce, error: error)
                } catch let error {
                    DispatchQueue.main.async { completion(nil, error) }
                }
                if let data = data {
                    do {
                        let dataMeeting : MeetingDTO = try self.getData(data: data)
                        if let image = image {
                            self.uploadImage(meetingID: dataMeeting.id, image: image, completion: completion)
                        } else {
                            let recievedMeeting = self.createMeetingFromDTO(dataMeeting: dataMeeting)
                            DispatchQueue.main.async { completion(recievedMeeting, nil) }
                        }
                    } catch let error {
                        DispatchQueue.main.async { completion(nil, error) }
                    }
                }
            }))
            task.resume()
        } catch {
            DispatchQueue.main.async { completion(nil, JSONError.encodingError) }
        }
    }
    
    /// Создание и отправка запроса на редактирование существующего мероприятия пользователя и обработка полученного ответа
    func editMeeting(image: UIImage?, meeting: Meeting, completion: @escaping (Meeting?, Error?) -> (Void)) {
        if !NetworkMonitor.shared.isConnected {
            DispatchQueue.main.async { completion(nil, NetworkerError.noConnection)}
        }
        
        do {
            formatter.dateFormat = "MM-dd-yyyy HH:mm"
            
            var meetingData = EditMeetingDTO(name: meeting.name, description: meeting.info, startDate: formatter.string(from: meeting.startingDate), endDate: nil, isOnline: meeting.isOnline, locate: meeting.Location, maxNumberOfParticipants: meeting.participantsMax)
            if let endingDate = meeting.endingDate {
                meetingData.endDate = formatter.string(from: endingDate)
            }
            let meetingInfo = try encoder.encode(meetingData)
            print(meetingInfo.prettyJson as Any)
            var request = URLRequest(url: URL(string: meetingURL + meeting.id.description + "/edit")!)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "POST"
            request.httpBody = meetingInfo
            request.setValue("Bearer \(MeetMeRequests.JWTToken)", forHTTPHeaderField: "Authorization")
            
            let task = session.dataTask(with: request, completionHandler: ({ data, responce, error in
                do {
                    try self.errorCheck(data: data, response: responce, error: error)
                } catch let error {
                    DispatchQueue.main.async { completion(nil, error) }
                }
                if let data = data {
                    do {
                        let dataMeeting : MeetingDTO = try self.getData(data: data)
                        if let image = image {
                            self.uploadImage(meetingID: dataMeeting.id, image: image, completion: completion)
                        } else {
                            let recievedMeeting = self.createMeetingFromDTO(dataMeeting: dataMeeting)
                            if let endDate = dataMeeting.endDate {
                                recievedMeeting.endingDate = self.formatter.date(from: endDate)
                            }
                            DispatchQueue.main.async { completion(recievedMeeting, nil) }
                        }
                        
                    } catch let error {
                        DispatchQueue.main.async { completion(nil, error) }
                    }
                }
            }))
            task.resume()
        } catch {
            DispatchQueue.main.async { completion(nil, JSONError.encodingError) }
        }
    }
    
    /// Создание и отправка запроса на отказ пользователя от участия в мероприятии с meetingID и обработка полученного ответа
    func removeMeeting(meetingID: Int64, completion: @escaping (Error?) -> (Void)) {
        if !NetworkMonitor.shared.isConnected {
            DispatchQueue.main.async { completion(NetworkerError.noConnection)}
        }
        
        var request = URLRequest(url: URL(string: meetingURL + meetingID.description + "/delete/" + User.currentUser.account!.id.description)!)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(MeetMeRequests.JWTToken)", forHTTPHeaderField: "Authorization")
        
        let task = session.dataTask(with: request, completionHandler: ({ data, responce, error in
            do {
                try self.errorCheck(data: data, response: responce, error: error)
            } catch let error {
                DispatchQueue.main.async { completion(error) }
            }
            if let data = data {
                do {
                    let _ : MeetingDTO = try self.getData(data: data)
                    DispatchQueue.main.async { completion(nil) }
                } catch let error {
                    DispatchQueue.main.async { completion(error) }
                }
            }
        }))
        task.resume()
    }
    
    /// Создание и отправка ответа на приглашение пользователя на мероприятие и обработка полученного ответа
    func answerToInvitation(accept: Bool, meetingID: Int64, completion: @escaping (Error?) -> (Void)) {
        if !NetworkMonitor.shared.isConnected {
            DispatchQueue.main.async { completion(NetworkerError.noConnection)}
        }
        
        var request = URLRequest(url: URL(string: meetingURL + meetingID.description + (accept ? "/accept/" : "/cancel/") + User.currentUser.account!.id.description)!)
        print(meetingURL + meetingID.description + (accept ? "/accept/" : "/cancel/") + User.currentUser.account!.id.description)
        request.httpMethod = "POST"
        request.setValue("Bearer \(MeetMeRequests.JWTToken)", forHTTPHeaderField: "Authorization")
        
        let task = emptyResponceTask(request: request, completion: completion)
        task.resume()
    }
    
    /// Создание и отправка запроса на участие пользователя в мероприятии с meetingID и обработка полученного ответа
    func participateInMeeting(meetingID: Int64, completion: @escaping (Error?) -> (Void)) {
        if !NetworkMonitor.shared.isConnected {
            DispatchQueue.main.async { completion(NetworkerError.noConnection)}
        }
        
        var request = URLRequest(url: URL(string: meetingURL + meetingID.description + "/add/" + User.currentUser.account!.id.description)!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(MeetMeRequests.JWTToken)", forHTTPHeaderField: "Authorization")
        
        let task = emptyResponceTask(request: request, completion: completion)
        task.resume()
    }
    
    /// Создание и отправка запроса на отмену проведения мероприятия с meetingID и обработка полученного ответа
    func deleteMeeting(meetingID: Int64, completion: @escaping (Error?) -> (Void)) {
        if !NetworkMonitor.shared.isConnected {
            DispatchQueue.main.async { completion(NetworkerError.noConnection)}
        }
        
        var request = URLRequest(url: URL(string: meetingURL + meetingID.description)!)
        //request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(MeetMeRequests.JWTToken)", forHTTPHeaderField: "Authorization")
        
        let task = emptyResponceTask(request: request, completion: completion)
        task.resume()
        
    }
    
    /// Создание и отправка запроса на получение списка мероприй пользователя и обработка полученного ответа
    func getUserMeetings(meetingType: MeetingType, completion: @escaping (MeetingType, [Meeting]?, Error?) -> (Void)) {
        
        if !NetworkMonitor.shared.isConnected {
            DispatchQueue.main.async { completion(meetingType, nil, NetworkerError.noConnection)}
        }
        print("getting meetings \(meetingType)")
        var request = URLRequest(url: URL(string: meetingURL + User.currentUser.account!.id.description + "/\(meetingType.rawValue)")!)
        //request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "Get"
        request.setValue("Bearer \(MeetMeRequests.JWTToken)", forHTTPHeaderField: "Authorization")
        
        let task = session.dataTask(with: request, completionHandler: ({ data, responce, error in
            do {
                try self.errorCheck(data: data, response: responce, error: error)
            } catch let error {
                DispatchQueue.main.async { completion(meetingType, nil, error) }
            }
            if let data = data {
                do {
                    let meetingsData : [MeetingDTO] = try self.getData(data: data)
                    var meetings = [Meeting]()
                    for meetingsDatum in meetingsData {
                        meetings.append(self.createMeetingFromDTO(dataMeeting: meetingsDatum))
                    }
                    if meetingType == .visited {
                        meetings = meetings.sorted(by: { $0.startingDate > $1.startingDate })
                    } else {
                        meetings = meetings.sorted(by: { $0.startingDate < $1.startingDate })
                    }
                    DispatchQueue.main.async { completion(meetingType, meetings, nil) }
                } catch let error {
                    DispatchQueue.main.async { completion(meetingType, nil, error) }
                }
            }
        }))
        task.resume()
    }
    
    /// Создание и отправка запроса на получение списка приглашений пользователя на мероприятия и обработка полученного ответа
    func getUserInvitations(completion: @escaping (UserInvitations?, Error?) -> (Void)) {
        if !NetworkMonitor.shared.isConnected {
            DispatchQueue.main.async { completion(nil, NetworkerError.noConnection)}
        }
       
        var request = URLRequest(url: URL(string: meetingURL + User.currentUser.account!.id.description + "/invites")!)
        request.httpMethod = "GET"
        request.setValue("Bearer \(MeetMeRequests.JWTToken)", forHTTPHeaderField: "Authorization")
        
        let task = session.dataTask(with: request, completionHandler: ({ data, responce, error in
            do {
                try self.errorCheck(data: data, response: responce, error: error)
            } catch let error {
                DispatchQueue.main.async { completion(nil, error) }
            }
            if let data = data {
                do {
                    let meetingsData : [String:[MeetingDTO]] = try self.getData(data: data)
                    let invitations = UserInvitations()
                    print("Count: \(meetingsData.count)")
                    for meetingsDatum in meetingsData {
                        var meetings = [Meeting]()
                        let key = self.getShortInvitationInfo(str: meetingsDatum.key)
                        print(key)
                        for meetingDTO in meetingsDatum.value {
                            meetings.append(self.createMeetingFromDTO(dataMeeting: meetingDTO))
                        }
                        
                        if key.id == User.currentUser.account!.id && key.name == "User" {
                            invitations.personalInvitations = meetings
                        } else if meetings.count != 0 {
                            invitations.groupInvitations.append((key,meetings))
                        }
                    }
                    
                    for pair in invitations.groupInvitations {
                        print("Group: \(pair.group)")
                        for meetinggg in pair.meetings {
                            print("     Meeting: \(meetinggg.name)")
                        }
                    }
                    
                    DispatchQueue.main.async { completion(invitations, nil) }
                } catch let error {
                    DispatchQueue.main.async { completion(nil, error) }
                }
            }
        }))
        task.resume()
    }
    
    /// Создание и отправка запроса на поиск мероприятий по их названию и дополнительным фильтрам (дата начала, макс. участников и т.д.) и обработка полученного ответа
    func getFilteredMeetings(meetingType: MeetingType, query: String, filter: MeetingSearchFilter, completion: @escaping ([(sectionHeader: String, meetings: [Meeting])]?, Error?) ->  (Void)) {
        if !NetworkMonitor.shared.isConnected {
            DispatchQueue.main.async { completion(nil, NetworkerError.noConnection)}
        }
        formatter.dateFormat = "MM-dd-yyyy HH:mm"
        var searchInfo = MeetingSearchDTO(searchQuery: query, interests: InterestsParser.getInterestsString(interests: filter.types), maxNumberOfParticipants: filter.participantsMax)
        if let startDate = filter.startingDate {
            searchInfo.startDate = formatter.string(from: startDate)
        }
        if let endDate = filter.endingDate {
            searchInfo.endDate = formatter.string(from: endDate)
        }

        let searchData = try! encoder.encode(searchInfo)
        var request = URLRequest(url: URL(string: meetingURL + User.currentUser.account!.id.description + "/\(meetingType.rawValue)/search")!)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = searchData
        request.setValue("Bearer \(MeetMeRequests.JWTToken)", forHTTPHeaderField: "Authorization")
        
        let task = session.dataTask(with: request, completionHandler: ({ data, responce, error in
            do {
                try self.errorCheck(data: data, response: responce, error: error)
            } catch let error {
                DispatchQueue.main.async { completion(nil, error) }
            }
            if let data = data {
                do {
                    var results = [(sectionHeader: String, meetings: [Meeting])]()
                    var meetings = [Meeting]()
                    switch meetingType {
                    case .visited:
                        let meetingsData: [MeetingDTO] = try self.getData(data: data)
                        for meetingsDatum in meetingsData {
                            meetings.append(self.createMeetingFromDTO(dataMeeting: meetingsDatum))
                        }
                        results.append(("Посещенные мероприятия", meetings))
                    case .planned:
                        let meetingsData : [String:[MeetingDTO]] = try self.getData(data: data)
                        for meetingsDatum in meetingsData["my"]! {
                            meetings.append(self.createMeetingFromDTO(dataMeeting: meetingsDatum))
                        }
                        results.append(("Мои мероприятия", meetings))
                        meetings.removeAll()
                        for meetingsDatum in meetingsData["global"]! {
                            meetings.append(self.createMeetingFromDTO(dataMeeting: meetingsDatum))
                        }
                        results.append(("Глобальный поиск" ,meetings))
                    case .invitations:
                        let meetingsData : [String:[MeetingDTO]] = try self.getData(data: data)
                        for meetingsDatum in meetingsData {
                            for meetingDTO in meetingsDatum.value {
                                meetings.append(self.createMeetingFromDTO(dataMeeting: meetingDTO))
                            }
                            results.append((meetingsDatum.key, meetings))
                            meetings.removeAll()
                        }
                    }
                    
                    DispatchQueue.main.async { completion(results, nil) }
                } catch let error {
                    DispatchQueue.main.async { completion(nil, error) }
                }
            }
        }))
        task.resume()
    }
    
    /// Создание и отправка запроса на приглашение друзей и групп,  в которых состоит пользователь, на мероприятие и обработка полученного ответа
    func inviteAccountsToMeeting(invites: MeetingInvitationsDTO, meetingID: Int64, completion: @escaping (Error?) -> (Void)) {
        if !NetworkMonitor.shared.isConnected {
            DispatchQueue.main.async { completion(NetworkerError.noConnection)}
        }
        
        let idsData = try! encoder.encode(invites)
        var request = URLRequest(url: URL(string: meetingURL + meetingID.description + "/invite")!)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = idsData
        request.setValue("Bearer \(MeetMeRequests.JWTToken)", forHTTPHeaderField: "Authorization")
        
        let task = emptyResponceTask(request: request, completion: completion)
        task.resume()
    }
    
    /// Создание и отправка запроса на получение списка участников мероприятия и обработка полученного ответа
    func getParticipants(meetingID: Int64, completion: @escaping ([Account]?, Error?) -> (Void)) {
        if !NetworkMonitor.shared.isConnected {
            DispatchQueue.main.async { completion(nil, NetworkerError.noConnection)}
        }
        
        var request = URLRequest(url: URL(string: meetingURL + meetingID.description + "/participants")!)
        //request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "GET"
        request.setValue("Bearer \(MeetMeRequests.JWTToken)", forHTTPHeaderField: "Authorization")
        
        let task = accountsResponceTask(request: request, completion: completion)
        task.resume()
    }
    
    /// Создание и отправка запроса на загрузку изображения мероприятия на сервер и обработка полученного ответа 
    func uploadImage(meetingID: Int64, image: UIImage, completion: @escaping (Meeting?, Error?) -> (Void)) {
        if !NetworkMonitor.shared.isConnected {
            DispatchQueue.main.async { completion(nil, NetworkerError.noConnection)}
        }
        
        var request = URLRequest(url: URL(string: meetingURL + meetingID.description + "/image")!)
        request.httpMethod = "POST"
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.httpBody = createBody(
            boundary: boundary,
            data: image.jpegData(compressionQuality: 0.7)!,
            mimeType: "image/jpg",
            fileName: "image.jpg")
        request.setValue("Bearer \(MeetMeRequests.JWTToken)", forHTTPHeaderField: "Authorization")
        
        let task = session.dataTask(with: request, completionHandler: ({ data, responce, error in
            do {
                try self.errorCheck(data: data, response: responce, error: error)
            } catch let error {
                DispatchQueue.main.async { completion(nil, error) }
            }
            
            if let data = data {
                do {
                    let dataMeeting : MeetingDTO = try self.getData(data: data)
                    let meeting = self.createMeetingFromDTO(dataMeeting: dataMeeting)
                    DispatchQueue.main.async { completion(meeting, nil) }
                } catch let error {
                    DispatchQueue.main.async { completion(nil, error) }
                }
            }
        }))
        task.resume()
    }
}
