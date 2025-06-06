//
//  RealmStorage.swift
//  TaskList
//
//  Created by Alexey Efimov on 29.05.2025.
//

import RealmSwift

final class RealmStorage: Storage {
    
    private let realm: Realm
    
    init() {
        do {
            realm = try Realm()
        } catch {
            fatalError("Failed to initialize Realm: \(error)")
        }
    }
    
}

// MARK: - TaskLists
extension RealmStorage {
    func fetchTaskLists(completion: @escaping (Result<[TaskList], any Error>) -> Void) {
        let taskListObjects = realm.objects(TaskListObject.self)
        let taskLists = taskListObjects.map { $0.toDTO() }
        
        completion(.success(Array(taskLists)))
    }
    
    func create(_ taskList: TaskList, completion: @escaping (Result<Void, any Error>) -> Void) {
        let taskListObject = TaskListObject(
            id: taskList.id,
            title: taskList.title,
            creationDate: taskList.creationDate
        )
        
        performRealmWrite {
            realm.add(taskListObject)
        } completion: { result in
            completion(result)
        }

    }
    
    func update(_ taskList: TaskList, completion: @escaping (Result<Void, any Error>) -> Void) {
        fetchObject(ofType: TaskListObject.self, forPrimaryKey: taskList.id) { result in
            switch result {
            case .success(let taskListObject):
                performRealmWrite {
                    taskListObject.title = taskList.title
                } completion: { result in
                    completion(result)
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func delete(_ taskList: TaskList, completion: @escaping (Result<Void, any Error>) -> Void) {
        fetchObject(ofType: TaskListObject.self, forPrimaryKey: taskList.id) { result in
            switch result {
            case .success(let taskListObject):
                performRealmWrite {
                    realm.delete(taskListObject.tasks)
                    realm.delete(taskListObject)
                } completion: { result in
                    completion(result)
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }

    }
    
    func done(_ taskList: TaskList, completion: @escaping (Result<TaskList, any Error>) -> Void) {
        fetchObject(ofType: TaskListObject.self, forPrimaryKey: taskList.id) { result in
            switch result {
            case .success(let taskListObject):
                do {
                    try realm.write {
                        taskListObject.tasks.forEach { $0.isComplete = true }
                    }
                    completion(.success(taskListObject.toDTO()))
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

// MARK: - Tasks
extension RealmStorage {
    func create(_ task: Task, to taskList: TaskList, completion: @escaping (Result<Void, any Error>) -> Void) {
        fetchObject(ofType: TaskListObject.self, forPrimaryKey: taskList.id) { result in
            switch result {
            case .success(let taskListObject):
                let taskObject = TaskObject(
                    id: task.id,
                    title: task.title,
                    note: task.note,
                    creationDate: task.creationDate,
                    dueDate: task.dueDate,
                    isComplete: task.isComplete
                )
                
                performRealmWrite {
                    taskListObject.tasks.append(taskObject)
                } completion: { result in
                    completion(result)
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func update(_ task: Task, completion: @escaping (Result<Void, any Error>) -> Void) {
        fetchObject(ofType: TaskObject.self, forPrimaryKey: task.id) { result in
            switch result {
            case .success(let taskObject):
                performRealmWrite {
                    taskObject.title = task.title
                    taskObject.note = task.note
                    taskObject.dueDate = task.dueDate
                    taskObject.isComplete = task.isComplete
                } completion: { result in
                    completion(result)
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func delete(_ task: Task, completion: @escaping (Result<Void, any Error>) -> Void) {
        fetchObject(ofType: TaskObject.self, forPrimaryKey: task.id) { result in
            switch result {
            case .success(let taskObject):
                performRealmWrite {
                    realm.delete(taskObject)
                } completion: { result in
                    completion(result)
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func done(_ task: Task, completion: @escaping (Result<Task, any Error>) -> Void) {
        fetchObject(ofType: TaskObject.self, forPrimaryKey: task.id) { result in
            switch result {
            case .success(let taskObject):
                do {
                    try realm.write {
                        taskObject.isComplete = true
                    }
                    
                    completion(.success(taskObject.toDTO()))
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

// MARK: - Private Methods
private extension RealmStorage {
    // Метод для выполнения записи в Realm с обработкой ошибок
    func performRealmWrite(writeBlock: () -> Void, completion: (Result<Void, Error>) -> Void) {
        do {
            try realm.write {
                writeBlock()
            }
            completion(.success(()))
        } catch {
            completion(.failure(error))
        }
    }
    
    // Универсальный метод для получения объекта из Realm по его идентификатору
    func fetchObject<T: Object>(ofType type: T.Type, forPrimaryKey key: Any, completion: (Result<T, Error>) -> Void) {
        guard let object = realm.object(ofType: type, forPrimaryKey: key) else {
            completion(.failure(RealmStorageError.objectNotFound))
            return
        }
        
        completion(.success(object))
    }
}

private extension RealmStorage {
    /// Ошибки, возникающие при работе с хранилищем RealmStorage.
    enum RealmStorageError: Error {
        /// Объект не найден в базе по заданному идентификатору.
        case objectNotFound
    }
}
