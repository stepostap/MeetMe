//
//  ImageStoreRequest.swift
//  MeetMe
//
//  Created by Stepan Ostapenko on 07.04.2022.
//

import Foundation
import UIKit

/// Создание, отправка и обработка запросов,  связанных с хранилищем фотографий для истории мероприятий 
class ImageStoreRequests: MeetMeRequests {
    /// Статический экзмепляр класса
    static let shared = ImageStoreRequests()
    /// Базовая часть URL дла запросов
    let storeURL = "http://localhost:8080/api/v1/imageStore/"
    
    /// Создание и отправка запроса на загрузку нового изображения в хранилище + обработка ответа
    func uploadImage(meetingID: Int64, image: UIImage, completion: @escaping ([String]?, Error?) -> (Void)) {
        if !NetworkMonitor.shared.isConnected {
            DispatchQueue.main.async { completion(nil, NetworkerError.noConnection)}
        }
        
        var request = URLRequest(url: URL(string: storeURL + meetingID.description)!)
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
                    let dataMeeting : [String] = try self.getData(data: data)
                    
                    DispatchQueue.main.async { completion(dataMeeting, nil) }
                } catch let error {
                    DispatchQueue.main.async { completion(nil, error) }
                }
            }
        }))
        task.resume()
    }
    
    /// Создание и отправка запроса на получение списка ссылок на изображения хранилища + обработка ответа 
    func getImageLinks(meetingID: Int64, completion: @escaping ([String]?, Error?) ->  (Void)) {
        if !NetworkMonitor.shared.isConnected {
            DispatchQueue.main.async { completion(nil, NetworkerError.noConnection)}
        }
        
        var request = URLRequest(url: URL(string: storeURL + meetingID.description)!)
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
                    let dataMeeting : [String] = try self.getData(data: data)
                    
                    DispatchQueue.main.async { completion(dataMeeting, nil) }
                } catch let error {
                    DispatchQueue.main.async { completion(nil, error) }
                }
            }
        }))
        task.resume()
    }
}
