//
//  Storage.swift
//  TaskList
//
//  Created by Alexey Efimov on 19.05.2025.
//

import Foundation

/// Ошибки, которые могут возникнуть при работе с хранилищем данных.
enum StorageError: Error {
    /// Список задач не найден.
    case taskListNotFound
    
    /// Задача не найдена.
    case taskNotFound
}

/// Протокол, определяющий асинхронный интерфейс для работы с хранилищем списков задач и отдельных задач.
///
/// Все операции выполняются асинхронно и сообщают о результате через замыкание completion.
/// При реализации этого протокола необходимо обеспечить потокобезопасность.
///
/// - Note: При работе с данным протоколом могут возникнуть ошибки типа `StorageError`.
protocol Storage {
    // MARK: - TaskLists
    
    /// Получает все списки задач из хранилища.
    /// - Parameter completion: Замыкание, вызываемое по завершении операции с результатом, содержащим массив списков задач или ошибку.
    func fetchTaskLists(completion: @escaping(Result<[TaskList], Error>) -> Void)
    
    /// Создает новый список задач в хранилище.
    /// - Parameters:
    ///   - taskList: Список задач для создания.
    ///   - completion: Замыкание, вызываемое по завершении операции с результатом успеха или ошибки.
    func create(_ taskList: TaskList, completion: @escaping(Result<Void, Error>) -> Void)
    
    /// Обновляет существующий список задач в хранилище.
    /// - Parameters:
    ///   - taskList: Список задач для обновления.
    ///   - completion: Замыкание, вызываемое по завершении операции с результатом успеха или ошибки.
    /// - Note: Может вернуть ошибку `StorageError.taskListNotFound`, если список задач не найден.
    func update(_ taskList: TaskList, completion: @escaping(Result<Void, Error>) -> Void)
    
    /// Удаляет список задач из хранилища.
    /// - Parameters:
    ///   - taskList: Список задач для удаления.
    ///   - completion: Замыкание, вызываемое по завершении операции с результатом успеха или ошибки.
    /// - Note: Может вернуть ошибку `StorageError.taskListNotFound`, если список задач не найден.
    func delete(_ taskList: TaskList, completion: @escaping(Result<Void, Error>) -> Void)
    
    /// Отмечает список задач как выполненный.
    /// - Parameters:
    ///   - taskList: Список задач для отметки.
    ///   - completion: Замыкание, вызываемое по завершении операции с результатом, содержащим обновленный список задач или ошибку.
    /// - Note: Возвращает обновленный объект списка задач, что позволяет получить актуальное состояние после изменения.
    /// - Note: Может вернуть ошибку `StorageError.taskListNotFound`, если список задач не найден.
    func done(_ taskList: TaskList, completion: @escaping(Result<TaskList, Error>) -> Void)
    
    // MARK: - Tasks
    
    /// Создает новую задачу в указанном списке задач.
    /// - Parameters:
    ///   - task: Задача для создания.
    ///   - taskList: Список задач, в который нужно добавить задачу.
    ///   - completion: Замыкание, вызываемое по завершении операции с результатом успеха или ошибки.
    /// - Note: Может вернуть ошибку `StorageError.taskListNotFound`, если указанный список задач не найден.
    func create(_ task: Task, to taskList: TaskList, completion: @escaping (Result<Void, Error>) -> Void)
    
    /// Обновляет существующую задачу в хранилище.
    /// - Parameters:
    ///   - task: Задача для обновления.
    ///   - completion: Замыкание, вызываемое по завершении операции с результатом успеха или ошибки.
    /// - Note: Может вернуть ошибку `StorageError.taskNotFound`, если задача не найдена.
    func update(_ task: Task, completion: @escaping (Result<Void, Error>) -> Void)
    
    /// Удаляет задачу из хранилища.
    /// - Parameters:
    ///   - task: Задача для удаления.
    ///   - completion: Замыкание, вызываемое по завершении операции с результатом успеха или ошибки.
    /// - Note: Может вернуть ошибку `StorageError.taskNotFound`, если задача не найдена.
    func delete(_ task: Task, completion: @escaping (Result<Void, Error>) -> Void)
    
    /// Отмечает задачу как выполненную.
    /// - Parameters:
    ///   - task: Задача для отметки.
    ///   - completion: Замыкание, вызываемое по завершении операции с результатом, содержащим обновленную задачу или ошибку.
    /// - Note: Возвращает обновленный объект задачи, что позволяет получить актуальное состояние после изменения.
    /// - Note: Может вернуть ошибку `StorageError.taskNotFound`, если задача не найдена.
    func done(_ task: Task, completion: @escaping (Result<Task, Error>) -> Void)
}

