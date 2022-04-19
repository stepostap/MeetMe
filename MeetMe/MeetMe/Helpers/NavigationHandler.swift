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
        accountVC.title = "Аккаунт"
        accountVC.tabBarItem = UITabBarItem(title: "Аккаунт", image: UIImage(named: "account2"), tag: 0)
        let navigation = UINavigationController(rootViewController: accountVC)
        navigation.navigationBar.barTintColor = UIColor(named: "BackgroundDarker")
        
        return navigation
    }
    
    ///  Создание NavigationController, содержащего контроллер мероприятий
    static func createMeetingsNC() -> UINavigationController {
        
        let meetingVC = MeetingsVC()
        meetingVC.title = "Meetings"
        meetingVC.tabBarItem = UITabBarItem(title: "Meetings", image: UIImage(named: "meeting3"), tag: 1)
        let navigation = UINavigationController(rootViewController: meetingVC)
        navigation.navigationBar.barTintColor = UIColor(named: "BackgroundDarker")
        
        return navigation
    }
    
    ///  Создание NavigationController, содержащего контроллер групп
    static func createGroupsNC() -> UINavigationController {
        
        let groupsVC = GroupsVC()
        groupsVC.title = "Groups"
        groupsVC.tabBarItem = UITabBarItem(title: "Groups", image: UIImage(named: "groups3"), tag: 2)
        let navigation = UINavigationController(rootViewController: groupsVC)
        navigation.navigationBar.barTintColor = UIColor(named: "BackgroundDarker")
        
        return navigation
    }
    
    ///  Создание TabBarController, содержащего 3 NavigationController: для мероприятий, для аккаунта и для групп
    static func createTabBar() -> UITabBarController {
        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [createAccountNC(), createMeetingsNC(), createGroupsNC()]
        let appearance = UITabBarAppearance()
        appearance.backgroundColor = UIColor(named: "BackgroundDarker")
        appearance.selectionIndicatorTintColor = UIColor(named: "BackgroundDarker")
        appearance.shadowColor = UIColor(named: "BackgroundDarker")
        tabBarController.tabBar.standardAppearance = appearance
        tabBarController.tabBar.isTranslucent = false
        tabBarController.tabBar.backgroundColor = UIColor(named: "BackgroundDarker")
        
        
        return tabBarController
    }
    
    ///  Создание NavigationController, содержащего контроллер для авторизации и регистрации пользователей
    static func createAuthNC() -> UINavigationController {
        
        return UINavigationController(rootViewController: LoginVC())
    }
}
