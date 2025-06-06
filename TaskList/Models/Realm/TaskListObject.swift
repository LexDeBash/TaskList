//
//  TaskListObject.swift
//  TaskList
//
//  Created by Alexey Efimov on 29.05.2025.
//

import Foundation
import RealmSwift

final class TaskListObject: Object {
    @Persisted(primaryKey: true) var id: UUID
    @Persisted var title: String
    @Persisted var creationDate: Date
    @Persisted var tasks = List<TaskObject>()
    
    convenience init(
        id: UUID,
        title: String,
        creationDate: Date
    ) {
        self.init()
        self.id = id
        self.title = title
        self.creationDate = creationDate
    }
}

extension TaskListObject {
    func toDTO() -> TaskList {
        TaskList(
            id: id,
            title: title,
            creationDate: creationDate,
            tasks: tasks.map { $0.toDTO() }
        )
    }
}

final class TaskObject: Object {
    @Persisted(primaryKey: true) var id: UUID
    @Persisted var title: String
    @Persisted var note: String?
    @Persisted var creationDate: Date
    @Persisted var dueDate: Date?
    @Persisted var isComplete: Bool
    
    convenience init(
        id: UUID,
        title: String,
        note: String?,
        creationDate: Date,
        dueDate: Date?,
        isComplete: Bool
    ) {
        self.init()
        self.id = id
        self.title = title
        self.note = note
        self.creationDate = creationDate
        self.dueDate = dueDate
        self.isComplete = isComplete
    }
}

extension TaskObject {
    func toDTO() -> Task {
        Task(
            id: id,
            title: title,
            note: note,
            creationDate: creationDate,
            dueDate: dueDate,
            isComplete: isComplete
        )
    }
}
