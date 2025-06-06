//
//  ViewController.swift
//  TaskList
//
//  Created by Alexey Efimov on 05.05.2025.
//

import UIKit

final class TasksViewController: UITableViewController {
    
    // MARK: - Private Properties
    private var viewModel: TasksViewModelProtocol
    private let onTaskSaved: () -> Void
    
    // MARK: - Initializers
    init(viewModel: TasksViewModelProtocol, onTaskSaved: @escaping () -> Void) {
        self.viewModel = viewModel
        self.onTaskSaved = onTaskSaved
        super.init(style: .plain)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = .systemBackground
        
        tableView.register(
            UITableViewCell.self,
            forCellReuseIdentifier: UITableViewCell.reuseIdentifier
        )
        
        setupNavigationBar()
        bindViewModel()
    }
}

// MARK: - UITableViewDataSource
extension TasksViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfTasks
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: UITableViewCell.reuseIdentifier,
            for: indexPath
        )
        
        let cellViewModel = viewModel.cellViewModel(at: indexPath)
        
        var content = cell.defaultContentConfiguration()
        content.attributedText = cellViewModel.attributedTitle
        content.secondaryAttributedText = cellViewModel.attributedNote

        cell.contentConfiguration = content
        return cell
    }
}

// MARK: - UITableViewDelegate
extension TasksViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let taskEditorVM = viewModel.taskEditorViewModel(at: indexPath)
        
        let taskEditorVC = TaskEditorViewController(viewModel: taskEditorVM) { [weak self] input in
            guard let self else { return }
            viewModel.updateTask(at: indexPath, with: input)
            onTaskSaved()
        }
        
        present(taskEditorVC, animated: true)
    }
    
    override func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        let actionsConfiguration = SwipeActionsBuilder()
            .addAction(
                title: "Done",
                style: .normal,
                imageName: "checkmark",
                backgroundColor: .systemGreen
            ) { [weak self] in
                guard let self else { return }
                viewModel.markTaskAsComplete(at: indexPath)
                onTaskSaved()
            }
            .addAction(
                title: "Delete",
                style: .destructive,
                imageName: "trash"
            ) { [weak self] in
                guard let self else { return }
                viewModel.deleteTask(at: indexPath)
                onTaskSaved()
            }
            .build()
        
        return actionsConfiguration
    }
}

// MARK: - Setup UI
private extension TasksViewController {
    func setupNavigationBar() {
        guard let navigationBar = navigationController?.navigationBar else { return }
        
        NavigationBarBuilder()
            .setTitle(viewModel.taskListTitle)
            .addRightButton(
                UIBarButtonItem(
                    barButtonSystemItem: .add,
                    target: self,
                    action: #selector(addTask)
                )
            )
            .addRightButton(editButtonItem)
            .build(with: navigationItem, and: navigationBar)
    }
    
    func updateVisibleCell(at indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        let viewModel = viewModel.cellViewModel(at: indexPath)
        
        var content = cell.defaultContentConfiguration()
        content.attributedText = viewModel.attributedTitle
        
        cell.contentConfiguration = content
    }
    
    func showAlert(withTitle title: String, andMessage message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        
        alert.addAction(okAction)
        present(alert, animated: true)
    }
}

// MARK: - Actions
private extension TasksViewController {
    @objc func addTask() {
        let taskEditorVM = viewModel.taskEditorViewModel(at: nil)
        
        let taskEditorVC = TaskEditorViewController(
            viewModel: taskEditorVM,
        ) { [weak self] input in
            guard let self else { return }
            viewModel.createTask(from: input)
        }
        
        present(taskEditorVC, animated: true)
    }
}

// MARK: - Internal Methods
private extension TasksViewController {
    func bindViewModel() {
        viewModel.onTasksChanged = { [weak self] update in
            guard let self else { return }
            
            switch update {
            case .inserted(indexPath: let indexPath):
                tableView.insertRows(at: [indexPath], with: .automatic)
            case .deleted(indexPath: let indexPath):
                tableView.deleteRows(at: [indexPath], with: .automatic)
            case .reloaded(indexPath: let indexPath):
                tableView.reloadRows(at: [indexPath], with: .automatic)
            case .moved(let oldIndexPath, let newIndexPath):
                tableView.moveRow(at: oldIndexPath, to: newIndexPath)
                updateVisibleCell(at: newIndexPath)
            case .fullReloaded:
                tableView.reloadData()
            }
        }
        
        viewModel.onError = { [weak self] error in
            self?.showAlert(withTitle: "Error", andMessage: error.localizedDescription)
        }
    }
}
