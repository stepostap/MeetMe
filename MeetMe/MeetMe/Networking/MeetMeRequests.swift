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
    
    func getData<T: Codable>(data: Data) throws -> T {
        var responceData: Responce<T>
        
//        do {
//            responceData = try self.decoder.decode(Responce<T>.self, from: data)
//            print(responceData.data)
//        } catch {
//            throw JSONError.decodingError
//        }
        responceData = try! self.decoder.decode(Responce<T>.self, from: data)
        
        let model = responceData as Responce<T>
        if model.message == "success" {
            return model.data
        } else {
            throw ServerError.init(message: model.message)
        }
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
