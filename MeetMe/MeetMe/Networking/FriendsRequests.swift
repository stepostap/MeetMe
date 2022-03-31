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
        
        let task = emptyResponceTask(request: request, completion: completion)
        task.resume()
    }
    
    
    func deleteFriend(recieverId: Int64, completion: @escaping (Error?) -> (Void)) {
        if !NetworkMonitor.shared.isConnected {
            DispatchQueue.main.async { completion(NetworkerError.noConnection)}
        }
        
        var request = URLRequest(url: URL(string: userURL + User.currentUser.account!.id.description + "/friends/" + recieverId.description)!)
        request.httpMethod = "DELETE"
        
        let task = emptyResponceTask(request: request, completion: completion)
        task.resume()
    }
    
    
    func getFriends(completion: @escaping ([Account]?, Error?) -> (Void)) {
        if !NetworkMonitor.shared.isConnected {
            DispatchQueue.main.async { completion(nil, NetworkerError.noConnection)}
        }
        
        var request = URLRequest(url: URL(string: userURL + User.currentUser.account!.id.description + "/friends")!)
        request.httpMethod = "GET"
        
        let task = accountsResponceTask(request: request, completion: completion)
        task.resume()
    }
    
    
    func getFriendRequests(completion: @escaping ([Account]?, Error?) -> (Void)) {
        if !NetworkMonitor.shared.isConnected {
            DispatchQueue.main.async { completion(nil, NetworkerError.noConnection)}
        }
        
        var request = URLRequest(url: URL(string: userURL + User.currentUser.account!.id.description + "/friends/to")!)
        request.httpMethod = "GET"
        
        let task = accountsResponceTask(request: request, completion: completion)
        task.resume()
    }
    
    
}
