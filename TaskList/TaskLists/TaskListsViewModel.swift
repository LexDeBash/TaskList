//
//  TaskListsViewModel.swift
//  TaskList
//
//  Created by Alexey Efimov on 26.05.2025.
//

import Foundation

/// Обновление, которое сообщает View о конкретном изменении в списке.
/// Позволяет View обновлять таблицу в соответсвии с ситуацией.
enum ListUpdate {
    case inserted(indexPath: IndexPath)
    case deleted(indexPath: IndexPath)
    case reloaded(indexPath: IndexPath)
    case moved(oldIndexPath: IndexPath, newIndexPath: IndexPath)
    case fullReloaded
}

/// Интерфейс взаимодействия ViewController с ViewModel списка задач
protocol TaskListsViewModelProtocol: AnyObject {

    /// Колбэк, вызываемый при обновлении списков задач
    var onListsUpdated: ((ListUpdate) -> Void)? { get set }
    
    /// Колбэк, вызываемый при возникновении ошибки
    var onError: ((Error) -> Void)? { get set }
    
    /// Количество списков задач
    var numberOfLists: Int { get }
    
    /// Создаёт новый список задач с заданным заголовком
    /// - Parameter title: Название списка задач
    func createList(with title: String)
    
    /// Обновляет заголовок списка задач по указанному индексу
    /// - Parameters:
    ///   - indexPath: Индекс списка задач
    ///   - newTitle: Новый заголовок
    func renameList(at indexPath: IndexPath, to newTitle: String)
    
    /// Помечает все задачи в списке как выполненные
    /// - Parameter indexPath: Индекс списка задач
    func markListAsDone(at indexPath: IndexPath)
    
    /// Удаляет список задач по указанному индексу
    /// - Parameter indexPath: Индекс удаляемого списка
    func deleteList(at indexPath: IndexPath)
    
    /// Применяет сортировку к спискам задач
    /// - Parameter sortOption: Критерий сортировки
    func sortLists(by sortOption: SortOption)
    
    /// Обновляет список по указанному индексу
    /// - Parameter indexPath: Индекс списка задач
    func refreshList(at indexPath: IndexPath)
    
    /// Возвращает модель представления для отображения ячейки списка задач
    /// - Parameter indexPath: Индекс пути к ячейке
    /// - Returns: Экземпляр `TaskListCellViewModel`, соответствующий переданному `indexPath`
    func cellViewModel(at indexPath: IndexPath) -> TaskListCellViewModel
    
    /// Возвращает модель представления задач для конкретного списка
    /// - Parameter indexPath: Индекс списка задач
    /// - Returns: Экземпляр `TasksViewModelProtocol`, соответствующий выбранному списку
    func tasksViewModel(for indexPath: IndexPath) -> TasksViewModelProtocol
    
    /// Возвращает данные для конфигурации алерт контроллера
    /// - Parameter indexPath: Индекс списка, если редактирование. `nil` — если создание
    /// - Returns: Структура `AlertContext`, содержащая все UI-компоненты для отображения алерта
    func alertContext(for indexPath: IndexPath?) -> AlertContext
    
    func didSelectRow(at indexPath: IndexPath)
    
    func didTapAddButton()
}

/// Модель представления, инкапсулирующая бизнес-логику списка задач
final class TaskListsViewModel {

    // MARK: - Public API
    var onListsUpdated: ((ListUpdate) -> Void)?
    var onError: ((any Error) -> Void)?
    weak var output: TaskListsOutput?
    
    var numberOfLists: Int {
        taskLists.count
    }

    // MARK: - Private Properties
    private let storage: Storage
    private var taskLists: [TaskList] = []
    private let sortOptionKey = "taskListsSortOption"
    private var currentSort: SortOption = .creationDate

