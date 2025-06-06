//
//  CoreDataStorage.swift
//  TaskList
//
//  Created by Alexey Efimov on 19.05.2025.
//

import CoreData

final class CoreDataStorage: Storage {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext = PersistentController.shared.context) {
        self.context = context
    }
}

// MARK: - TaskList
extension CoreDataStorage {
    func fetchTaskLists(completion: @escaping (Result<[TaskList], any Error>) -> Void) {
        let request = TaskListEntity.fetchRequest()
        
        performContextOperation { storage in
            do {
                let taskListEntities = try storage.context.fetch(request)
                let taskLists = taskListEntities.map { $0.toTaskList() }
                
                DispatchQueue.main.async {
                    completion(.success(taskLists))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    func create(_ taskList: TaskList, completion: @escaping (Result<Void, any Error>) -> Void) {
        performContextOperation { storage in
            TaskListEntity(from: taskList, context: storage.context)
            
            do {
                try storage.context.save()
                DispatchQueue.main.async {
                    completion(.success(()))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    func update(_ taskList: TaskList, completion: @escaping (Result<Void, any Error>) -> Void) {
        performContextOperation { storage in
            do {
                let taskListEntity = try storage.fetchTaskListEntity(by: taskList.id)
                taskListEntity.title = taskList.title
                
                try storage.context.save()
                
                DispatchQueue.main.async {
                    completion(.success(()))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    func delete(_ taskList: TaskList, completion: @escaping (Result<Void, any Error>) -> Void) {
        performContextOperation { storage in
            do {
                let taskListEntity = try storage.fetchTaskListEntity(by: taskList.id)
                storage.context.delete(taskListEntity)
                
                try storage.context.save()
                
                DispatchQueue.main.async {
                    completion(.success(()))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    func done(_ taskList: TaskList, completion: @escaping (Result<TaskList, any Error>) -> Void) {
        performContextOperation { storage in
            do {
                let taskListEntity = try storage.fetchTaskListEntity(by: taskList.id)
                let tasks = taskListEntity.tasks as? Set<TaskEntity> ?? []
                
                tasks.forEach { $0.isComplete = true }
                try storage.context.save()
                
                let updatedList = taskListEntity.toTaskList()
                
                DispatchQueue.main.async {
                    completion(.success(updatedList))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
}

// MARK: - Tasks
extension CoreDataStorage {
    func create(_ task: Task, to taskList: TaskList, completion: @escaping (Result<Void, Error>) -> Void) {
        performContextOperation { storage in
            do {
                let taskListEntity = try storage.fetchTaskListEntity(by: taskList.id)
                let taskEntity = TaskEntity(from: task, context: storage.context)
                
                taskListEntity.addToTasks(taskEntity)
                try storage.context.save()
                
                DispatchQueue.main.async {
                    completion(.success(()))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    func update(_ task: Task, completion: @escaping (Result<Void, Error>) -> Void) {
        performContextOperation { storage in
            do {
                let taskEntity = try storage.fetchTaskEntity(by: task.id)
                taskEntity.update(from: task)

                try storage.context.save()
                
                DispatchQueue.main.async {
                    completion(.success(()))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    func delete(_ task: Task, completion: @escaping (Result<Void, Error>) -> Void) {
        performContextOperation { storage in
            do {
                let taskEntity = try storage.fetchTaskEntity(by: task.id)
                storage.context.delete(taskEntity)
                try storage.context.save()
                
                DispatchQueue.main.async {
                    completion(.success(()))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    func done(_ task: Task, completion: @escaping (Result<Task, Error>) -> Void) {
        performContextOperation { storage in
            do {
                let taskEntity = try storage.fetchTaskEntity(by: task.id)
                taskEntity.isComplete = true
                
                try storage.context.save()
                let updatedTask = taskEntity.toTask()
                
                DispatchQueue.main.async {
                    completion(.success(updatedTask))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
}

// MARK: - Internal Methods
private extension CoreDataStorage {
    func fetchTaskListEntity(by id: UUID) throws -> TaskListEntity {
        let request = TaskListEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        guard let taskListEntity = try context.fetch(request).first else {
            throw StorageError.taskListNotFound
        }
        
        return taskListEntity
    }
    
    func fetchTaskEntity(by id: UUID) throws -> TaskEntity {
        let request = TaskEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)

        guard let task = try context.fetch(request).first else {
            throw StorageError.taskNotFound
        }

        return task
    }
    
    func performContextOperation(_ completion: @escaping (CoreDataStorage) -> Void) {
        context.perform { [weak self] in
            guard let self else { return }
            completion(self)
        }
    }
}
