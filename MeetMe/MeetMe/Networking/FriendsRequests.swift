//
//  FriendsRequests.swift
//  MeetMe
//
//  Created by Stepan Ostapenko on 20.03.2022.
//

import Foundation

class FriendsReequests: MeetMeRequests{
    let userURL = "http://localhost:8080/api/v1/user/"
    static let shared = FriendsReequests()
    
    
    func makeFriendRequest(recieverId: Int64, completion: @escaping (Error?) -> (Void)) {
        if !NetworkMonitor.shared.isConnected {
            DispatchQueue.main.async { completion(NetworkerError.noConnection)}
        }
        
        var request = URLRequest(url: URL(string: userURL + User.currentUser.account!.id.description + "/friends/" + recieverId.description)!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(MeetMeRequests.JWTToken)", forHTTPHeaderField: "Authorization")
        
        let task = emptyResponceTask(request: request, completion: completion)
        task.resume()
    }
    
    
    func deleteFriend(recieverId: Int64, completion: @escaping (Error?) -> (Void)) {
        if !NetworkMonitor.shared.isConnected {
            DispatchQueue.main.async { completion(NetworkerError.noConnection)}
        }
        
        var request = URLRequest(url: URL(string: userURL + User.currentUser.account!.id.description + "/friends/" + recieverId.description)!)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(MeetMeRequests.JWTToken)", forHTTPHeaderField: "Authorization")
        
        let task = emptyResponceTask(request: request, completion: completion)
        task.resume()
    }
    
    
    func getFriends(completion: @escaping ([Account]?, Error?) -> (Void)) {
        if !NetworkMonitor.shared.isConnected {
            DispatchQueue.main.async { completion(nil, NetworkerError.noConnection)}
        }
        
        var request = URLRequest(url: URL(string: userURL + User.currentUser.account!.id.description + "/friends")!)
        request.httpMethod = "GET"
        request.setValue("Bearer \(MeetMeRequests.JWTToken)", forHTTPHeaderField: "Authorization")
        
        let task = accountsResponceTask(request: request, completion: completion)
        task.resume()
    }
    
    
    func getFriendRequests(completion: @escaping ([Account]?, Error?) -> (Void)) {
        if !NetworkMonitor.shared.isConnected {
            DispatchQueue.main.async { completion(nil, NetworkerError.noConnection)}
        }
        
        var request = URLRequest(url: URL(string: userURL + User.currentUser.account!.id.description + "/friends/to?query=")!)
        request.httpMethod = "GET"
        request.setValue("Bearer \(MeetMeRequests.JWTToken)", forHTTPHeaderField: "Authorization")
        
        let task = accountsResponceTask(request: request, completion: completion)
        task.resume()
    }
    
    
    func searchFriends(query:  String, completion: @escaping ([[Account]]?, Error?) -> (Void)) {
        if !NetworkMonitor.shared.isConnected {
            DispatchQueue.main.async { completion(nil, NetworkerError.noConnection)}
        }
        
        var request = URLRequest(url: URL(string: userURL + User.currentUser.account!.id.description + "/friends/search?query=\(query)")!)
        request.httpMethod = "GET"
        request.setValue("Bearer \(MeetMeRequests.JWTToken)", forHTTPHeaderField: "Authorization")
        
        print(userURL + User.currentUser.account!.id.description + "/friends/search?query=\(query)")
        
        let task = session.dataTask(with: request, completionHandler: ({ data, responce, error in
            do {
                try self.errorCheck(data: data, response: responce, error: error)
            } catch let error {
                DispatchQueue.main.async { completion(nil, error) }
            }
            if let data = data {
                do {
                    let accountsData : [String:[AccountDTO]] = try self.getData(data: data)
                    var accounts = [Account]()
                    var results = [[Account]]()
                    
                    for dto in accountsData["friends"]! {
                        accounts.append(self.createAccountFromDTO(dataAccount: dto))
                    }
                    results.append(accounts)
                    print(accounts.count)
                    accounts.removeAll()
                    for dto in accountsData["global"]! {
                        accounts.append(self.createAccountFromDTO(dataAccount: dto))
                    }
                    results.append(accounts)
                    print(accounts.count)
                    DispatchQueue.main.async { completion(results, nil) }
                } catch let error {
                    DispatchQueue.main.async { completion(nil, error) }
                }
            }
        }))
        task.resume()
    }
}
