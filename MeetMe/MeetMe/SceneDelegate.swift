//
//  SceneDelegate.swift
//  MeetMe
//
//  Created by Stepan Ostapenko on 24.02.2022.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let scene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(frame: scene.coordinateSpace.bounds)
        window?.windowScene = scene
        
        if let email = UserDefaults.standard.string(forKey: "userEmail") {
            if let password = UserDefaults.standard.string(forKey: "userPassword") {
                AuthRequests.shared.getJWTToken(info: JWTBullshit(email: email, password: password), completion: {(token, error) in
                    if error != nil {
                        self.window?.rootViewController = NavigationHandler.createAuthNC()
                    }
                    if let token = token {
                        MeetingRequests.JWTToken = token
                        AuthRequests.shared.login(info: LoginInfo(email: email, password: password), completion: { (account, error) in
                            if error != nil {
                                print(3)
                                self.window?.rootViewController = NavigationHandler.createAuthNC()
                            }

                            if let account = account {
                                User.currentUser.account = account
                                self.window?.rootViewController = NavigationHandler.createTabBar()
                            }
                        })
                    }
                })
            } else {
                print("no password")
                window?.rootViewController = NavigationHandler.createAuthNC()
            }
        } else {
            print("no email")
            window?.rootViewController = NavigationHandler.createAuthNC()
        }
        
        
        window?.makeKeyAndVisible()
        
    }
    

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.

        // Save changes in the application's managed object context when the application transitions to the background.
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }


}

