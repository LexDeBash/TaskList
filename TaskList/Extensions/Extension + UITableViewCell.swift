//
//  Extension + UITableViewCell.swift
//  TaskList
//
//  Created by Alexey Efimov on 26.05.2025.
//

import UIKit

extension UITableViewCell {
    static var reuseIdentifier: String {
        String(describing: self)
    }
}
