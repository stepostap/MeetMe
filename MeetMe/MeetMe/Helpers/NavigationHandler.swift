//
//  NavigationHandler.swift
//  MeetMe
//
//  Created by Stepan Ostapenko on 26.02.2022.
//

import Foundation
import UIKit

/// Класс, отвечающий за создание навигациии в приложении
class NavigationHandler {
    ///  Создание NavigationController, содержащего контроллер аккаунта
    static func createAccountNC() -> UINavigationController {
        
        let accountVC = AccountVC()
        accountVC.title = "Account"
        accountVC.tabBarItem = UITabBarItem(title: "Account", image: UIImage(named: "account2"), tag: 0)
        
        return UINavigationController(rootViewController: accountVC)
    }
    
    ///  Создание NavigationController, содержащего контроллер мероприятий
    static func createMeetingsNC() -> UINavigationController {
        
        let meetingVC = MeetingsVC()
        meetingVC.title = "Meetings"
        meetingVC.tabBarItem = UITabBarItem(title: "Meetings", image: UIImage(named: "meeting3"), tag: 1)
        
        return UINavigationController(rootViewController: meetingVC)
    }
    
    ///  Создание NavigationController, содержащего контроллер групп
    static func createGroupsNC() -> UINavigationController {
        
        let groupsVC = GroupsVC()
        groupsVC.title = "Groups"
        groupsVC.tabBarItem = UITabBarItem(title: "Groups", image: UIImage(named: "groups3"), tag: 2)
        
        return UINavigationController(rootViewController: groupsVC)
    }
    
    ///  Создание TabBarController, содержащего 3 NavigationController: для мероприятий, для аккаунта и для групп
    static func createTabBar() -> UITabBarController {
        let tabBarController = UITabBarController()
        UITabBar.appearance().tintColor = .systemBlue
        tabBarController.viewControllers = [createAccountNC(), createMeetingsNC(), createGroupsNC()]
        
        return tabBarController
    }
    
    ///  Создание NavigationController, содержащего контроллер для авторизации и регистрации пользователей
    static func createAuthNC() -> UINavigationController {
        
        return UINavigationController(rootViewController: LoginVC())
    }
}
