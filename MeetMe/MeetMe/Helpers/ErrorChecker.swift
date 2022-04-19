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
                message = "Не указано имя."
            case RegisterErrors.accountNotActive:
                message = "Аккаунт не был активирован, пожалуйста, повторите процесс регистрации."
            case RegisterErrors.wrongEmailCode:
                message = "Неверный код подтверждения электронной почты."
            case RegisterErrors.emptyEmail:
                message = "Не указана электронная почта."
            case RegisterErrors.emptyPassword:
                message = "Не указан пароль"
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
                message = "Не указана дата начала мероприятия."
            case CreateMeetingError.unableToEdit:
                message = "Не удалось сохранить внесенные изменения."
            case CreateMeetingError.startDateError:
                message = "Мероприятие не может начинаться в прошлом."
            case CreateMeetingError.unableToCreateMeeting:
                message = "Не удалось создать мероприятие."
            default:
                break
            }
            return message
        }
        
        if error is MeetingError {
            switch error {
            case MeetingError.userAlreadyParticipant:
                message = "Вы уже участвуете в данном мероприятии."
            case MeetingError.meetingDeleted:
                message = "Данное мероприятие было удалено."
            case MeetingError.maxMeetingParticipants:
                message = "В данном мероприятии нет свободных мест для участия."
            default:
                break
            }
        }
        
        if error is CreateGroupError {
            switch error {
            case CreateGroupError.noName:
                message = "Укажите название группы."
            case CreateGroupError.userAlreadyParticipant:
                message = "Вы уже подписаны на данную группу."
            case CreateGroupError.unableToEditGroup:
                message = "Не удалось отредактировать группу."
            case CreateGroupError.unableToCreateGroup:
                message = "Не удалось создать группу."
            default:
                break
            }
            return message
        }
        
        if error is JSONError {
            switch error {
            case JSONError.decodingError:
                message = "Ошибка в декодировании данных, полученных с сервера."
            case JSONError.encodingError:
                message = "Ошибка в кодировании введенных данных."
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
            return message
        }
        
        if error is FriendError {
            switch error {
            case FriendError.alreadyFriend:
                message = "Данный пользователь уже находится в списке ваших друзей."
            case FriendError.unableToSendRequest:
                message = "Не удалось отправить запрос в друзья."
            default:
                break
            }
        }
        
        if error is ImageStoreError {
            switch error {
            case ImageStoreError.unableToUploadImage:
                message = "Не удалось загрузить изображение."
            case ImageStoreError.unableToLoadImage:
                message = "Не удалось получить изображения."
            default:
                break
            }
        }
        
        if error is ChatError {
            switch error {
            case ChatError.unableToSendMessage:
                message = "Не удалось отправить сообщение."
            case ChatError.unableToLoadMessages:
                message = "Не удалось загрузить сообщения."
            default:
                break
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


