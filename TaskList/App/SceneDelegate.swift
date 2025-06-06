//
//  SceneDelegate.swift
//  TaskList
//
//  Created by Alexey Efimov on 05.05.2025.
//

import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    private var appCoordinator: AppCoordinator?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        let appCoordinator = AppCoordinator(window: window)
        
        self.window = window
        self.appCoordinator = appCoordinator
        
        appCoordinator.start()
    }
}

