//
//  TaskTaskList.swift
//  TaskList
//
//  Created by Alexey Efimov on 08.05.2025.
//

import Foundation

struct TaskList {
    var id = UUID()
    var title: String
    var creationDate = Date()
    var tasks: [Task] = []
}

struct Task: Codable, Equatable {
    var id = UUID()
    var title: String
    var note: String?
    var creationDate = Date()
    var dueDate: Date?
    var isComplete: Bool
    
    init(
        id: UUID = UUID(),
        title: String,
        note: String? = nil,
        creationDate: Date = Date(),
        dueDate: Date? = nil,
        isComplete: Bool
    ) {
        self.id = id
        self.title = title
        self.note = note
        self.creationDate = creationDate
        self.dueDate = dueDate
        self.isComplete = isComplete
    }
    
    init(from input: TaskInput) {
        title = input.title
        note = input.note
        dueDate = input.dueDate
        isComplete = input.isComplete
    }
}

/// Данные, необходимые для создания новой задачи
struct TaskInput {
    let title: String
    let note: String?
    let dueDate: Date?
    let isComplete: Bool
}

/// Критерии сортировки списков задач
enum SortOption: String {
    case creationDate
    case title
}
