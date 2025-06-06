//
//  TaskEditorViewController.swift
//  TaskList
//
//  Created by Alexey Efimov on 05.05.2025.
//

import UIKit

final class TaskEditorViewController: UIViewController {
    
    // MARK: - UI Elements
    private lazy var taskTextField = makeTextField(
        withPlaceholder: viewModel.textFieldPlaceholder,
        andText: viewModel.title
    )
    private lazy var noteTextView = makeTextView(withText: viewModel.note)
    private lazy var dueDatePicker = makeDatePicker(withDate: viewModel.dueDate)
    
    private lazy var statusSegmentedControl = makeSegmentedControl(
        withItems: viewModel.segmentItems,
        andSelectedSegment: viewModel.selectedSegmentIndex
    )
    
    private lazy var saveButton: UIButton = {
        let button = FilledButton.make(
            title: viewModel.saveButtonTitle,
            color: .milkBlue,
            action: UIAction { [weak self] _ in
                guard let self else { return }
                let input = viewModel.makeTaskInput()
                onSave(input)
                dismiss(animated: true)
            }
        )
        
        button.isEnabled = viewModel.isButtonEnabled
        return button
    }()
    
    private lazy var cancelButton = FilledButton.make(
        title: "Cancel",
        color: .milkRed,
        action: UIAction { [weak self] _ in
            guard let self else { return }
            dismiss(animated: true)
        }
    )
    
    // MARK: - Private Properties
    private var cancelButtonBottomConstraint: NSLayoutConstraint!
    
    private var viewModel: TaskEditorViewModelProtocol
    private let onSave: (TaskInput) -> Void

    
    // MARK: - Initializers
    init(
        viewModel: TaskEditorViewModelProtocol,
        onSave: @escaping (TaskInput) -> Void
    ) {
        self.viewModel = viewModel
        self.onSave = onSave
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        taskTextField.delegate = self
        
        setConstraints()
        
        viewModel.onFormStateChanged = { [weak self] in
            guard let self else { return }
            saveButton.isEnabled = viewModel.isButtonEnabled
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        taskTextField.becomeFirstResponder()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
}

// MARK: - UITextFieldDelegate
extension TaskEditorViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
}

// MARK: - UITextViewDelegate
extension TaskEditorViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        viewModel.updateNote(to: textView.text)
    }
}

// MARK: - Setup UI
private extension TaskEditorViewController {
    func setConstraints() {
        view.applyConstraints(
            to: taskTextField,
            top: Metrics.VSpacing.large
        )
        
        view.applyConstraints(
            to: noteTextView,
            relativeTo: taskTextField,
            top: Metrics.VSpacing.medium,
            height: Metrics.NoteTextView.height
        )
        
        view.applyConstraints(
            to: dueDatePicker,
            relativeTo: noteTextView,
            top: Metrics.VSpacing.medium
        )
        
        view.applyConstraints(
            to: statusSegmentedControl,
            relativeTo: dueDatePicker,
            top: Metrics.VSpacing.medium
        )
        
        // Добавляем cancelButton и сохраняем все его констрейнты
        let cancelConstraints = view.applyConstraints(
            to: cancelButton,
            bottom: 100
        )
        
        // Находим среди них нижний констрейнт
        cancelButtonBottomConstraint = cancelConstraints.first { constraint in
            constraint.firstItem as? UIView == cancelButton &&
            constraint.firstAttribute == .bottom &&
            constraint.relation == .equal
        }
        
        // Отступ для saveButton относительно cancelButton
        view.applyConstraints(
            to: saveButton,
            alignToTopOf: cancelButton,
            bottom: Metrics.VSpacing.small
        )
    }
}

// MARK: - UI Factory
private extension TaskEditorViewController {
    func makeTextField(withPlaceholder placeholder: String, andText text: String) -> UITextField {
        let textField = UITextField()
        textField.placeholder = placeholder
        textField.text = text
        textField.borderStyle = .roundedRect
        
        textField.addTarget(
            self,
            action: #selector(titleChanged),
            for: .editingChanged
        )
        
        return textField
    }
    
    func makeTextView(withText text: String?) -> UITextView {
        let textView = UITextView()
        textView.delegate = self
        textView.applyNoteStyle()
        textView.text = text
        return textView
    }
    
    func makeDatePicker(withDate date: Date) -> UIDatePicker {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.date = date
        
        datePicker.addTarget(
            self,
            action: #selector(dueDateChanged),
            for: .valueChanged
        )
        
        return datePicker
    }
    
    func makeSegmentedControl(withItems items: [String], andSelectedSegment index: Int) -> UISegmentedControl {
        let segmentedControl = UISegmentedControl(items: items)
        segmentedControl.selectedSegmentIndex = index
        
        segmentedControl.addTarget(
            self,
            action: #selector(statusChanged),
            for: .valueChanged
        )
        
        return segmentedControl
    }
}

// MARK: - Keyboard Handling
private extension TaskEditorViewController {
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey]
        guard let keyboardFrame = (keyboardFrame as? NSValue)?.cgRectValue else { return }
        
        let offset = keyboardFrame.height - Metrics.VSpacing.keyboardOffset

        UIView.animate(withDuration: Metrics.Animation.keyboardDuration) { [weak self] in
            guard let self else { return }
            cancelButtonBottomConstraint.constant = -offset
            view.layoutIfNeeded()
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        UIView.animate(withDuration: Metrics.Animation.keyboardDuration) { [weak self] in
            guard let self else { return }
            cancelButtonBottomConstraint.constant = -Metrics.VSpacing.medium
            view.layoutIfNeeded()
        }
    }
}

// MARK: - Actions
private extension TaskEditorViewController {
    @objc func titleChanged(_ sender: UITextField) {
        viewModel.updateTitle(to: sender.text ?? "")
    }

    @objc func dueDateChanged(_ sender: UIDatePicker) {
        viewModel.updateDueDate(to: sender.date)
    }

    @objc func statusChanged(_ sender: UISegmentedControl) {
        viewModel.updateCompletionState(to: sender.selectedSegmentIndex == 1)
    }
}

private extension UITextView {
    func applyNoteStyle() {
        layer.borderColor = UIColor.gray.cgColor
        layer.borderWidth = Metrics.NoteTextView.borderWidth
        layer.cornerRadius = Metrics.NoteTextView.cornerRadius
        backgroundColor = UIColor(
            white: Metrics.NoteTextView.backgroundWhite,
            alpha: Metrics.NoteTextView.alpha
        )
    }
}

final class PreviewTaskEditorViewModel: TaskEditorViewModelProtocol {
    var segmentItems: [String] = ["In Progress", "Completed"]
    var textFieldPlaceholder: String = ""
    var isEditingMode: Bool = false
    var saveButtonTitle: String = ""
    var title = ""
    var note: String?
    var dueDate = Date()
    var isComplete = false
    var isButtonEnabled = false
    var selectedSegmentIndex: Int = 0
    var onFormStateChanged: (() -> Void)?
    func updateTitle(to value: String) {}
    func updateNote(to value: String?) {}
    func updateDueDate(to date: Date) {}
    func updateCompletionState(to value: Bool) {}
    func makeTaskInput() -> TaskInput {
        TaskInput(title: "", note: nil, dueDate: nil, isComplete: false)
    }
}

#Preview {
    TaskEditorViewController(
        viewModel: PreviewTaskEditorViewModel(),
        onSave: {_ in }
    )
}

