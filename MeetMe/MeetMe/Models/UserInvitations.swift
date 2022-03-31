//
//  UserInnvitations.swift
//  MeetMe
//
//  Created by Stepan Ostapenko on 30.03.2022.
//

import Foundation

class UserInvitations {
    
    var personalInvitations = [Meeting]()
    var groupInvitations = [(group: InvitationShortInfo, meetings: [Meeting])]()
    
    
    func count() -> Int {
        return groupInvitations.count + 1
    }
    
    func meetings () -> [[Meeting]] {
        var arr = [[Meeting]]()
        arr.append(personalInvitations)
        for val in groupInvitations {
            arr.append(val.meetings)
        }
        return arr
    }
}
