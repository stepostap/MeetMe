//
//  MeetingRequests.swift
//  MeetMe
//
//  Created by Stepan Ostapenko on 20.03.2022.
//

import Foundation

class MeetingRequests {
    
    static let shared = MeetingRequests()
    
    func createMeeting(meeting: Meeting, completion: @escaping (Meeting?, Error?) -> (Void)) {
        
    }
    
    func editMeeting(meeting: Meeting, completion: @escaping (Error?) -> (Void)) {
        
    }
    
    func deleteMeeting(meetingID: Int64) {
        
    }
    
    func participateInMeeting(meetingID: Int64) {
        
    }
    
    func removeMeeting(meetingID: Int64) {
        
    }
    
    func getUserMeetings() {
        
    }
    
    func getMeetingInfo(meetingID: Int64) {
        
    }
    
    func getFilteredMeetings(filter: MeetingSearchFilter) {
        
    }
    
    func getParticipants(meetingID: Int64) {
        
    }
}
