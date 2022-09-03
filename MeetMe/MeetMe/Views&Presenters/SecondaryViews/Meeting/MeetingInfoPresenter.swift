//
//  MeetingInfoVC.swift
//  MeetMe
//
//  Created by Stepan Ostapenko on 14.03.2022.
//

import UIKit

/// Класс, отвечающий за отображение информации о мероприятии
class MeetingInfoVC: UIViewController {
    /// Мероприятие
    var meeting: Meeting?
    /// Форматтер даты
    private let formatter = DateFormatter()
    /// Прокручиваемая область,  содежащая UI элементы
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "BackgroundMain")
        let viewParticipantsButton = UIBarButtonItem(title: "Участники", style: .done, target: self, action: #selector(viewParticipants))
        navigationItem.rightBarButtonItem = viewParticipantsButton
        if let meeting = meeting {
            let meetingInfoView = MeetingInfoView(meeting: meeting)
            meetingInfoView.participateButton.addTarget(self, action: #selector(participate), for: .touchUpInside)
            view = meetingInfoView
        }
    }
    
    /// Переход на контроллер, отображающий участников мероприятия
    @objc private func viewParticipants() {
        let vc = ViewParticipantsVC()
        vc.meeting = meeting
        navigationController?.pushViewController(vc, animated: true)
    }
    
    /// Участие пользователя в мероприятии
    @objc private func participate() {
        MeetingRequests.shared.participateInMeeting(meetingID: meeting!.id, completion: {(error) in
            if let error = error {
                let alert = ErrorChecker.handler.getAlertController(error: error)
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            self.meeting!.isUserParticipant = true
            self.meeting!.currentParticipantNumber += 1
            if User.currentUser.meetingInvitations?.personalInvitations.contains(self.meeting!) ??  false {
                let index = User.currentUser.meetingInvitations!.personalInvitations.firstIndex(of: self.meeting!)
                User.currentUser.meetingInvitations!.personalInvitations.remove(at: index!)
                User.currentUser.plannedMeetings?.append(self.meeting!)
            } else {
                User.currentUser.plannedMeetings?.append(self.meeting!)
            }
            self.navigationController?.popViewController(animated: true)
        })
    }
}
