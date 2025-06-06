//
//  FilledButton.swift
//  TaskList
//
//  Created by Alexey Efimov on 05.05.2025.
//

import UIKit

/// Простая фабрика для создания кнопок с конфигурацией `.filled()`.
enum FilledButton {
    
    /// Создаёт кнопку с заданным заголовком, цветом фона и действием.
    ///
    /// - Parameters:
    ///   - title: Текст заголовка кнопки.
    ///   - color: Цвет фона кнопки.
    ///   - action: Объект `UIAction`, выполняемый при нажатии.
    ///
    /// - Returns: Сконфигурированный экземпляр `UIButton`.
    static func make(title: String, color: UIColor, action: UIAction) -> UIButton {
        // Задаём атрибуты шрифта для заголовка
        var attributes = AttributeContainer()
        attributes.font = UIFont.boldSystemFont(ofSize: 18)

        // Конфигурация кнопки с заливкой
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = color
        config.attributedTitle = AttributedString(title, attributes: attributes)

        // Создаём кнопку с конфигурацией и действием
        let button = UIButton(configuration: config, primaryAction: action)
        button.translatesAutoresizingMaskIntoConstraints = false

        return button
    }
}
