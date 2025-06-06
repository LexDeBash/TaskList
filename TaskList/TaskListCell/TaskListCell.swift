//
//  TaskListCell.swift
//  TaskList
//
//  Created by Alexey Efimov on 19.05.2025.
//

import UIKit

final class TaskListCell: UITableViewCell {
    private lazy var titleLabel: UILabel = {
        UILabel()
    }()
    
    private lazy var statusLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.textAlignment = .right
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with viewModel: TaskListCellViewModel) {
        titleLabel.text = viewModel.title
        statusLabel.text = viewModel.status
        accessoryType = viewModel.isCompleted ? .checkmark : .none
    }
    
    private func setupConstraints() {
        applyConstraints(to: titleLabel, in: contentView)
        applyConstraints(to: statusLabel, in: contentView)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Metrics.Cell.verticalPadding),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Metrics.Cell.verticalPadding),
            
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            statusLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
}
