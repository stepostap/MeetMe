//
//  MeetingRequests.swift
//  MeetMe
//
//  Created by Stepan Ostapenko on 20.03.2022.
//

import Foundation

class MeetingRequests: MeetMeRequests {
    
    static let shared = MeetingRequests()
    let meetingURL = "http://localhost:8080/api/v1/meetings/"
        
    
    func createMeeting(meeting: Meeting, completion: @escaping (Meeting?, Error?) -> (Void)) {
        if !NetworkMonitor.shared.isConnected {
            DispatchQueue.main.async { completion(nil, NetworkerError.noConnection)}
        }
        
        do {
            formatter.dateFormat = "MM-dd-yyyy HH:mm"
            
            var meetingData = MeetingDTO(id: meeting.id, adminID: meeting.creatorID, name: meeting.name, startDate: formatter.string(from: meeting.startingDate), endDate: nil, description: meeting.info, location: meeting.Location, imageURL: meeting.imageURL, isPrivate: meeting.isPrivate, isOnline: meeting.isOnline, maxNumberOfParticipants: meeting.participantsMax, numberOfParticipants: meeting.currentParticipantNumber, interests: InterestsParser.getInterestsString(interests: meeting.types))
            if let endingDate = meeting.endingDate {
                meetingData.endDate = formatter.string(from: endingDate)
            }
            let meetingInfo = try encoder.encode(meetingData)
            var request = URLRequest(url: URL(string: meetingURL + "create")!)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "POST"
            request.httpBody = meetingInfo
            
            let task = session.dataTask(with: request, completionHandler: ({ data, responce, error in
                do {
                    try self.errorCheck(data: data, response: responce, error: error)
                } catch let error {
                    DispatchQueue.main.async { completion(nil, error) }
                }
                print("no errors")
                if let data = data {
                    do {
                        let dataMeeting : MeetingDTO = try self.getData(data: data)
                        let recievedMeeting = self.createMeetingFromDTO(dataMeeting: dataMeeting)
                        if let endDate = dataMeeting.endDate {
                            recievedMeeting.endingDate = self.formatter.date(from: endDate)
                        }
                        recievedMeeting.participantsID.append(User.currentUser.account!.id)
                        //meeting.id = dataMeeting.id
                        DispatchQueue.main.async { completion(recievedMeeting, nil) }
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
    
    
    func editMeeting(meeting: Meeting, completion: @escaping (Error?) -> (Void)) {
        if !NetworkMonitor.shared.isConnected {
            DispatchQueue.main.async { completion(NetworkerError.noConnection)}
        }
        
        do {
            formatter.dateFormat = "MM-dd-yyyy HH:mm"
            
            var meetingData = EditMeetingDTO(name: meeting.name, description: meeting.info, startDate: formatter.string(from: meeting.startingDate), endDate: nil, isOnline: meeting.isOnline, locate: meeting.Location, maxNumberOfParticipants: meeting.participantsMax)
            if let endingDate = meeting.endingDate {
                meetingData.endDate = formatter.string(from: endingDate)
            }
            let meetingInfo = try encoder.encode(meetingData)
            print(meetingInfo.prettyJson)
            var request = URLRequest(url: URL(string: meetingURL + meeting.id.description + "/edit")!)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "POST"
            request.httpBody = meetingInfo
            
            let task = session.dataTask(with: request, completionHandler: ({ data, responce, error in
                do {
                    try self.errorCheck(data: data, response: responce, error: error)
                } catch let error {
                    DispatchQueue.main.async { completion(error) }
                }
                if let data = data {
                    do {
                        let _ : MeetingDTO = try self.getData(data: data)
                        DispatchQueue.main.async {
                            completion(nil)
                        }
                    } catch let error {
                        DispatchQueue.main.async { completion(error) }
                    }
                }
            }))
            task.resume()
        } catch {
            DispatchQueue.main.async { completion(JSONError.encodingError) }
        }
    }
    
    

    func removeMeeting(meetingID: Int64, completion: @escaping (Error?) -> (Void)) {
        if !NetworkMonitor.shared.isConnected {
            DispatchQueue.main.async { completion(NetworkerError.noConnection)}
        }
        
        var request = URLRequest(url: URL(string: meetingURL + meetingID.description + "/delete/" + User.currentUser.account!.id.description)!)
        //request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "DELETE"
        
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
    
    
    func participateInMeeting(accept: Bool, meetingID: Int64, completion: @escaping (Error?) -> (Void)) {
        if !NetworkMonitor.shared.isConnected {
            DispatchQueue.main.async { completion(NetworkerError.noConnection)}
        }
        
        var request = URLRequest(url: URL(string: meetingURL + meetingID.description + (accept ? "/accept/" : "/cancel/") + User.currentUser.account!.id.description)!)
        //request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        let task = emptyResponceTask(request: request, completion: completion)
        task.resume()
    }
    
    
//    func declineInvitation(meetingID: Int64, completion: @escaping (Error?) -> (Void)) {
//        if !NetworkMonitor.shared.isConnected {
//            DispatchQueue.main.async { completion(NetworkerError.noConnection)}
//        }
//
//        var request = URLRequest(url: URL(string: meetingURL + meetingID.description + "/cancel/" + User.currentUser.account!.id.description)!)
//        //request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.httpMethod = "POST"
//
//        let task = emptyResponceTask(request: request, completion: completion)
//        task.resume()
//    }
    
    
    func deleteMeeting(meetingID: Int64, completion: @escaping (Error?) -> (Void)) {
        if !NetworkMonitor.shared.isConnected {
            DispatchQueue.main.async { completion(NetworkerError.noConnection)}
        }
        
        var request = URLRequest(url: URL(string: meetingURL + meetingID.description)!)
        //request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "DELETE"
        
        let task = emptyResponceTask(request: request, completion: completion)
        task.resume()
        
    }
    
    
    func getUserMeetings(meetingType: String, completion: @escaping (String, [Meeting]?, Error?) -> (Void)) {
        
        if !NetworkMonitor.shared.isConnected {
            DispatchQueue.main.async { completion(meetingType, nil, NetworkerError.noConnection)}
        }
        print("getting meetings \(meetingType)")
        var request = URLRequest(url: URL(string: meetingURL + User.currentUser.account!.id.description + "/\(meetingType)")!)
        //request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "Get"
        
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
                    DispatchQueue.main.async { completion(meetingType, meetings, nil) }
                } catch let error {
                    DispatchQueue.main.async { completion(meetingType, nil, error) }
                }
            }
        }))
        task.resume()
    }
    
    func getUserInvitations(completion: @escaping (UserInvitations?, Error?) -> (Void)) {
        if !NetworkMonitor.shared.isConnected {
            DispatchQueue.main.async { completion(nil, NetworkerError.noConnection)}
        }
       
        var request = URLRequest(url: URL(string: meetingURL + User.currentUser.account!.id.description + "/invites")!)
        //request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "GET"
        
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
                    
                    for meetingsDatum in meetingsData {
                        var meetings = [Meeting]()
                        let key = self.getShortInvitationInfo(str: meetingsDatum.key)
                        
                        for meetingDTO in meetingsDatum.value {
                            meetings.append(self.createMeetingFromDTO(dataMeeting: meetingDTO))
                        }
                        
                        if key.id == User.currentUser.account!.id {
                            invitations.personalInvitations = meetings
                        } else {
                            invitations.groupInvitations.append((key,meetings))
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
    
//    func getMeetingInfo(meetingID: Int64) {
//
//    }
    
    func getFilteredMeetings(filter: MeetingSearchFilter) {
        
    }
    
    
    func inviteAccountsToMeeting(accountsID: [Int64], meetingID: Int64, completion: @escaping (Error?) -> (Void)) {
        if !NetworkMonitor.shared.isConnected {
            DispatchQueue.main.async { completion(NetworkerError.noConnection)}
        }
        
        let idsData = try! encoder.encode(accountsID)
        var request = URLRequest(url: URL(string: meetingURL + meetingID.description + "/invite")!)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = idsData
        
        let task = emptyResponceTask(request: request, completion: completion)
        task.resume()
    }
    
    
    func getParticipants(meetingID: Int64, completion: @escaping ([Account]?, Error?) -> (Void)) {
        if !NetworkMonitor.shared.isConnected {
            DispatchQueue.main.async { completion(nil, NetworkerError.noConnection)}
        }
        
        var request = URLRequest(url: URL(string: meetingURL + meetingID.description + "/participants")!)
        //request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "GET"
        
        let task = accountsResponceTask(request: request, completion: completion)
        task.resume()
    }
}
