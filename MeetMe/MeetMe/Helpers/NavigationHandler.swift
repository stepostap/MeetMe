//
//  NavigationHandler.swift
//  MeetMe
//
//  Created by Stepan Ostapenko on 26.02.2022.
//

import Foundation
import UIKit

class NavigationHandler {
    
    static  func createAccountNC() -> UINavigationController {
        
        let accountVC = AccountVC()
        accountVC.title = "Account"
        accountVC.tabBarItem = UITabBarItem(title: "Account", image: UIImage(named: "account2"), tag: 0)
        
        return UINavigationController(rootViewController: accountVC)
    }
    
    
    static func createMeetingsNC() -> UINavigationController {
        
        let meetingVC = MeetingsVC()
        meetingVC.title = "Meetings"
        meetingVC.tabBarItem = UITabBarItem(title: "Meetings", image: UIImage(named: "meeting3"), tag: 1)
        
        return UINavigationController(rootViewController: meetingVC)
    }
    
    
    static func createGroupsNC() -> UINavigationController {
        
        let groupsVC = GroupsVC()
        groupsVC.title = "Groups"
        groupsVC.tabBarItem = UITabBarItem(title: "Groups", image: UIImage(named: "groups3"), tag: 2)
        
        return UINavigationController(rootViewController: groupsVC)
    }
    
    static func createTabBar() -> UITabBarController {
        let tabBarController = UITabBarController()
        UITabBar.appearance().tintColor = .systemBlue
        tabBarController.viewControllers = [createAccountNC(), createMeetingsNC(), createGroupsNC()]
        
        return tabBarController
    }
    
    static func createAuthNC() -> UINavigationController {
        
        return UINavigationController(rootViewController: LoginVC())
    }
}
