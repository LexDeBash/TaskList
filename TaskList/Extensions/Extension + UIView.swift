//
//  Extension + UIViewContoller.swift
//  TaskList
//
//  Created by Alexey Efimov on 05.05.2025.
//

import UIKit

extension UIView {
    /**
     Добавляет `UIView` в указанный контейнер и активирует для него автолэйаут-констрейнты в соответствии с переданными параметрами.
     
     Метод возвращает массив созданных и активированных констрейнтов.
     Это позволяет сохранить и при необходимости изменить конкретные констрейнты (например, bottomAnchor).
     
     - Parameters:
       - item: `UIView`, к которому будут применены констрейнты.
       - container: Опциональный контейнер (`UIView`), в который будет добавлен `item`.
         Если не указан, используется `self`.
       - relativeTo: Опциональный `UIView`, относительно которого будет установлен верхний отступ.
         Если указан, верхний якорь `item` привязывается к `anchorItem.bottomAnchor`, иначе к `safeAreaLayoutGuide.topAnchor`.
       - alignToTopOf: Опциональный `UIView`, относительно которого будет установлен нижний отступ.
         Если указан, нижний якорь `item` привязывается к `anchorTopItem.topAnchor`, иначе по `bottom` к `safeAreaLayoutGuide.bottomAnchor`.
       - top: Опциональный `CGFloat` — отступ сверху.
       - leading: Опциональный `CGFloat` — отступ слева (по умолчанию 0).
       - trailing: Опциональный `CGFloat` — отступ справа (по умолчанию 0).
       - bottom: Опциональный `CGFloat` — отступ снизу (используется при отсутствии `alignToTopOf`).
       - width: Опциональный `CGFloat` — фиксированная ширина для `item`.
       - height: Опциональный `CGFloat` — фиксированная высота для `item`.
     
     - Returns: Массив `NSLayoutConstraint` — все созданные и активированные констрейнты.
     
     - Note: Установка `@discardableResult` позволяет игнорировать возвращаемое значение там,
       где оно не требуется, но сохранять при необходимости.
     */
    @discardableResult
    func applyConstraints(
        to item: UIView,
        in container: UIView? = nil,
        relativeTo anchorItem: UIView? = nil,
        alignToTopOf anchorTopItem: UIView? = nil,
        top: CGFloat? = nil,
        leading: CGFloat? = 0,
        trailing: CGFloat? = 0,
        bottom: CGFloat? = nil,
        width: CGFloat? = nil,
        height: CGFloat? = nil
    ) -> [NSLayoutConstraint] {
        // Определяем родительский контейнер
        let parentView = container ?? self
        
        // Добавляем проверку на уже существующий subview
        if !parentView.subviews.contains(item) {
            parentView.addSubview(item)
        }
        
        item.translatesAutoresizingMaskIntoConstraints = false

        var constraints: [NSLayoutConstraint] = []

        // Верхний отступ
        if let top {
            let topAnchor = anchorItem?.bottomAnchor
                ?? parentView.safeAreaLayoutGuide.topAnchor
            constraints.append(
                item.topAnchor.constraint(
                    equalTo: topAnchor,
                    constant: top
                )
            )
        }

        // Нижний отступ
        if let anchorTopItem {
            let constant = -(bottom ?? 0)
            constraints.append(
                item.bottomAnchor.constraint(
                    equalTo: anchorTopItem.topAnchor,
                    constant: constant
                )
            )
        } else if let bottom {
            constraints.append(
                item.bottomAnchor.constraint(
                    equalTo: parentView.safeAreaLayoutGuide.bottomAnchor,
                    constant: -bottom
                )
            )
        }

        // Leading / Trailing
        if let leading {
            constraints.append(
                item.leadingAnchor.constraint(
                    equalTo: parentView.layoutMarginsGuide.leadingAnchor,
                    constant: leading
                )
            )
        }
        if let trailing {
            constraints.append(
                item.trailingAnchor.constraint(
                    equalTo: parentView.layoutMarginsGuide.trailingAnchor,
                    constant: -trailing
                )
            )
        }

        // Фиксированные размеры
        if let width {
            constraints.append(
                item.widthAnchor.constraint(equalToConstant: width)
            )
        }
        if let height {
            constraints.append(
                item.heightAnchor.constraint(equalToConstant: height)
            )
        }

        NSLayoutConstraint.activate(constraints)
        return constraints
    }
}

