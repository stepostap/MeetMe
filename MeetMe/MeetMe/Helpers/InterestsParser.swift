//
//  InterestsParser.swift
//  MeetMe
//
//  Created by Stepan Ostapenko on 27.03.2022.
//

import Foundation

/// Класс для парсинга интересов
class InterestsParser {
    /// Получение стрового представления интересов
    static func getInterestsString(interests: [Interests]) -> [String] {
        var stringInterests = [String]()
        for interest in interests {
            stringInterests.append(interest.rawValue)
        }
        return stringInterests
    }
    /// Получение списка интересов в виде экземпляров перечисления из строки
    static func getInterests(interestsString: [String]) -> [Interests] {
        var interests = [Interests]()
        for interestStr in interestsString {
            if let interest = Interests(rawValue: interestStr) {
                interests.append(interest)
            }
        }
        return interests
    }
}
