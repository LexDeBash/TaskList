//
//  TaskEditorViewModel.swift
//  TaskList
//
//  Created by Alexey Efimov on 26.05.2025.
//

import Foundation

/// Интерфейс взаимодействия TaskEditorViewController с моделью представления
/// Отвечает за хранение пользовательского ввода и валидацию данных.
protocol TaskEditorViewModelProtocol {
    
    /// Режим экрана: создание или редактирование
    var isEditingMode: Bool { get }
    
    /// Заголовок задачи
    var title: String { get }

    /// Заметка к задаче
    var note: String? { get }

    /// Дата завершения
    var dueDate: Date { get }

    /// Статус выполнения задачи
    var isComplete: Bool { get }
    
    /// Флаг, указывающий, должна ли быть активна кнопка сохранения.
    /// Кнопка доступна, только если поле `title` не пустое.
    var isButtonEnabled: Bool { get }
    
    /// Заголовок кнопки сохранения
    var saveButtonTitle: String { get }
    
    /// Плейсхолдер для текстового поля
    var textFieldPlaceholder: String { get }
    
    /// Заголовок сегмента, опредяющий статус задачи
    var segmentItems: [String] { get }
    
    /// Индекс выбранного сегмента, отвечающего за статус задачи
    var selectedSegmentIndex: Int { get }
    
    /// Замыкание, вызываемое при изменении состояния формы (например, активности кнопки).
    var onFormStateChanged: (() -> Void)? { get set }

    /// Обновляет заголовок задачи.
    /// - Parameter value: Новый текст.
    func updateTitle(to value: String)

    /// Обновляет описание задачи.
    /// - Parameter value: Новый текст.
    func updateNote(to value: String?)

    /// Обновляет дату завершения задачи.
    /// - Parameter date: Новая дата.
    func updateDueDate(to date: Date)

    /// Обновляет флаг завершения задачи.
    /// - Parameter value: Новое значение.
    func updateCompletionState(to value: Bool)

    /// Возвращает собранную модель `TaskInput`.
    /// - Returns: Готовая структура `TaskInput`.
    func makeTaskInput() -> TaskInput
}

/// Модель представления для экрана редактирования задачи
final class TaskEditorViewModel: TaskEditorViewModelProtocol {
    
    let isEditingMode: Bool
    
    var title = "" {
        didSet {
            onFormStateChanged?()
        }
    }
    
    var note: String?
    var dueDate: Date
    var isComplete: Bool
    
    var isButtonEnabled: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var saveButtonTitle: String {
        isEditingMode ? "Update Task" : "Save Task"
    }
    
    var textFieldPlaceholder: String {
        isEditingMode ? "Editable Task" : "New Task"
    }
    
    var segmentItems: [String] {
        [
            "In Progress",
            "Completed"
        ]
    }
    
    var selectedSegmentIndex: Int {
        isComplete ? 1 : 0
    }
    
    var onFormStateChanged: (() -> Void)?
    
    init(input: TaskInput? = nil) {
        isEditingMode = (input != nil)
        title = input?.title ?? ""
        note = input?.note
        dueDate = input?.dueDate ?? Date()
        isComplete = input?.isComplete ?? false
    }

    func updateTitle(to value: String) {
        title = value
    }

    func updateNote(to value: String?) {
        note = value
    }

    func updateDueDate(to date: Date) {
        dueDate = date
    }

    func updateCompletionState(to value: Bool) {
        isComplete = value
    }

    func makeTaskInput() -> TaskInput {
        TaskInput(
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            note: note?.trimmingCharacters(in: .whitespacesAndNewlines),
            dueDate: dueDate,
            isComplete: isComplete
        )
    }
}

