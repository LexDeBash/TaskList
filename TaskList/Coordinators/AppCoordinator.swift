//
//  AppCoordinator.swift
//  TaskList
//
//  Created by Alexey Efimov on 06.06.2025.
//


import UIKit

/// Главный координатор, отвечает за инициализацию окна и стартовый флоу
@MainActor
final class AppCoordinator: BaseCoordinator {

    /// Окно приложения
    private let window: UIWindow

    /// Инициализирует координатор с окном, полученным из SceneDelegate
    /// - Parameter window: UIWindow, в котором отображается UI приложения
    init(window: UIWindow) {
        self.window = window
        super.init(navigationController: UINavigationController())
        navigationController.navigationBar.prefersLargeTitles = true
    }

    /// Точка входа — делаем navController root-контроллером и запускаем первый флоу
    override func start() {
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        showTasksFlow()
    }
}

// MARK: – Helpers
private extension AppCoordinator {

    /// Запускает координатор списка задач
    func showTasksFlow() {
        let tasksCoordinator = TaskListsCoordinator(
            navigationController: navigationController,
            storage: makeStorage()
        )
        addChild(tasksCoordinator)
        tasksCoordinator.start()
    }

    /// Фабрика хранилища: Core Data или Realm
    func makeStorage() -> Storage {
        #if USE_REALM
        return RealmStorage()
        #else
        return CoreDataStorage()
        #endif
    }
}
