//
//  Coordinator.swift
//  TaskList
//
//  Created by Alexey Efimov on 06.06.2025.
//

import UIKit

/// Контракт координатора
@MainActor
protocol Coordinator: AnyObject {
    /// Root-контроллер флоу
    var navigationController: UINavigationController { get }

    /// Запуск флоу
    func start()

    /// Завершение флоу (освободить ресурсы / детей)
    func finish()
}
