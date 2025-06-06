//
//  TaskListsCoordinator.swift
//  TaskList
//
//  Created by Alexey Efimov on 06.06.2025.
//


import UIKit

/// События, поступающие из TaskListsViewModel
protocol TaskListsOutput: AnyObject {
    /// Пользователь выбрал конкретный список задач
    func didSelect(taskList: TaskList)

    /// Пользователь нажал «+» для создания нового списка
    func didTapAddList()
}

/// Координатор списка задач
@MainActor
final class TaskListsCoordinator: BaseCoordinator {

    // MARK: - Dependencies
    private let storage: Storage

    // MARK: - Initializers
    init(navigationController: UINavigationController, storage: Storage) {
        self.storage = storage
        super.init(navigationController: navigationController)
    }

    // MARK: - Start
    override func start() {
        let viewModel = TaskListsViewModel(storage: storage)
        let viewController = TaskListsViewController(viewModel: viewModel)

        // Делегат для передачи событий наверх
        viewModel.output = self

        navigationController.setViewControllers([viewController], animated: false)
    }
}

// MARK: - TaskListsOutput
extension TaskListsCoordinator: @preconcurrency TaskListsOutput {
    func didSelect(taskList: TaskList) {
        // Переход во флоу конкретного списка задач
        let tasksCoordinator = TasksCoordinator(
            navigationController: navigationController,
            storage: storage,
            taskList: taskList
        )
        addChild(tasksCoordinator)
        tasksCoordinator.start()
    }

    func didTapAddList() {
        // Экран создания нового списка (можно ре-юзать TaskListEditorCoordinator)
        let listEditor = TaskListEditorCoordinator(
            navigationController: navigationController,
            storage: storage
        )
        addChild(listEditor)
        listEditor.start()
    }
}
