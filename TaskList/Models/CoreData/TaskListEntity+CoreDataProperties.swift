//
//  TaskListEntity+CoreDataProperties.swift
//  TaskList
//
//  Created by Alexey Efimov on 15.05.2025.
//
//

import Foundation
import CoreData


extension TaskListEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TaskListEntity> {
        return NSFetchRequest<TaskListEntity>(entityName: "TaskListEntity")
    }

    @NSManaged public var id: UUID
    @NSManaged public var title: String
    @NSManaged public var creationDate: Date
    @NSManaged public var tasks: NSSet

}

// MARK: Generated accessors for tasks
extension TaskListEntity {

    @objc(addTasksObject:)
    @NSManaged public func addToTasks(_ value: TaskEntity)

    @objc(removeTasksObject:)
    @NSManaged public func removeFromTasks(_ value: TaskEntity)

    @objc(addTasks:)
    @NSManaged public func addToTasks(_ values: NSSet)

    @objc(removeTasks:)
    @NSManaged public func removeFromTasks(_ values: NSSet)

}

// MARK: - Initializer
extension TaskListEntity {
    @discardableResult
    convenience init(from taskList: TaskList, context: NSManagedObjectContext) {
        self.init(context: context)
        id = taskList.id
        title = taskList.title
        creationDate = taskList.creationDate
    }
}

// MARK: - TaskListEntity -> TaskList
extension TaskListEntity {
    func toTaskList() -> TaskList {
        let tasks = (tasks as? Set<TaskEntity>)?.map { $0.toTask() } ?? []
        
        return TaskList(
            id: id,
            title: title,
            creationDate: creationDate,
            tasks: tasks
        )
    }
}
