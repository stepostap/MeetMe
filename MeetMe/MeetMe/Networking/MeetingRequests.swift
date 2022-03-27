//
//  MeetingRequests.swift
//  MeetMe
//
//  Created by Stepan Ostapenko on 20.03.2022.
//

import Foundation

class MeetingRequests: MeetMeRequests {
    
    let formatter = DateFormatter()
    static let shared = MeetingRequests()
    let userURL = "http://localhost:8080/api/v1/meetings/"
    
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
            var request = URLRequest(url: URL(string: userURL + "create")!)
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
                        let recievedMeeting = Meeting(id: dataMeeting.id, creatorID: dataMeeting.adminId, name: dataMeeting.name, types: InterestsParser.getInterests(interestsString: dataMeeting.interests ?? []), info: dataMeeting.description ?? "", online: dataMeeting.isOnline, isPrivate: dataMeeting.isPrivate, participants: [], groups: [], participantsMax: dataMeeting.maxNumberOfParticipants, Location: dataMeeting.location ?? "", startingDate: self.formatter.date(from: dataMeeting.startDate)!, endingDate: nil, currentParticipantNumber: dataMeeting.numberOfParticipants)
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
        
    }
    
    func deleteMeeting(meetingID: Int64) {
        
    }
    
    func participateInMeeting(meetingID: Int64) {
        
    }
    
    func removeMeeting(meetingID: Int64) {
        
    }
    
    func getUserMeetings() {
        
    }
    
    func getMeetingInfo(meetingID: Int64) {
        
    }
    
    func getFilteredMeetings(filter: MeetingSearchFilter) {
        
    }
    
    func getParticipants(meetingID: Int64) {
        
    }
}
