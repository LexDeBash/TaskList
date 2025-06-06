//
//  TaskListsViewController.swift
//  TaskList
//
//  Created by Alexey Efimov on 15.05.2025.
//

import UIKit

final class TaskListsViewController: UITableViewController {
   
    private let viewModel: TaskListsViewModelProtocol
    
    // MARK: - Initializers
    init(viewModel: TaskListsViewModelProtocol) {
        self.viewModel = viewModel
        super.init(style: .plain)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(
            TaskListCell.self,
            forCellReuseIdentifier: TaskListCell.reuseIdentifier
        )
        
        setupNavigationBar()
        setupSegmentedControl()
        bindViewModel()
    }
}

// MARK: - UITableViewDataSource
extension TaskListsViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfLists
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: TaskListCell.reuseIdentifier,
            for: indexPath
        )
        
        guard let cell = cell as? TaskListCell else { return UITableViewCell() }
        
        let cellViewModel = viewModel.cellViewModel(at: indexPath)
        cell.configure(with: cellViewModel)
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension TaskListsViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.didSelectRow(at: indexPath)
        tableView.deselectRow(at: indexPath, animated: false)
        /*
        let tasksViewModel = viewModel.tasksViewModel(for: indexPath)
        let tasksVC = TasksViewController(viewModel: tasksViewModel) { [weak self] in
            guard let self else { return }
            viewModel.refreshList(at: indexPath)
        }
        
        navigationController?.pushViewController(tasksVC, animated: true)
        */
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
                viewModel.markListAsDone(at: indexPath)
            }
            .addAction(
                title: "Edit",
                style: .normal,
                imageName: "pencil",
                backgroundColor: .systemOrange
            ) { [weak self] in
                guard let self else { return }
                showAlert(at: indexPath)
            }
            .addAction(
                title: "Delete",
                style: .destructive,
                imageName: "trash",
                shouldComplete: false
            ) { [weak self] in
                guard let self else { return }
                viewModel.deleteList(at: indexPath)
            }
            .build()
        
        return actionsConfiguration
    }
}

// MARK: - Setup UI
private extension TaskListsViewController {
    func setupNavigationBar() {
        guard let navigationBar = navigationController?.navigationBar else { return }
        
        NavigationBarBuilder()
            .setTitle("Task Lists")
            .addRightButton(
                UIBarButtonItem(
                    barButtonSystemItem: .add,
                    target: self,
                    action: #selector(addTaskList)
                )
            )
            .addLeftButton(editButtonItem)
            .build(with: navigationItem, and: navigationBar)
    }
    
    func setupSegmentedControl() {
        let segmentedControl = UISegmentedControl(items: ["Date", "A-Z"])
        segmentedControl.selectedSegmentIndex = 0
        
        segmentedControl.frame = CGRect(
            x: .zero,
            y: .zero,
            width: tableView.frame.width,
            height: Metrics.VSpacing.large
        )
        
        segmentedControl.addTarget(
            self,
            action: #selector(sortChanged),
            for: .valueChanged
        )
        
        tableView.tableHeaderView = segmentedControl
    }
    
    func showAlert(at indexPath: IndexPath? = nil) {
        let alertContext = viewModel.alertContext(for: indexPath)
        
        let alert = UIAlertController(
            title: alertContext.title,
            message: alertContext.message,
            preferredStyle: .alert
        )
        
        let okAction = UIAlertAction(
            title: alertContext.buttonTitle,
            style: .default
        ) { [weak self] _ in
            guard let self else { return }
            guard let inputText = alert.textFields?.first?.text else { return }
            guard !inputText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
            
            if let indexPath {
                viewModel.renameList(at: indexPath, to: inputText)
            } else {
                viewModel.createList(with: inputText)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        
        alert.addTextField { textField in
            textField.placeholder = alertContext.placeholder
            textField.text = alertContext.prefilledText
        }
        
        present(alert, animated: true)
    }
    
    func showUnavailableMessage(_ text: String) {
        var config = UIContentUnavailableConfiguration.empty()
        config.text = text
        config.textProperties.font = .boldSystemFont(ofSize: 20)
        contentUnavailableConfiguration = config
    }
}

// MARK: - Actions
private extension TaskListsViewController {
    @objc func addTaskList() {
        viewModel.didTapAddButton()
//        showAlert()
    }
    
    @objc func sortChanged(_ sender: UISegmentedControl) {
        sender.selectedSegmentIndex == 0
            ? viewModel.sortLists(by: .creationDate)
            : viewModel.sortLists(by: .title)
    }
}

// MARK: - Internals Methods
private extension TaskListsViewController {
    func bindViewModel() {
        viewModel.onListsUpdated = { [weak self] update in
            guard let self else { return }
            
            switch update {
            case .inserted(indexPath: let indexPath):
                tableView.insertRows(at: [indexPath], with: .automatic)
            case .deleted(indexPath: let indexPath):
                tableView.deleteRows(at: [indexPath], with: .automatic)
            case .reloaded(indexPath: let indexPath):
                tableView.reloadRows(at: [indexPath], with: .automatic)
            case .fullReloaded:
                tableView.reloadData()
            default:
                break
            }
        }
        
        viewModel.onError = { [weak self] error in
            self?.showUnavailableMessage(error.localizedDescription)
        }
    }
}
