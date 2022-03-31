//
//  MeetMeRequests.swift
//  MeetMe
//
//  Created by Stepan Ostapenko on 24.03.2022.
//

import Foundation

class MeetMeRequests {
    let session = URLSession(configuration: .default)
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()
    let formatter = DateFormatter()
    
    func createMeetingFromDTO(dataMeeting: MeetingDTO) -> Meeting {
        formatter.dateFormat = "MM-dd-yyyy HH:mm"
        let recievedMeeting = Meeting(id: dataMeeting.id, creatorID: dataMeeting.adminId, name: dataMeeting.name, types: InterestsParser.getInterests(interestsString: dataMeeting.interests ?? []), info: dataMeeting.description ?? "", online: dataMeeting.isOnline, isPrivate: dataMeeting.isPrivate, participants: [], groups: [], participantsMax: dataMeeting.maxNumberOfParticipants, Location: dataMeeting.location ?? "", startingDate: self.formatter.date(from: dataMeeting.startDate)!, endingDate: nil, currentParticipantNumber: dataMeeting.numberOfParticipants)
        return recievedMeeting
    }
    
    
    func createAccountFromDTO(dataAccount: AccountDTO) -> Account {
        let account = Account(id: dataAccount.id, name: dataAccount.fullName, info: dataAccount.description ?? "", imageDataURL: dataAccount.photoUrl ?? "", interests: InterestsParser.getInterests(interestsString: dataAccount.interests ?? []), socialMediaLinks: dataAccount.links ?? [:])
        return account
    }
    
    
    func createGroupFromDTO(dataGroup: GroupDTO) -> Group {
        let group = Group(id: dataGroup.id, groupImage: dataGroup.photoURL ?? "", groupName: dataGroup.name, groupInfo: dataGroup.description ?? "", interests: InterestsParser.getInterests(interestsString: dataGroup.interests ?? []), meetings: [], participants: [], admins: [dataGroup.adminId])
        return group
    }
    
    
    func getData<T: Codable>(data: Data) throws -> T {
        var responceData: Responce<T>
        print(data.prettyJson as Any)
//        do {
//            responceData = try self.decoder.decode(Responce<T>.self, from: data)
//            print(responceData.data)
//        } catch {
//            throw JSONError.decodingError
//        }
        responceData = try! self.decoder.decode(Responce<T>.self, from: data)
        
        let model = responceData as Responce<T>
        if model.message == "success" {
            if let data = model.data {
                return data
            } else {
                throw NetworkerError.badData
            }
        } else {
            throw ServerError.init(message: model.message)
        }
    }
    
    
    func checkResponce(data: Data) throws {
        var responceData: Responce<IDDTO>
        print(data.prettyJson as Any)
        do {
            responceData = try self.decoder.decode(Responce<IDDTO>.self, from: data)
            print(responceData.data as Any)
        } catch {
            throw JSONError.decodingError
        }
        //responceData = try! self.decoder.decode(Responce<IDDTO>.self, from: data)
        
        let model = responceData as Responce<IDDTO>
        if model.message != "success" {
            throw ServerError.init(message: model.message)
        }
    }
    
    
    func emptyResponceTask(request:  URLRequest, completion: @escaping (Error?) -> (Void)) -> URLSessionDataTask {
        let task = session.dataTask(with: request, completionHandler: ({ data, responce, error in
            do {
                try self.errorCheck(data: data, response: responce, error: error)
            } catch let error {
                DispatchQueue.main.async { completion(error) }
            }
            if let data = data {
                do {
                    try self.checkResponce(data: data)
                    DispatchQueue.main.async { completion(nil) }
                } catch let error {
                    DispatchQueue.main.async { completion(error) }
                }
            }
        }))
        return task
    }
    
    
    func accountsResponceTask(request:  URLRequest, completion: @escaping ([Account]?, Error?) -> (Void)) -> URLSessionDataTask {
        let task = session.dataTask(with: request, completionHandler: ({ data, responce, error in
            do {
                try self.errorCheck(data: data, response: responce, error: error)
            } catch let error {
                DispatchQueue.main.async { completion(nil, error) }
            }
            if let data = data {
                do {
                    let accountsData : [AccountDTO] = try self.getData(data: data)
                    var accounts = [Account]()
                    for dto in accountsData {
                        accounts.append(self.createAccountFromDTO(dataAccount: dto))
                    }
                    DispatchQueue.main.async { completion(accounts, nil) }
                } catch let error {
                    DispatchQueue.main.async { completion(nil, error) }
                }
            }
        }))
        return task
    }
    
    
    func getShortInvitationInfo(str: String) -> InvitationShortInfo {
        let info = str.split(separator: ":")
        return InvitationShortInfo(name: String(info[0]), id: Int64(info[1])!)
    }
    
    
    func errorCheck(data: Data?, response: URLResponse?, error: Error?) throws {
        if let error = error {
            throw error
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkerError.badResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkerError.badStatusCode(httpResponse.statusCode)
        }
        
        guard data != nil else {
            throw NetworkerError.badData
        }
    }
    
}
