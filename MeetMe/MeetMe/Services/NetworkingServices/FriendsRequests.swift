//
//  FriendsRequests.swift
//  MeetMe
//
//  Created by Stepan Ostapenko on 20.03.2022.
//

import Foundation

/// Создание, отправка и обработка запросов для взаимодействия с друзьями пользователя
class FriendsReequests: MeetMeRequests{
    /// Базовая часть URL дла запросов
    let userURL = "http://localhost:8080/api/v1/user/"
    /// Статический экзмепляр класса
    static let shared = FriendsReequests()
    
    /// Создание и отправка аккаунту с recieverId запроса на добавление в друзья и обработка полученного ответа
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
    
    /// Создание и отправка запроса на удаление аккаунта с reciverId из списка друзей пользователя и обработка полученного ответа
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
    
    /// Создание и отправка запроса на получение списка друзей пользователя и обработка полученного ответа
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
    
    /// Создание и отправка запроса на получение списка заявок в друзья пользователя и обработка полученного ответа
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
    
    /// Создание и отправка запроса на поиск аккаунтов приложения по имени и обработка полученного ответа 
    func searchFriends(query:  String, completion: @escaping ([[Account]]?, Error?) -> (Void)) {
        if !NetworkMonitor.shared.isConnected {
            DispatchQueue.main.async { completion(nil, NetworkerError.noConnection)}
        }
        
        let queryItems = [URLQueryItem(name: "query", value: query)]
        var urlComps = URLComponents(string: userURL + User.currentUser.account!.id.description + "/friends/search")!
        urlComps.queryItems = queryItems
        // URL(string: userURL + User.currentUser.account!.id.description + "/friends/search?query=\(query)")
        if let url = urlComps.url {
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("Bearer \(MeetMeRequests.JWTToken)", forHTTPHeaderField: "Authorization")
            
            print(url)
            
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
                            accounts.append(dto.createAccountFromDTO())
                        }
                        results.append(accounts)
                        print(accounts.count)
                        accounts.removeAll()
                        for dto in accountsData["global"]! {
                            accounts.append(dto.createAccountFromDTO())
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
}
