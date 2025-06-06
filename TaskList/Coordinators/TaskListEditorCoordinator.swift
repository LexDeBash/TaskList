//
//  TaskListEditorCoordinator.swift
//  TaskList
//
//  Created by Alexey Efimov on 06.06.2025.
//

import UIKit

@MainActor
final class TaskListEditorCoordinator: BaseCoordinator {

    private let storage: Storage
    private let taskList: TaskList?      // nil → создание, не nil → редактирование

    init(
        navigationController: UINavigationController,
        storage: Storage,
        taskList: TaskList? = nil
    ) {
        self.storage = storage
        self.taskList = taskList
        super.init(navigationController: navigationController)
    }

    // Реальная логика будет реализована на шаге 6
    override func start() { }
}
