//
//  AuthRequests.swift
//  MeetMe
//
//  Created by Stepan Ostapenko on 24.03.2022.
//

import Foundation
import UIKit

/// Создание, отправка и обработка запросов, связанных с авторизацией пользователя в приложении
class AuthRequests: MeetMeRequests {
    /// Статический экзмепляр класса
    static let shared = AuthRequests()
    /// Базовая часть URL дла запросов
    let userURL = "http://localhost:8080/api/v1/user/"
    
    /// Создание и отправка запроса на вход в приложение и обработка полученного ответа
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
    
    /// Создание и отправка запроса на регистрацию в приложении и обработка полученного ответа
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
    
    /// Создание и отправка запроса на получение JWT токена и обработка полученного ответа 
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
    
    /// Создание и отправка запроса на повторную отправку кода для подтверждения почты
    func requestAnotherVerificationCode(completion: @escaping (Error?) -> (Void)) {
        if !NetworkMonitor.shared.isConnected {
            DispatchQueue.main.async { completion(NetworkerError.noConnection)}
        }
        
        var request = URLRequest(url: URL(string: userURL + User.currentUser.account!.id.description + "/send_new_code")!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(MeetMeRequests.JWTToken)", forHTTPHeaderField: "Authorization")
        
        let task = emptyResponceTask(request: request, completion: completion)
        task.resume()
    }
    
    /// Создание и отправка запроса на проверку введенного пользователем кода для подтверждения адреса электронной почты
    func sendVerificationCode(code: String, completion: @escaping (Error?) -> (Void)) {
        if !NetworkMonitor.shared.isConnected {
            DispatchQueue.main.async { completion(NetworkerError.noConnection)}
        }
        
        var request = URLRequest(url: URL(string: userURL + User.currentUser.account!.id.description + "/verify/\(code)")!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(MeetMeRequests.JWTToken)", forHTTPHeaderField: "Authorization")
        
        let task = emptyResponceTask(request: request, completion: completion)
        task.resume()
    }
}
