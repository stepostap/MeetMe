//
//  AccountRequests.swift
//  MeetMe
//
//  Created by Stepan Ostapenko on 20.03.2022.
//

import Foundation
import UIKit

/// Создание, отправка и обработка запросов для взаимодействия с аккаунтом пользователя
class AccountRequests: MeetMeRequests {
    /// Базовая часть URL дла запросов
    let userURL = "http://localhost:8080/api/v1/user/"
    /// Статический экзмепляр класса
    static let shared = AccountRequests()
    
    /// Создание и отправка запроса на получение информации об аккаунте пользователя и обработка полученного ответа
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
    
    /// Загрузка картинки (аватара) аккаунта на сервер и обработка полученного ответа 
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
