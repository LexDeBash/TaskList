//
//  SwipeActionsBuilder.swift
//  ToDoManager
//
//  Created by Alexey Efimov on 19.03.2025.
//

import UIKit

/// Класс-строитель для создания `UISwipeActionsConfiguration`.
/// - Примечание: Использует **флюентный интерфейс**, позволяя вызывать методы цепочкой.
final class SwipeActionsBuilder {
    /// Массив действий, добавленных в конфигурацию свайпа.
    private var actions: [UIContextualAction] = []

    /// Добавляет новое действие в конфигурацию.
    /// - Параметры:
    ///   - title: Заголовок действия. Если задан `imageName`, заголовок будет скрыт.
    ///   - style: Стиль действия (`.normal` или `.destructive`).
    ///   - imageName: Имя системного изображения для иконки. Если `nil`, используется только текст.
    ///   - backgroundColor: Фон кнопки. По умолчанию `nil`, тогда применяется системный цвет.
    ///   - shouldComplete: Нужно ли автоматически скрывать кнопку после выполнения (`isDone(true)`). По умолчанию `true`.
    ///   - completion: Замыкание, выполняемое при выборе действия.
    /// - Возвращает: Экземпляр `SwipeActionsBuilder`, позволяя вызывать методы цепочкой.
    func addAction(
        title: String?,
        style: UIContextualAction.Style,
        imageName: String?,
        backgroundColor: UIColor? = nil,
        shouldComplete: Bool = true,
        completion: @escaping () -> Void
    ) -> SwipeActionsBuilder {
        let action = UIContextualAction(
            style: style,
            title: imageName == nil ? title : nil
        ) { _, _, isDone in
            completion()
            
            if shouldComplete {
                isDone(true)
            }
        }
        
        if let imageName {
            action.image = makeIcon(imageName)
        }
        action.backgroundColor = backgroundColor
        actions.append(action)
        return self
    }

    /// Создаёт `UISwipeActionsConfiguration` с добавленными действиями.
    /// - Возвращает: `UISwipeActionsConfiguration`, содержащий все добавленные действия.
    func build() -> UISwipeActionsConfiguration {
        UISwipeActionsConfiguration(actions: actions)
    }

    private func makeIcon(_ name: String) -> UIImage? {
        let config = UIImage.SymbolConfiguration(weight: .heavy)
        return UIImage(systemName: name, withConfiguration: config)
    }
}
