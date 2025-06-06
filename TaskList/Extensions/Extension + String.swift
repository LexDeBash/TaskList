//
//  Extension + String.swift
//  TaskList
//
//  Created by Alexey Efimov on 26.05.2025.
//

import UIKit

extension String {
    func strikeThrough(_ isStrikeThrough: Bool) -> NSAttributedString {
        let attributes: [NSAttributedString.Key: Any] = [
            .strikethroughStyle: isStrikeThrough ? NSUnderlineStyle.double.rawValue : 0
        ]
        return NSAttributedString(string: self, attributes: attributes)
    }
}
