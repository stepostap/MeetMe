//
//  GroupRequests.swift
//  MeetMe
//
//  Created by Stepan Ostapenko on 29.03.2022.
//

import Foundation
import UIKit

class GroupRequests: MeetMeRequests {
    static let shared = GroupRequests()
    let groupURL = "http://localhost:8080/api/v1/groups/"
    
    
    func getUserGroups(completion: @escaping ([Group]?, Error?) -> (Void)) {
        if !NetworkMonitor.shared.isConnected {
            DispatchQueue.main.async { completion(nil, NetworkerError.noConnection)}
        }
        
        var request = URLRequest(url: URL(string: groupURL + "user/" + User.currentUser.account!.id.description)!)
        //request.setValue("application/json", forHTTPHeaderField: "Content-Type")
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
                    let groupsData : [GroupDTO] = try self.getData(data: data)
                    var groups = [Group]()
                    for dto in groupsData {
                        groups.append(self.createGroupFromDTO(dataGroup: dto))
                    }
                    DispatchQueue.main.async { completion(groups, nil) }
                } catch let error {
                    DispatchQueue.main.async { completion(nil, error) }
                }
            }
        }))
        task.resume()
    }
    
    
    func createGroup(image: UIImage? = nil, group: Group, completion: @escaping (Group?, Error?) -> (Void)) {
        if !NetworkMonitor.shared.isConnected {
            DispatchQueue.main.async { completion(nil, NetworkerError.noConnection)}
        }
        
        do {
            let groupData = GroupDTO(id: group.id, adminID: User.currentUser.account!.id, name: group.groupName, description: group.groupInfo, photoURL: "", isPrivate: group.isPrivate, interests: InterestsParser.getInterestsString(interests: group.interests))
            let groupInfo = try encoder.encode(groupData)
            var request = URLRequest(url: URL(string: groupURL + "create")!)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "POST"
            request.httpBody = groupInfo
            request.setValue("Bearer \(MeetMeRequests.JWTToken)", forHTTPHeaderField: "Authorization")
    
            let task = session.dataTask(with: request, completionHandler: ({ data, responce, error in
                do {
                    try self.errorCheck(data: data, response: responce, error: error)
                } catch let error {
                    DispatchQueue.main.async { completion(nil, error) }
                }
                if let data = data {
                    do {
                        let dataGroup : GroupDTO = try self.getData(data: data)
                        if let image = image {
                            self.uploadImage(groupID: dataGroup.id, image: image, completion: completion)
                        } else {
                            let recievedGroup = self.createGroupFromDTO(dataGroup: dataGroup)
                            DispatchQueue.main.async { completion(recievedGroup, nil) }
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
    
    
    func getGroupMeetings(groupID: Int64, completion: @escaping ([Meeting]?, Error?) -> (Void)) {
        if !NetworkMonitor.shared.isConnected {
            DispatchQueue.main.async { completion(nil, NetworkerError.noConnection)}
        }
        
        var request = URLRequest(url: URL(string: groupURL + groupID.description + "/meetings")!)
        //request.setValue("application/json", forHTTPHeaderField: "Content-Type")
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
                    let meetingData : [MeetingDTO] = try self.getData(data: data)
                    var meetings = [Meeting]()
                    for dto in meetingData {
                        meetings.append(self.createMeetingFromDTO(dataMeeting: dto))
                    }
                    //meeting.id = dataMeeting.id
                    DispatchQueue.main.async { completion(meetings, nil) }
                } catch let error {
                    DispatchQueue.main.async { completion(nil, error) }
                }
            }
        }))
        task.resume()
    }
    
    
    func getGroupParticipants(groupID: Int64, completion: @escaping ([Account]?, Error?) -> (Void)) {
        if !NetworkMonitor.shared.isConnected {
            DispatchQueue.main.async { completion(nil, NetworkerError.noConnection)}
        }
        
        var request = URLRequest(url: URL(string: groupURL + groupID.description + "/participants")!)
        //request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "GET"
        request.setValue("Bearer \(MeetMeRequests.JWTToken)", forHTTPHeaderField: "Authorization")
        
        let task = accountsResponceTask(request: request, completion: completion)
        task.resume()
    }
    
    
    func addNewGroupParticipants(participants: [Int64], groupID: Int64, completion: @escaping (Error?) -> (Void)) {
        if !NetworkMonitor.shared.isConnected {
            DispatchQueue.main.async { completion(NetworkerError.noConnection)}
        }
        
        let idsData = try! encoder.encode(participants)
        var request = URLRequest(url: URL(string: groupURL + groupID.description + "/participants")!)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = idsData
        request.setValue("Bearer \(MeetMeRequests.JWTToken)", forHTTPHeaderField: "Authorization")
        
        let task = emptyResponceTask(request: request, completion: completion)
        task.resume()
    }
    
    
    func inviteGroupsToMeeting(groups: [Int64], meetingID: Int64, completion: @escaping (Error?) -> (Void)) {
        if !NetworkMonitor.shared.isConnected {
            DispatchQueue.main.async { completion(NetworkerError.noConnection)}
        }
        
        let idsData = try! encoder.encode(groups)
        var request = URLRequest(url: URL(string: groupURL + "invite/" + meetingID.description)!)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = idsData
        request.setValue("Bearer \(MeetMeRequests.JWTToken)", forHTTPHeaderField: "Authorization")
        
        let task = emptyResponceTask(request: request, completion: completion)
        task.resume()
    }
    
    
    func leaveGroup(groupID: Int64, completion: @escaping (Error?) -> (Void)) {
        if !NetworkMonitor.shared.isConnected {
            DispatchQueue.main.async { completion(NetworkerError.noConnection)}
        }
        
        var request = URLRequest(url: URL(string: groupURL + groupID.description + "/participant/" + User.currentUser.account!.id.description)!)
        //request.setValue("application/json", forHTTPHeaderField: "Content-Type")
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
                    let _ : GroupDTO = try self.getData(data: data)
                    //let recievedGroup = self.createGroupFromDTO(dataGroup: dataMeeting)
                    //meeting.id = dataMeeting.id
                    DispatchQueue.main.async { completion(nil) }
                } catch let error {
                    DispatchQueue.main.async { completion(error) }
                }
            }
        }))
        task.resume()
    }
    
    
    func deleteGroup(groupID: Int64, completion: @escaping (Error?) -> (Void)) {
        if !NetworkMonitor.shared.isConnected {
            DispatchQueue.main.async { completion(NetworkerError.noConnection)}
        }
        
        var request = URLRequest(url: URL(string: groupURL + groupID.description + "/" + User.currentUser.account!.id.description)!)
        //request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(MeetMeRequests.JWTToken)", forHTTPHeaderField: "Authorization")
        
        let task = emptyResponceTask(request: request, completion: completion)
        task.resume()
    }
    
    
    func respondMeetingForGroupInvitation(accept: Bool, groupID: Int64, meetingID: Int64, completion: @escaping (Error?) -> (Void)) {
        if !NetworkMonitor.shared.isConnected {
            DispatchQueue.main.async { completion(NetworkerError.noConnection)}
        }
        
        var request = URLRequest(url: URL(string: groupURL + groupID.description + (accept ? "/accept/" : "/cancel/") + meetingID.description)!)
        //request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.setValue("Bearer \(MeetMeRequests.JWTToken)", forHTTPHeaderField: "Authorization")
        
        let task = emptyResponceTask(request: request, completion: completion)
        task.resume()
    }
    
    
    func uploadImage(groupID: Int64, image: UIImage, completion: @escaping (Group?, Error?) -> (Void)) {
        if !NetworkMonitor.shared.isConnected {
            DispatchQueue.main.async { completion(nil, NetworkerError.noConnection)}
        }
        
        var request = URLRequest(url: URL(string: groupURL + groupID.description + "/image")!)
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
                    let dataMeeting : GroupDTO = try self.getData(data: data)
                    let recievedGroup = self.createGroupFromDTO(dataGroup: dataMeeting)
                    DispatchQueue.main.async { completion(recievedGroup, nil) }
                } catch let error {
                    DispatchQueue.main.async { completion(nil, error) }
                }
            }
        }))
        task.resume()
    }
    
    func getFilteredGroups(query: String, filter: [Interests], completion: @escaping ([[Group]]?, Error?) ->  (Void)) {
        if !NetworkMonitor.shared.isConnected {
            DispatchQueue.main.async { completion(nil, NetworkerError.noConnection)}
        }
        let searchInfo = MeetingSearchDTO(searchQuery: query, interests: InterestsParser.getInterestsString(interests: filter))
        let searchData = try! encoder.encode(searchInfo)
        var request = URLRequest(url: URL(string: groupURL + User.currentUser.account!.id.description + "/search")!)
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
                    let groupData : [String:[GroupDTO]] = try self.getData(data: data)
                    var results = [[Group]]()
                    var groups = [Group]()
                    for group in groupData["my"]! {
                        groups.append(self.createGroupFromDTO(dataGroup: group))
                    }
                    results.append(groups)
                    groups.removeAll()
                    for group in groupData["global"]! {
                        groups.append(self.createGroupFromDTO(dataGroup: group))
                    }
                    results.append(groups)
                    
                    DispatchQueue.main.async { completion(results, nil) }
                } catch let error {
                    DispatchQueue.main.async { completion(nil, error) }
                }
            }
        }))
        task.resume()
    }
}
