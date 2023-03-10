//
//  SceneDelegate.swift
//  KudaGo
//
//  Created by Николай Игнатов on 15.01.2023.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
 
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions){
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        window?.windowScene = windowScene
        let navigationController = UINavigationController(rootViewController: EventsViewController())
        window?.makeKeyAndVisible()
        window?.rootViewController = navigationController
    }
}

