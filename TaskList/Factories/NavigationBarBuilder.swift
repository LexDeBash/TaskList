//
//  NavigationBarBuilder.swift
//  TaskList
//
//  Created by Alexey Efimov on 15.05.2025.
//

import UIKit

/// `NavigationBarBuilder` предоставляет пошаговое построение конфигурации для `UINavigationBar`.
/// Этот паттерн позволяет создавать сложные объекты с помощью последовательного вызова методов строителя,
/// предоставляя гибкость в конфигурировании объекта.
final class NavigationBarBuilder {
    
    private var title: String?
    private var prefersLargeTitles = true
    private var rightButtons: [UIBarButtonItem] = []
    private var leftButtons: [UIBarButtonItem] = []
    
    /// Устанавливает заголовок для `UINavigationBar`.
    /// - Parameter title: Текст заголовка, который будет отображаться на панели навигации.
    /// - Returns: Возвращает экземпляр `NavigationBarBuilder` для поддержки цепочечных вызовов.
    func setTitle(_ title: String) -> NavigationBarBuilder {
        self.title = title
        return self
    }
    
    /// Указывает, следует ли использовать большие заголовки.
    /// - Parameter prefersLargeTitles: Булево значение, указывающее, следует ли использовать большие заголовки.
    /// - Returns: Возвращает экземпляр `NavigationBarBuilder` для поддержки цепочечных вызовов.
    func setPrefersLargeTitles(_ prefersLargeTitles: Bool) -> NavigationBarBuilder {
        self.prefersLargeTitles = prefersLargeTitles
        return self
    }
    
    /// Добавляет кнопку справа на `UINavigationBar`.
    /// - Parameter button: Элемент `UIBarButtonItem`, который нужно добавить справа на панели навигации.
    /// - Returns: Возвращает экземпляр `NavigationBarBuilder` для поддержки цепочечных вызовов.
    func addRightButton(_ button: UIBarButtonItem) -> NavigationBarBuilder {
        rightButtons.append(button)
        return self
    }
    
    /// Добавляет кнопку слева на `UINavigationBar`.
    /// - Parameter button: Элемент `UIBarButtonItem`, который нужно добавить слева на панели навигации.
    /// - Returns: Возвращает экземпляр `NavigationBarBuilder` для поддержки цепочечных вызовов.
    func addLeftButton(_ button: UIBarButtonItem) -> NavigationBarBuilder {
        leftButtons.append(button)
        return self
    }
    
    /// Настраивает внешний вид и элементы `UINavigationItem` и `UINavigationBar` с использованием текущих настроек строителя.
    ///
    /// Этот метод применяет ранее установленные свойства и кнопки к переданному `navigationItem` и `navigationBar`.
    /// Он должен быть вызван внутри `UIViewController`, связанного с `UINavigationController`.
    ///
    /// - Parameters:
    ///   - navigationItem: Объект `UINavigationItem`, который нужно настроить. Обычно это `navigationItem` текущего `UIViewController`.
    ///   - navigationBar: Объект `UINavigationBar`, который нужно настроить. Обычно это `navigationBar` связанного `UINavigationController`.
    ///
    /// Пример использования:
    /// ```
    /// override func viewDidLoad() {
    ///     super.viewDidLoad()
    ///     let builder = NavigationBarBuilder()
    ///         .setTitle("My Tasks")
    ///         .addRightButton(...)
    ///         .addLeftButton(...)
    ///     builder.build(navigationItem: navigationItem, navigationBar: navigationController!.navigationBar)
    /// }
    /// ```
    ///
    /// - Important: Убедитесь, что все пользовательские цвета, такие как `UIColor.milkBlue`, определены в вашем проекте, так как это не стандартные цвета.
    ///
    /// - Note: Если `rightButtons` или `leftButtons` не установлены, соответствующие кнопки в `UINavigationItem` не будут изменены. `tintColor` применяется к `navigationBar`, чтобы определить цвет элементов управления.
    func build(with navigationItem: UINavigationItem, and navigationBar: UINavigationBar) {
        navigationItem.title = title
        navigationBar.prefersLargeTitles = prefersLargeTitles
        
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = UIColor.milkBlue
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        navigationBar.tintColor = .white
        
        if !rightButtons.isEmpty {
            navigationItem.rightBarButtonItems = rightButtons
        }
        
        if !leftButtons.isEmpty {
            navigationItem.leftBarButtonItems = leftButtons
        }
    }
}
