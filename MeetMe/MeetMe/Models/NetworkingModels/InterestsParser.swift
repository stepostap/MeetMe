//
//  InterestsParser.swift
//  MeetMe
//
//  Created by Stepan Ostapenko on 27.03.2022.
//

import Foundation

class InterestsParser {
    
    static func getInterestsString(interests: [Interests]) -> [String] {
        var stringInterests = [String]()
        for interest in interests {
            stringInterests.append(interest.rawValue)
        }
        return stringInterests
    }
    
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
