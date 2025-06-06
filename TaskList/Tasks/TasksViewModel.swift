//
//  TasksViewModel.swift
//  TaskList
//
//  Created by Alexey Efimov on 26.05.2025.
//

import Foundation

/// Контракт для ViewModel, обслуживающей экран со списком задач.
/// Позволяет получать количество задач, доступ к отдельным задачам,
/// и выполнять действия над задачами (добавление, удаление, переключение состояния).
protocol TasksViewModelProtocol {
    /// Заголовок текущего списка
    var taskListTitle: String { get }
    
    /// Количество задач в списке
    var numberOfTasks: Int { get }
    
    /// Колбэк, вызываемый при обновлении задач
    var onTasksChanged: ((ListUpdate) -> Void)? { get set }
    
    /// Колбэк, вызываемый при возникновении ошибки
    var onError: ((Error) -> Void)? { get set }
    
    /// Создаёт новую задачу на основе пользовательского ввода
    /// - Parameter input: Вводимые пользователем данные
    func createTask(from input: TaskInput)
    
    /// Обновляет задачу по индексу на основе пользовательского ввода
    /// - Parameters:
    ///   - indexPath: Индекс редактируемой задачи
    ///   - input: Новые значения полей
    func updateTask(at indexPath: IndexPath, with input: TaskInput)
    
    /// Помечает задачу как выполненную
    /// - Parameter indexPath: Индекс задачи
    func markTaskAsComplete(at indexPath: IndexPath)
    
    /// Удаляет задачу из хранилища и списка
    /// - Parameter indexPath: Индекс удаляемой задачи
    func deleteTask(at indexPath: IndexPath)
    
    /// Возвращает модель представления для отображения задачи в ячейке.
    /// - Parameter index: Индекс задачи.
    /// - Returns: ViewModel с отформатированными данными для UI.
    func cellViewModel(at indexPath: IndexPath) -> TaskCellViewModel
    
    /// Возвращает модель представления для экрана добавления и редактирования задачи.
    /// - Parameter indexPath: Индекс строки в списке задач. Если значение `nil`, будет создана модель с пустыми полями.
    /// - Returns: Экземпляр `TaskEditorViewModelProtocol`, готовый к передаче в `TaskEditorViewController`.
    func taskEditorViewModel(at indexPath: IndexPath?) -> TaskEditorViewModelProtocol
}

/// Модель представления для списка задач
final class TasksViewModel {
    
    // MARK: - Public API
    var taskListTitle: String {
        taskList.title
    }

    var numberOfTasks: Int {
        tasks.count
    }
    
    var onTasksChanged: ((ListUpdate) -> Void)?
    
    var onError: ((any Error) -> Void)?

    // MARK: - Private Properties
    private var taskList: TaskList
    private let storage: Storage
    private var tasks: [Task] = []
    
    // MARK: - Initialization
    /// Инициализирует модель представления конкретным списком и хранилищем
    /// - Parameters:
    ///   - taskList: Список задач, с которым работает сцена
    ///   - storage: Хранилище задач
    init(taskList: TaskList, storage: Storage) {
        self.taskList = taskList
        self.storage = storage
        
        loadTasks()
    }
}

// MARK: - TasksViewModelProtocol
extension TasksViewModel: TasksViewModelProtocol {
    func createTask(from input: TaskInput) {
        let task = Task(from: input)
        
        storage.create(task, to: taskList) { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success:
                tasks.append(task)
                sortTasks()
                
                guard let taskIndex = tasks.firstIndex(where: { $0.id == task.id }) else { return }
                let indexPath = IndexPath(row: taskIndex, section: 0)
                onTasksChanged?(.inserted(indexPath: indexPath))
            case .failure(let error):
                onError?(error)
            }
        }
    }
    
    func updateTask(at indexPath: IndexPath, with input: TaskInput) {
        var task = tasks[indexPath.row]
        
        task.title = input.title
        task.note = input.note
        task.dueDate = input.dueDate
        task.isComplete = input.isComplete
        
        storage.update(task) { [weak self] result in
            guard let self else { return }

            switch result {
            case .success:
                guard let oldIndex = tasks.firstIndex(where: { $0.id == task.id }) else { return }

                let oldTask = tasks[oldIndex]
                let oldIndexPath = IndexPath(row: oldIndex, section: 0)

                // Если ничего не изменилось — выходим
                guard oldTask != task else { return }
                tasks[oldIndex] = task
                applySortedUpdate(for: oldTask, from: oldIndexPath)
            case .failure(let error):
                onError?(error)
            }
        }
    }
    
    func markTaskAsComplete(at indexPath: IndexPath) {
        let task = tasks[indexPath.row]

        storage.done(task) { [weak self] result in
            guard let self else { return }

            switch result {
            case .success(let updatedTask):
                tasks[indexPath.row] = updatedTask
                applySortedUpdate(for: task, from: indexPath)
            case .failure(let error):
                onError?(error)
            }
        }
    }
    
    func deleteTask(at indexPath: IndexPath) {
        let task = tasks[indexPath.row]
        
        storage.delete(task) { [weak self] result in
            guard let self else { return }

            switch result {
            case .success:
                tasks.remove(at: indexPath.row)
                onTasksChanged?(.deleted(indexPath: indexPath))
            case .failure(let error):
                onError?(error)
            }
        }
    }
    
    func cellViewModel(at indexPath: IndexPath) -> TaskCellViewModel {
        let task = tasks[indexPath.row]
        
        return TaskCellViewModel(
            title: task.title,
            note: task.note,
            isComplete: task.isComplete
        )
    }
    
    func taskEditorViewModel(at indexPath: IndexPath?) -> any TaskEditorViewModelProtocol {
        guard let indexPath else { return TaskEditorViewModel() }
        
        let task = tasks[indexPath.row]
        let input = TaskInput(
            title: task.title,
            note: task.note,
            dueDate: task.dueDate,
            isComplete: task.isComplete
        )
        return TaskEditorViewModel(input: input)
    }
}

// MARK: - Internal Methods
private extension TasksViewModel {
    func loadTasks() {
        tasks = taskList.tasks
        sortTasks()
        onTasksChanged?(.fullReloaded)
    }
    
    func sortTasks() {
        let current = tasks.filter { !$0.isComplete }
        let completed = tasks.filter { $0.isComplete }
        
        tasks = current + completed
    }
    
    func applySortedUpdate(for updatedTask: Task, from oldIndexPath: IndexPath) {
        sortTasks()
        
        // Находим новое расположение задачи по идентификатору
        guard let newIndex = tasks.firstIndex(where: { $0.id == updatedTask.id }) else { return }
        let newIndexPath = IndexPath(row: newIndex, section: 0)
        
        if oldIndexPath == newIndexPath {
            // Если положение не изменилось, просто перезагружаем строку
            onTasksChanged?(.reloaded(indexPath: newIndexPath))
        } else {
            // При изменении расположения уведомляем о перемещении
            onTasksChanged?(.moved(oldIndexPath: oldIndexPath, newIndexPath: newIndexPath))
        }
    }
}

/// Модель представления задачи для отображения в ячейке
struct TaskCellViewModel {
    let title: String
    let note: String?
    let isComplete: Bool

    var attributedTitle: NSAttributedString {
        title.strikeThrough(isComplete)
    }
    
    var attributedNote: NSAttributedString? {
        note?.strikeThrough(isComplete)
    }
}
