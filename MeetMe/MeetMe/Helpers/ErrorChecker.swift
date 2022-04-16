//
//  ErrorDisplayer.swift
//  MeetMe
//
//  Created by Stepan Ostapenko on 10.03.2022.
//

import Foundation
import UIKit

/// Класс, отвечающий за обработку и отображение ошибок
class ErrorChecker {
    static var handler = ErrorChecker()
    
    /// Создание сообщения в зависимости от типа ошибки
    private func getMessage(error: Error) -> String {
        var message = ""
        
        if error is LoginErrors {
            switch error {
            case LoginErrors.invalidPassword:
                message = "Введен неправильный пароль"
            case LoginErrors.invalidEmail:
                message = "Некорректный email адрес."
            case LoginErrors.noSuchUser:
                message = "Неверный email или пароль."
            case LoginErrors.emptyLogin:
                message = "Не введен email адрес."
            case LoginErrors.emptyPassword:
                message = "Не введен пароль."
            
            default:
                break
            }
            
            return message
        }
        
        if error is RegisterErrors {
            switch error {
            case RegisterErrors.weakPassword:
                message = "Слишком слабый пароль."
            case RegisterErrors.passwordsDontMatch:
                message = "Пароли не совпадают."
            case RegisterErrors.emailRegistered:
                message = "Данный электорнный адрес уже зарегестрирован."
            case RegisterErrors.emptyName:
                message = "Введите имя."
            default:
                break
            }
            
            return message
        }
        
        if error is CreateMeetingError {
            switch error {
            case CreateMeetingError.startEndDateError:
                message = "Дата окончания мероприятия идет до даты наступления мероприятия."
            case CreateMeetingError.noName:
                message = "Не введено название мероприятия."
            case CreateMeetingError.noParticipants:
                message = "У приватного мероприятия должны быть указаны участники."
            case CreateMeetingError.noMaxUser:
                message = "Не выбрано максимальное число участников мероприятия."
            case CreateMeetingError.noStartingDate:
                message = "Не указана дата начала мероприятия"
            default:
                break
            }
            
            return message
        }
        
        if error is createGroupError {
            switch error {
            case createGroupError.noName:
                message = "Укажите название группы"
            case createGroupError.noInfo:
                message = "Добавьте описание группы"
            case createGroupError.noInterests:
                message = "Укажите интересы группы"
            case createGroupError.noParticipants:
                message = "При создании приватной группы добавьте в нее участников"
            default:
                break
            }
            return message
        }
        
        if error is JSONError {
            switch error {
            case JSONError.decodingError:
                message = "Ошибка в декодировании данных, полученных с сервера"
            case JSONError.encodingError:
                message = "Ошибка в кодировании введенных данных"
            default: break
            }
            return message
        }
        
        if error is ServerError {
            let serverError = error as! ServerError
            return serverError.message
        }
        
        if error is NetworkerError {
            switch error {
            case NetworkerError.badData:
                message = "Данные с сервера не были получены."
            case NetworkerError.badResponse:
                message = "Неправильный ответ сервераю"
            case NetworkerError.badStatusCode(let code):
                message = "Ошибка сервера \(code)."
            case NetworkerError.noConnection:
                message = "Отсутствует соединение с сетью."
            default: break
            }
        }
        
        print(error)
        return "Unknown error"
    }
    
    /// Создание AlertController с текстом соответствующей ошибки
    func getAlertController (error: Error) -> UIAlertController {
        let alert = UIAlertController(title: "Warning", message: getMessage(error: error), preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        return alert
        
    }
    
    /// Проверка пароля на устойчивость
    static func isPasswordValid(_ password : String) -> Bool {
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-z])(?=.*[$@$#!%*?&])[A-Za-z\\d$@$#!%*?&]{8,}")
        return passwordTest.evaluate(with: password)
    }

    /// Проверка электорнной почты
    static func isEmailValid (_ email: String) -> Bool {
        let regex = try! NSRegularExpression(pattern: "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$", options: .caseInsensitive)
        return regex.firstMatch(in: email, options: [], range: NSRange(location: 0, length: email.count)) != nil
    }
    
}


