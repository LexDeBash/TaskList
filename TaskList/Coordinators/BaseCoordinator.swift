//
//  BaseCoordinator.swift
//  TaskList
//
//  Created by Alexey Efimov on 06.06.2025.
//


import UIKit

/// Базовый класс с приватным weak-хранилищем дочерних координаторов
@MainActor
class BaseCoordinator: Coordinator {

    // MARK: - Public API
    let navigationController: UINavigationController
    
    // MARK: - Private Properties
    /// Weak-коллекция, исключающая retain-циклы
    private let childCoordinators = NSHashTable<AnyObject>(
        options: [.weakMemory]
    )

    // MARK: - Initializers
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    /// Переопределяется в наследнике
    func start() { }

    /// Завершает флоу и рекурсивно закрывает детей
    func finish() {
        removeAllChildren()
    }

    // MARK: - Child management
    /// Удерживает координатор как слабую ссылку
    func addChild(_ coordinator: Coordinator) {
        childCoordinators.add(coordinator)
    }

    /// Удаляет координатор из коллекции
    func removeChild(_ coordinator: Coordinator) {
        childCoordinators.remove(coordinator)
    }

    /// Завершает и очищает всех детей
    func removeAllChildren() {
        for case let child as Coordinator in childCoordinators.allObjects {
            child.finish()
        }
        childCoordinators.removeAllObjects()
    }
}
