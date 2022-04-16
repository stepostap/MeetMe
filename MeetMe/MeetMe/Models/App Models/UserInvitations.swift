//
//  UserInnvitations.swift
//  MeetMe
//
//  Created by Stepan Ostapenko on 30.03.2022.
//

import Foundation

/// Информация о различных приглашениях пользователя или групп в которых пользователь значит администратором
class UserInvitations {
    /// Приглашения пользователя
    var personalInvitations = [Meeting]()
    /// Приглашения групп
    var groupInvitations = [(group: InvitationShortInfo, meetings: [Meeting])]()
    /// Число различных типов приглашений (приглашений групп + пользователя)
    func count() -> Int {
        return groupInvitations.count + 1
    }
    /// Получение двумерного массива всех приглашений на мероприятия 
    func meetings () -> [[Meeting]] {
        var arr = [[Meeting]]()
        arr.append(personalInvitations)
        for val in groupInvitations {
            arr.append(val.meetings)
        }
        return arr
    }
}
