//
//  AuthRequests.swift
//  MeetMe
//
//  Created by Stepan Ostapenko on 24.03.2022.
//

import Foundation
import UIKit

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
            request.setValue("Bearer \(MeetMeRequests.JWTToken)", forHTTPHeaderField: "Authorization")
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
                        let account = self.createAccountFromDTO(dataAccount: dataAccount)
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
    
    
    func getJWTToken (info: JWTBullshit, completion: @escaping (String?, Error?) -> (Void)){
        if !NetworkMonitor.shared.isConnected {
            DispatchQueue.main.async { completion(nil, NetworkerError.noConnection)}
        }
        
        let infoData = try! encoder.encode(info)
        var request = URLRequest(url: URL(string: "http://localhost:8080/login")!)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = infoData
        
        let task = session.dataTask(with: request, completionHandler: ({ data, response, error in
            do {
                try self.errorCheck(data: data, response: response, error: error)
            } catch let error {
                DispatchQueue.main.async { completion(nil, error) }
            }
            if let response = response {
                if let httpResponse = response as? HTTPURLResponse {
                    if let token = httpResponse.allHeaderFields["Authorization"] as? String {
                        let parsed = token.split(separator: " ")
                        DispatchQueue.main.async {
                            completion(String(parsed[1]), nil)
                        }
                    }
                }
            }
        }))
        task.resume()
    }
    
    
    func editAccount(image: UIImage?, account: EditAccountDTO, completion: @escaping (Account?, Error?) -> (Void)) {
        if !NetworkMonitor.shared.isConnected {
            DispatchQueue.main.async { completion(nil, NetworkerError.noConnection)}
        }
        
        let editedData = try! encoder.encode(account)
        var request = URLRequest(url: URL(string: userURL + User.currentUser.account!.id.description + "/edit")!)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = editedData
        request.setValue("Bearer \(MeetMeRequests.JWTToken)", forHTTPHeaderField: "Authorization")
        
        let task = session.dataTask(with: request, completionHandler: ({ data, responce, error in
            do {
                try self.errorCheck(data: data, response: responce, error: error)
            } catch let error {
                DispatchQueue.main.async { completion(nil, error) }
            }
            
            if let data = data {
                do {
                    if let image = image {
                        self.uploadImage(image: image, completion: completion)
                    } else {
                        let dataAccount : AccountDTO = try self.getData(data: data)
                        let account = self.createAccountFromDTO(dataAccount: dataAccount)
                        DispatchQueue.main.async { completion(account, nil) }
                    }
                    
                } catch let error {
                    DispatchQueue.main.async { completion(nil, error) }
                }
            }
        }))
        task.resume()
    }
    
    
    func uploadImage(image: UIImage, completion: @escaping (Account?, Error?) -> (Void)) {
        if !NetworkMonitor.shared.isConnected {
            DispatchQueue.main.async { completion(nil, NetworkerError.noConnection)}
        }
        
        
        var request = URLRequest(url: URL(string: userURL + User.currentUser.account!.id.description + "/image")!)
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
                    let dataAccount : AccountDTO = try self.getData(data: data)
                    let account = self.createAccountFromDTO(dataAccount: dataAccount)
                    DispatchQueue.main.async { completion(account, nil) }
                } catch let error {
                    DispatchQueue.main.async { completion(nil, error) }
                }
            }
        }))
        task.resume()
    }
    
}
