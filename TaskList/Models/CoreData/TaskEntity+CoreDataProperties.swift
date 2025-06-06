//
//  TaskEntity+CoreDataProperties.swift
//  TaskList
//
//  Created by Alexey Efimov on 15.05.2025.
//
//

import Foundation
import CoreData


extension TaskEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TaskEntity> {
        return NSFetchRequest<TaskEntity>(entityName: "TaskEntity")
    }

    @NSManaged public var creationDate: Date
    @NSManaged public var dueDate: Date?
    @NSManaged public var id: UUID
    @NSManaged public var isComplete: Bool
    @NSManaged public var note: String?
    @NSManaged public var title: String
    @NSManaged public var taskList: TaskListEntity

}

// MARK: - Initializers
extension TaskEntity {
    convenience init(from task: Task, context: NSManagedObjectContext) {
        self.init(context: context)
        id = task.id
        title = task.title
        note = task.note
        isComplete = task.isComplete
        creationDate = task.creationDate
        dueDate = task.dueDate
    }
}

// MARK: - TaskEntity -> Task
extension TaskEntity {
    func toTask() -> Task {
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

// MARK: - Updating TaskEntity from DTO
extension TaskEntity {
    func update(from task: Task) {
        title = task.title
        note = task.note
        dueDate = task.dueDate
        isComplete = task.isComplete
    }
}
