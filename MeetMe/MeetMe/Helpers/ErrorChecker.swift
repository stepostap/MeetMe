//
//  ErrorDisplayer.swift
//  MeetMe
//
//  Created by Stepan Ostapenko on 10.03.2022.
//

import Foundation
import UIKit

class ErrorChecker {
    static var handler = ErrorChecker()
    
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
                message = "Не введено название мероприятия"
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
        
        print(error)
        return "Unknown error"
    }
    
    func getAlertController (error: Error) -> UIAlertController {
        
        let alert = UIAlertController(title: "Warning", message: getMessage(error: error), preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        return alert
        
    }
    
    static func isPasswordValid(_ password : String) -> Bool {
        
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-z])(?=.*[$@$#!%*?&])[A-Za-z\\d$@$#!%*?&]{8,}")
        return passwordTest.evaluate(with: password)
    }
    
    static func isEmailValid (_ email: String) -> Bool {
        let regex = try! NSRegularExpression(pattern: "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$", options: .caseInsensitive)
        return regex.firstMatch(in: email, options: [], range: NSRange(location: 0, length: email.count)) != nil
    }
    
}


