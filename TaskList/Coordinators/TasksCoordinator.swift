//
//  TasksCoordinator.swift
//  TaskList
//
//  Created by Alexey Efimov on 06.06.2025.
//

import UIKit

@MainActor
final class TasksCoordinator: BaseCoordinator {

    private let storage: Storage
    private let taskList: TaskList

    init(
        navigationController: UINavigationController,
        storage: Storage,
        taskList: TaskList
    ) {
        self.storage = storage
        self.taskList = taskList
        super.init(navigationController: navigationController)
    }

    override func start() {
        // будет реализовано на шаге 5
    }
}
