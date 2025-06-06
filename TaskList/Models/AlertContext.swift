//
//  AlertContext.swift
//  TaskList
//
//  Created by Alexey Efimov on 26.05.2025.
//

import Foundation

/// Перечисление, представляющее статус оповещения для управления списками задач.
enum AlertStatus {
    /// Статус для создания нового списка задач.
    case createList
    
    /// Статус для редактирования существующего списка задач.
    case updateList
    
    /// Заголовок оповещения в зависимости от статуса.
    var title: String {
        switch self {
        case .createList:
            "New List"
        case .updateList:
            "Edit List"
        }
    }
    
    /// Сообщение оповещения в зависимости от статуса.
    var message: String {
        switch self {
        case .createList:
            "Please set title for the task list"
        case .updateList:
            "Update title for the list"
        }
    }
    
    /// Заголовок кнопки действия в зависимости от статуса.
    var buttonTitle: String {
        switch self {
        case .createList:
            "Create"
        case .updateList:
            "Update"
        }
    }
}

/// Контекст отображения алерта для создания или редактирования списка задач
struct AlertContext {
    /// Заголовок алерта
    let title: String
    
    /// Сообщение под заголовком
    let message: String
    
    /// Название кнопки подтверждения
    let buttonTitle: String
    
    /// Плейсхолдер для текстового поля
    let placeholder: String
    
    /// Предзаполненный текст в поле (если есть)
    let prefilledText: String?
    
    init(withStatus alertStatus: AlertStatus, placeholder: String = "Title", andPrefilledText prefilledText: String? = nil) {
        title = alertStatus.title
        message = alertStatus.message
        buttonTitle = alertStatus.buttonTitle
        self.placeholder = placeholder
        self.prefilledText = prefilledText
    }
}
