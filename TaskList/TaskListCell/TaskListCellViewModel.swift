//
//  TaskListCellViewModel.swift
//  TaskList
//
//  Created by Alexey Efimov on 26.05.2025.
//

import Foundation

/// Модель представления для отображения ячейки списка задач
struct TaskListCellViewModel {
    /// Заголовок списка задач
    let title: String

    /// Текст со статусом задач (количество или nil)
    let status: String?

    /// Отображать ли checkmark
    let isCompleted: Bool
    
    init(from taskList: TaskList) {
        title = taskList.title

        let tasks = taskList.tasks
        let currentTasks = tasks.filter { !$0.isComplete }

        if tasks.isEmpty {
            status = "0"
            isCompleted = false
        } else if currentTasks.isEmpty {
            status = nil
            isCompleted = true
        } else {
            status = currentTasks.count.formatted()
            isCompleted = false
        }
    }
}
