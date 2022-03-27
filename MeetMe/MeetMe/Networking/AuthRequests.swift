//
//  AuthRequests.swift
//  MeetMe
//
//  Created by Stepan Ostapenko on 24.03.2022.
//

import Foundation

class AuthRequests: MeetMeRequests {
    static let shared = AuthRequests()
    let userURL = "http://localhost:8080/api/v1/user/"
    
    func login(info: LoginInfo, completion: @escaping (Account?, Error?) -> (Void)) {
        if !NetworkMonitor.shared.isConnected {
            DispatchQueue.main.async { completion(nil, NetworkerError.noConnection)}
        }
        
        do {
            let loginData = try encoder.encode(info)
            var request = URLRequest(url: URL(string: userURL + "login")!)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "POST"
            request.httpBody = loginData
            
            let task = session.dataTask(with: request, completionHandler: ({ data, responce, error in
                do {
                    try self.errorCheck(data: data, response: responce, error: error)
                } catch let error {
                    DispatchQueue.main.async { completion(nil, error) }
                }
                
                if let data = data {
                    do {
                        let dataAccount : AccountDTO = try self.getData(data: data)
                        let account = Account(id: dataAccount.id, name: dataAccount.fullName, info: dataAccount.description ?? "", imageDataURL: dataAccount.photoUrl ?? "", interests: dataAccount.interests ?? [], socialMediaLinks: dataAccount.links ?? [:])
                        DispatchQueue.main.async { completion(account, nil) }
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
    
    
    func register(info: RegisterInfo, completion: @escaping (Account?, Error?) -> (Void)) {
        if !NetworkMonitor.shared.isConnected {
            DispatchQueue.main.async { completion(nil, NetworkerError.noConnection)}
        }
        
        do {
            let loginData = try encoder.encode(info)
            var request = URLRequest(url: URL(string: userURL + "register")!)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "POST"
            request.httpBody = loginData
            
            let task = session.dataTask(with: request, completionHandler: ({ data, responce, error in
                do {
                    try self.errorCheck(data: data, response: responce, error: error)
                } catch let error {
                    DispatchQueue.main.async { completion(nil, error) }
                }
                
                if let data = data {
                    do {
                        let id : IDDTO = try self.getData(data: data)
                        let account = Account(id: id.id, name: info.fullName, info: "", imageDataURL: "", interests: [], socialMediaLinks: [:])
                        DispatchQueue.main.async { completion(account, nil) }
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
    
    
}