    // MARK: - Initialization
    /// Инициализирует ViewModel с конкретным хранилищем
    /// - Parameter storage: Экземпляр, реализующий протокол `Storage`
    init(storage: Storage) {
        self.storage = storage
        
        if let sortOption = UserDefaults.standard.string(forKey: sortOptionKey) {
            currentSort = SortOption(rawValue: sortOption) ?? .creationDate
        }
        
        loadLists()
    }
}

// MARK: - TaskListsViewModelProtocol
extension TaskListsViewModel: TaskListsViewModelProtocol {
    func createList(with title: String) {
        let taskList = TaskList(title: title)
        
        storage.create(taskList) { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success:
                let indexPath = IndexPath(row: numberOfLists, section: 0)
                taskLists.append(taskList)
                onListsUpdated?(.inserted(indexPath: indexPath))
            case .failure(let error):
                onError?(error)
            }
        }
    }
    
    func renameList(at indexPath: IndexPath, to newTitle: String) {
        var selectedTask = taskLists[indexPath.row]
        selectedTask.title = newTitle
        
        storage.update(selectedTask) { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success:
                taskLists[indexPath.row] = selectedTask
                onListsUpdated?(.reloaded(indexPath: indexPath))
            case .failure(let error):
                onError?(error)
            }
        }
    }
    
    func markListAsDone(at indexPath: IndexPath) {
        let taskList = taskLists[indexPath.row]
        
        storage.done(taskList) { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success(let updatedTaskList):
                taskLists[indexPath.row] = updatedTaskList
                onListsUpdated?(.reloaded(indexPath: indexPath))
            case .failure(let error):
                onError?(error)
            }
        }
    }
    
    func deleteList(at indexPath: IndexPath) {
        let taskList = taskLists[indexPath.row]
        
        storage.delete(taskList) { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success:
                taskLists.remove(at: indexPath.row)
                onListsUpdated?(.deleted(indexPath: indexPath))
            case .failure(let error):
                onError?(error)
            }
        }
    }
    
    func sortLists(by sortOption: SortOption) {
        currentSort = sortOption
        
        UserDefaults.standard.set(sortOption.rawValue, forKey: sortOptionKey)
        
        switch sortOption {
        case .creationDate:
            taskLists.sort { $0.creationDate < $1.creationDate }
        case .title:
            taskLists.sort { $0.title.lowercased() < $1.title.lowercased() }
        }

        onListsUpdated?(.fullReloaded)
    }
    
    func refreshList(at indexPath: IndexPath) {
        let targetID = taskLists[indexPath.row].id
        
        storage.fetchTaskLists { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success(let taskLists):
                guard let index = taskLists.firstIndex(where: { $0.id == targetID }) else { return }
                let updatedList = taskLists[index]
                
                self.taskLists[index] = updatedList
                let newIndexPath = IndexPath(row: index, section: 0)
                onListsUpdated?(.reloaded(indexPath: newIndexPath))
            case .failure(let error):
                onError?(error)
            }
        }
    }
    
    func cellViewModel(at indexPath: IndexPath) -> TaskListCellViewModel {
        TaskListCellViewModel(from: taskLists[indexPath.row])
    }
    
    func tasksViewModel(for indexPath: IndexPath) -> any TasksViewModelProtocol {
        TasksViewModel(taskList: taskLists[indexPath.row], storage: storage)
    }
    
    func alertContext(for indexPath: IndexPath?) -> AlertContext {
        if let indexPath {
            AlertContext(
                withStatus: .updateList,
                andPrefilledText: taskLists[indexPath.row].title
            )
        } else {
            AlertContext(withStatus: .createList)
        }
    }
    
    func didSelectRow(at indexPath: IndexPath) {
        let taskList = taskLists[indexPath.row]
        output?.didSelect(taskList: taskList)
    }

    func didTapAddButton() {
        output?.didTapAddList()
    }
}

// MARK: - Internal Methods
private extension TaskListsViewModel {
    func loadLists() {
        storage.fetchTaskLists { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success(let taskLists):
                self.taskLists = taskLists
                sortLists(by: currentSort)
            case .failure(let error):
                onError?(error)
            }
        }
    }
}
