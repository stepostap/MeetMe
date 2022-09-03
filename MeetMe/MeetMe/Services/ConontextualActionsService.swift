//
//  File.swift
//  MeetMe
//
//  Created by Stepan Ostapenko on 01.09.2022.
//

import Foundation
import UIKit

class ContextualActionService {
    /// Создание UIContextualAction, добавляющего аккаунт в друзья
    static func addFriendAction(indexPath: IndexPath, friendsVC: FriendsVC) -> UIContextualAction {
        let action = UIContextualAction(style: .normal, title: "Добавить в друзья") {[weak friendsVC] (_,_,_) in
            guard let friendsVC = friendsVC else {
                return 
            }
            FriendsReequests.shared.makeFriendRequest(recieverId: friendsVC.currentAccounts[indexPath.row].id, completion: {(error) in
                if let error = error {
                    let alert = ErrorChecker.handler.getAlertController(error: error)
                    
                    friendsVC.navigationController?.present(alert, animated: true, completion: nil)
                    return
                }
                
                let index = User.currentUser.friendsRequests?.firstIndex(of: friendsVC.currentAccounts[indexPath.row])
                User.currentUser.friends?.append(User.currentUser.friendsRequests![index!])
                User.currentUser.friendsRequests?.remove(at: index!)
                friendsVC.currentAccounts.remove(at: index!)
                friendsVC.friendsView.friendsTableView.deleteRows(at: [indexPath], with: .automatic)
                friendsVC.friendsView.friendsTableView.reloadData()
            })
        }
        action.backgroundColor = .systemGreen
        return action
    }
    
    
    /// Создание UIContextualAction, удаляющего аккаунт из списка друзей
    static func removeFriendAction(indexPath: IndexPath, friendsVC: FriendsVC) -> UIContextualAction {
        let action = UIContextualAction(style: .destructive, title: "Удалить") {[weak friendsVC] (_,_,_) in
            guard let friendsVC = friendsVC else {
                return
            }
            FriendsReequests.shared.deleteFriend(recieverId: friendsVC.currentAccounts[indexPath.row].id, completion: {(error) in
                if let error = error {
                    let alert = ErrorChecker.handler.getAlertController(error: error)
                    friendsVC.navigationController?.present(alert, animated: true, completion: nil)
                    return
                }
                var index: Int?
                if User.currentUser.friends!.contains(friendsVC.currentAccounts[indexPath.row]) {
                    index = User.currentUser.friends?.firstIndex(of: friendsVC.currentAccounts[indexPath.row])
                    User.currentUser.friends?.remove(at: index!)
                } else {
                    index = User.currentUser.friendsRequests?.firstIndex(of: friendsVC.currentAccounts[indexPath.row])
                    User.currentUser.friendsRequests?.remove(at: index!)
                }
                friendsVC.currentAccounts.remove(at: index!)
                friendsVC.friendsView.friendsTableView.deleteRows(at: [indexPath], with: .automatic)
                friendsVC.friendsView.friendsTableView.reloadData()
            })
        }
        
        return action
    }
    
