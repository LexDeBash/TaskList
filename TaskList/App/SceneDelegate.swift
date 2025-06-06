//
//  SceneDelegate.swift
//  TaskList
//
//  Created by Alexey Efimov on 05.05.2025.
//

import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let storage = RealmStorage()
        let taskListsViewModel = TaskListsViewModel(storage: storage)
        let rootVC = TaskListsViewController(viewModel: taskListsViewModel)
        
        window = UIWindow(windowScene: windowScene)
        window?.makeKeyAndVisible()
        window?.rootViewController = UINavigationController(rootViewController: rootVC)
    }
}

