//
//  MeetMeRequests.swift
//  MeetMe
//
//  Created by Stepan Ostapenko on 24.03.2022.
//

import Foundation

/// Класс,  от которого наследуются все классы для создания и отправки запросов. Содержит в себе функции для создания
/// dataTask, десериализации данных с сервера и проверку ответа сервера на ошибки
class MeetMeRequests {
    /// Сессия,  с помощью которой отправляются URL запросы
    let session = URLSession(configuration: .default)
    /// Кодировщик данных
    let encoder = JSONEncoder()
    /// Декодироващик данных
    let decoder = JSONDecoder()
    /// Форматтер даты
    let formatter = DateFormatter()
    /// JWT токен
    static var JWTToken = ""
    
    /// Создание эземпляра класса Meeting из экземпляра класса MeetingDTO (перевод из серверной модели данныхданных
    /// в модель, используемую в приложени)
    func createMeetingFromDTO(dataMeeting: MeetingDTO) -> Meeting {
        formatter.dateFormat = "MM-dd-yyyy HH:mm"
        let recievedMeeting = Meeting(id: dataMeeting.id, creatorID: dataMeeting.adminId, chatID: dataMeeting.chatId, name: dataMeeting.name, types: InterestsParser.getInterests(interestsString: dataMeeting.interests ?? []), info: dataMeeting.description ?? "", online: dataMeeting.isOnline, isPrivate: dataMeeting.isPrivate, isParticipant: dataMeeting.isParticipant ?? false, groups: [], participantsMax: dataMeeting.maxNumberOfParticipants, Location: dataMeeting.location ?? "", startingDate: self.formatter.date(from: dataMeeting.startDate)!, endingDate: nil, currentParticipantNumber: dataMeeting.numberOfParticipants, imageURL: dataMeeting.imageUrl ?? "")
        if let endingDate = dataMeeting.endDate {
            recievedMeeting.endingDate = formatter.date(from: endingDate)
        }
        return recievedMeeting
    }
    
    /// Создание эземпляра класса Account из экземпляра класса AccountDTO (перевод из серверной модели данных
    /// в модель, используемую в приложени)
    func createAccountFromDTO(dataAccount: AccountDTO) -> Account {
        let account = Account(id: dataAccount.id, name: dataAccount.fullName, info: dataAccount.description ?? "", imageDataURL: dataAccount.photoUrl ?? "", interests: InterestsParser.getInterests(interestsString: dataAccount.interests ?? []), socialMediaLinks: dataAccount.links ?? [:])
        return account
    }
    
    /// Создание эземпляра класса Group из экземпляра класса GroupDTO (перевод из серверной модели данных
    /// в модель, используемую в приложени)
    func createGroupFromDTO(dataGroup: GroupDTO) -> Group {
        let group = Group(id: dataGroup.id, groupImage: dataGroup.photoUrl ?? "", groupName: dataGroup.name, groupInfo: dataGroup.description ?? "", interests: InterestsParser.getInterests(interestsString: dataGroup.interests ?? []), meetings: [], participants: [], admins: [dataGroup.adminId])
        return group
    }
    
    /// Десериализация ответа сервера в T
    func getData<T: Codable>(data: Data) throws -> T {
        var responceData: Responce<T>
        print("Recieved: \(data.prettyJson as Any)")
        do {
            responceData = try self.decoder.decode(Responce<T>.self, from: data)
            //print(responceData.data)
        } catch {
            throw JSONError.decodingError
        }
        
        let model = responceData as Responce<T>
        if model.message == "success" {
            if let data = model.data {
                return data
            } else {
                throw NetworkerError.badData
            }
        } else {
            throw ServerError.init(message: model.message)
        }
    }
    
    /// Проверка полученных  от сервера данных на наличие ошибок
    func checkResponce(data: Data) throws {
        var responceData: Responce<IDDTO>
        do {
            responceData = try self.decoder.decode(Responce<IDDTO>.self, from: data)
            print(responceData.data as Any)
        } catch {
            throw JSONError.decodingError
        }
        let model = responceData as Responce<IDDTO>
        if model.message != "success" {
            throw ServerError.init(message: model.message)
        }
    }
    
    /// Создание dataTask,  которое не возвращает никаких результатов, только ошибку при ее наличии
    func emptyResponceTask(request:  URLRequest, completion: @escaping (Error?) -> (Void)) -> URLSessionDataTask {
        let task = session.dataTask(with: request, completionHandler: ({ data, responce, error in
            do {
                try self.errorCheck(data: data, response: responce, error: error)
            } catch let error {
                DispatchQueue.main.async { completion(error) }
            }
            if let data = data {
                do {
                    try self.checkResponce(data: data)
                    DispatchQueue.main.async { completion(nil) }
                } catch let error {
                    DispatchQueue.main.async { completion(error) }
                }
            }
        }))
        return task
    }
    
    /// Создание dataTask,  которое возвращает массив аккаунтов или ошибку при ее наличии
    func accountsResponceTask(request:  URLRequest, completion: @escaping ([Account]?, Error?) -> (Void)) -> URLSessionDataTask {
        let task = session.dataTask(with: request, completionHandler: ({ data, responce, error in
            do {
                try self.errorCheck(data: data, response: responce, error: error)
            } catch let error {
                DispatchQueue.main.async { completion(nil, error) }
            }
            if let data = data {
                do {
                    let accountsData : [AccountDTO] = try self.getData(data: data)
                    var accounts = [Account]()
                    for dto in accountsData {
                        accounts.append(self.createAccountFromDTO(dataAccount: dto))
                    }
                    DispatchQueue.main.async { completion(accounts, nil) }
                } catch let error {
                    DispatchQueue.main.async { completion(nil, error) }
                }
            }
        }))
        return task
    }
    
    /// Парсинг строки на информацию о приглашении
    func getShortInvitationInfo(str: String) -> InvitationShortInfo {
        let info = str.split(separator: ":")
        return InvitationShortInfo(name: String(info[0]), id: Int64(info[1])!)
    }
    
    /// Проверка ответа сервера на наличие ошибок
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
    
    /// Сериализация картинки для отправки ее на сервер 
    func createBody(boundary: String, data: Data, mimeType: String, fileName: String) -> Data? {
        let body = NSMutableData()
        
        let boundaryPrefix = "--\(boundary)\r\n"
        
        body.appendString(boundaryPrefix)
        body.appendString("Content-Disposition: form-data; name=\"image\"; filename=\"\(fileName)\"\r\n")
        body.appendString("Content-Type: \(mimeType)\r\n\r\n")
        body.append(data)
        body.appendString("\r\n")
        body.appendString("--".appending(boundary.appending("--")))
        
        return body as Data
    }
}

// MARK: - Helper
extension NSMutableData {
    func appendString(_ string: String) {
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: false)
        append(data!)
    }
}