    /// Создание UIContextualAction, отвечающего за отписку пользователя от посещения данного мероприятия
    static func leaveMeetingAction(meetingType: MeetingType, indexPath: IndexPath, meetingsVC: MeetingsVC) -> UIContextualAction {
        let leaveAction = UIContextualAction(style: .destructive, title: "Покинуть мероприятие") { [weak meetingsVC] (_, _, _) in
            guard let meetingsVC = meetingsVC else {
                return
            }
            let alert = UIAlertController(title: "Покинуть мероприятие?", message: "Вы уверены, что хотите покинуть мероприятие? Это действие нельзя отменить.", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
            let removeAction = UIAlertAction(title: "Покинуть", style: .default, handler: {_ in
                switch meetingType {
                case .visited:
                    MeetingRequests.shared.removeMeeting(meetingID: User.currentUser.meetingHistory![indexPath.row].id, completion: {(error) in
                        if let error = error {
                            let alert = ErrorChecker.handler.getAlertController(error: error)
                            meetingsVC.navigationController?.present(alert, animated: true, completion: nil)
                            return
                        }
                        meetingsVC.currentMeetings!.remove(at: indexPath.row)
                        User.currentUser.meetingHistory?.remove(at: indexPath.row)
                        meetingsVC.meetingTableView.deleteRows(at: [indexPath], with: .automatic)
                        meetingsVC.meetingTableView.reloadData()
                    })
                case .planned:
                    MeetingRequests.shared.removeMeeting(meetingID: meetingsVC.currentMeetings![indexPath.row].id, completion: {(error) in
                        if let error = error {
                            let alert = ErrorChecker.handler.getAlertController(error: error)
                            meetingsVC.navigationController?.present(alert, animated: true, completion: nil)
                            return
                        }
                        meetingsVC.currentMeetings!.remove(at: indexPath.row)
                        User.currentUser.plannedMeetings?.remove(at: indexPath.row)
                        meetingsVC.meetingTableView.deleteRows(at: [indexPath], with: .automatic)
                        meetingsVC.meetingTableView.reloadData()
                    })
                case .invitations:
                    break
                }
                
            })
            alert.addAction(cancelAction)
            alert.addAction(removeAction)
            meetingsVC.navigationController?.present(alert, animated: true)
        }
        return leaveAction
    }
    
    /// Создание UIContextualAction, отвечающего за удаления данного мероприятия
    static func deleteMeetingAction(indexPath: IndexPath, meetingsVC: MeetingsVC) -> UIContextualAction {
        let deleteAction = UIContextualAction(style: .destructive, title: "Отменить мероприятие") { [weak meetingsVC] (_, _, _) in
            guard let meetingsVC = meetingsVC else {
                return
            }
            let alert = UIAlertController(title: "Удалить мероприятие?", message: "Вы уверены, что хотите удалить мероприятие? Это действие нельзя отменить. Мероприятие будет удалено для всех его участников.", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
            let removeAction = UIAlertAction(title: "Удалить", style: .default, handler: {_ in
                MeetingRequests.shared.deleteMeeting(meetingID: meetingsVC.currentMeetings![indexPath.row].id, completion: {(error) in
                    if let error = error {
                        let alert = ErrorChecker.handler.getAlertController(error: error)
                        meetingsVC.navigationController?.present(alert, animated: true, completion: nil)
                        return
                    }
                    meetingsVC.currentMeetings!.remove(at: indexPath.row)
                    User.currentUser.plannedMeetings?.remove(at: indexPath.row)
                    meetingsVC.meetingTableView.deleteRows(at: [indexPath], with: .automatic)
                    meetingsVC.meetingTableView.reloadData()
                })
            })
            alert.addAction(cancelAction)
            alert.addAction(removeAction)
            meetingsVC.navigationController?.present(alert, animated: true)
        }
        return deleteAction
    }

    /// Создание UIContextualAction, отвечающего за ответ на приглашение на мероприятие
    static func inviteMeetingAction(participate: Bool, indexPath: IndexPath, meetingsVC: MeetingsVC) -> UIContextualAction {
        let participateAction = UIContextualAction(style: (participate ? .normal : .destructive), title: (participate ? "Участвовать" : "Отказаться")) { [weak meetingsVC] (_, _, _) in
            guard let meetingsVC = meetingsVC else {
                return
            }
            if indexPath.section == 0 {
                let meeting = User.currentUser.meetingInvitations!.personalInvitations[indexPath.row]
                MeetingRequests.shared.answerToInvitation(accept: participate, meetingID: meeting.id, completion: {(error) in
                    if let error = error {
                        let alert = ErrorChecker.handler.getAlertController(error: error)
                        meetingsVC.navigationController?.present(alert, animated: true, completion: nil)
                        return
                    }

                    meeting.isUserParticipant = true
                    meeting.currentParticipantNumber += 1

                    let index = User.currentUser.meetingInvitations!.personalInvitations.firstIndex(of: meeting)
                    User.currentUser.meetingInvitations!.personalInvitations.remove(at: index!)

                    if participate {
                        let index = User.currentUser.plannedMeetings?.lastIndex(where: {$0.startingDate < meeting.startingDate})
                        if let index = index {
                            User.currentUser.plannedMeetings?.insert(meeting, at: index + 1)
                        } else {
                            User.currentUser.plannedMeetings?.insert(meeting, at: 0)
                        }
                    }

                    meetingsVC.meetingTableView.reloadData()
                })
            } else {
                let meeting = User.currentUser.meetingInvitations!.groupInvitations[indexPath.section - 1].meetings[indexPath.row]
                GroupRequests.shared.respondMeetingForGroupInvitation(accept: participate, groupID: (User.currentUser.meetingInvitations?.groupInvitations[indexPath.section - 1].group.id)!, meetingID: (User.currentUser.meetingInvitations?.groupInvitations[indexPath.section - 1].meetings[indexPath.row].id)!,
                                                                      completion: {(error) in
                    if let error = error {
                        let alert = ErrorChecker.handler.getAlertController(error: error)
                        meetingsVC.navigationController?.present(alert, animated: true, completion: nil)
                        return
                    }

                    let index = User.currentUser.meetingInvitations!.groupInvitations[indexPath.section - 1].meetings.firstIndex(of: meeting)
                    User.currentUser.meetingInvitations!.groupInvitations[indexPath.section - 1].meetings.remove(at: index!)

                    meetingsVC.meetingTableView.reloadData()
                })
            }
        }
        return participateAction
    }
}
