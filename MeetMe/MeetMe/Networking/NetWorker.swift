//
//  NetWorker.swift
//  MeetMe
//
//  Created by Stepan Ostapenko on 10.03.2022.
//

import Foundation

class Networker {
    
    static let shared = Networker()
    
    func loginUser (email: String, password: String, completion: @escaping (User?, Error?) -> (Void)) {
        if !NetworkMonitor.shared.isConnected {
            DispatchQueue.main.async {
                completion(nil, NetworkerError.noConnection)
            }
        }
        
        let userInfo = loginInfo(email: email, password: password)
        let loginData = try! JSONEncoder().encode(userInfo)
        
        if let userData = Server.shared.getUser(data: loginData){
            let user = User()
            do {
                user.account = try JSONDecoder().decode(Account.self, from: userData)
                DispatchQueue.main.async {
                    completion(user, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(nil, JSONError.decodingError)
                }
            }
        } else {
            DispatchQueue.main.async {
                completion(nil, LoginErrors.noSuchUser)
            }
        }
    }
    
    func registerUser (name: String, email: String, password: String, completion: @escaping (User?, Error?) -> (Void)) {
        if !NetworkMonitor.shared.isConnected {
            DispatchQueue.main.async {
                completion(nil, NetworkerError.noConnection)
            }
        }
        
        let userLoginData = [email, password, name]
        let userLoginDataJSON = try! JSONEncoder().encode(userLoginData)
        
        if let newAccount = Server.shared.registerUser(data: userLoginDataJSON) {
            do {
                let errorNumber = try JSONDecoder().decode(Int.self, from: newAccount)
                switch errorNumber {
                case 1:
                    DispatchQueue.main.async {
                        completion(nil, RegisterErrors.emailRegistered)
                    }
                default:
                    break
                }
                
            } catch {
                
            }
            
            let user = User()
            do {
                user.account = try JSONDecoder().decode(Account.self, from: newAccount)
                DispatchQueue.main.async {
                    completion(user, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(nil, JSONError.decodingError)
                }
            }
        } else {
            DispatchQueue.main.async {
                completion(nil, LoginErrors.noSuchUser)
            }
        }
    }
    
    func updateUserInfo(account: Account, completion:  @escaping (Error?) -> (Void)) {
        if !NetworkMonitor.shared.isConnected {
            DispatchQueue.main.async {
                completion(NetworkerError.noConnection)
            }
        }
        
        let updatedAccccountData = try! JSONEncoder().encode(account)
        if let serverResponceData = Server.shared.updateUser(data: updatedAccccountData) {
            do {
                let serverResponce = try JSONDecoder().decode(Int.self, from: serverResponceData)
                let responceType = ServerResponce.init(rawValue: serverResponce)
                
                switch responceType! {
                case ServerResponce.noSuchUser:
                    DispatchQueue.main.async {
                        completion(NetworkerError.noConnection)
                    }
                case ServerResponce.success:
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    completion(JSONError.decodingError)
                }
            }
        }
    }
    
    func addMeeting(meeting: Meeting, completion:  @escaping (Meeting?, Error?) -> (Void)) {
        if !NetworkMonitor.shared.isConnected {
            DispatchQueue.main.async {
                completion(nil, NetworkerError.noConnection)
            }
        }
        
        let meetingData = try! JSONEncoder().encode(meeting)
        let serverResponceData = Server.shared.newMeeting(data: meetingData)
        
        do {
            let serverResponce = try JSONDecoder().decode(Meeting.self, from: serverResponceData)
            DispatchQueue.main.async {
                completion(serverResponce, nil)
            }
        } catch {
            DispatchQueue.main.async {
                completion(nil, JSONError.decodingError)
            }
        }
    }
    
    func getUserMeetings(completion:  @escaping ([Meeting]?, Error?) -> (Void)) {
        if !NetworkMonitor.shared.isConnected {
            DispatchQueue.main.async {
                completion(nil, NetworkerError.noConnection)
            }
        }
        
        let idData = try! JSONEncoder().encode(User.currentUser.account?.id)
        if let meetingsData = Server.shared.getUserMeetings(data: idData) {
            do {
                let meetings = try JSONDecoder().decode([Meeting].self, from: meetingsData)
                DispatchQueue.main.async {
                    completion(meetings, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(nil, JSONError.decodingError)
                }
            }
        }
        
    }
    
    func participateInMeeting(meetingId: Int64, completion: @escaping ((Error?) -> (Void))) {
        
        if !NetworkMonitor.shared.isConnected {
            DispatchQueue.main.async {
                completion(NetworkerError.noConnection)
            }
        }
        let info = [User.currentUser.account!.id, meetingId]
        let data = try!  JSONEncoder().encode(info)
        
        Server.shared.participateInMeeting(data: data)
        
        DispatchQueue.main.async {
            completion(nil)
        }
        
    }
}
