//
//  ViewController.swift
//  TaskList
//
//  Created by Alexey Efimov on 28.03.2024.
//

import UIKit

final class TaskListViewController: UITableViewController {
    private var taskList: [ToDoTask] = []
    private let cellID = "task"
    private let storage = StorageManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupNavigationBar()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        fetchTasks()
    }
    
    private func fetchTasks() {
        storage.fetch() { [unowned self] result in
            switch result {
            case .success(let tasks):
                taskList = tasks
            case .failure(_):
                taskList = []
            }
            
            tableView.reloadData()
        }
    }
    
    @objc private func addNewTask() {
        showAlert(
            title: "New Task",
            description: "What do you want to do?",
            type: .create,
            value: nil,
            completion: { [unowned self] value in
                guard let value else { return }
                save(value)
            }
        )
    }
    
    // MARK: - CRUD methods
    private func save(_ taskName: String) {
        storage.create(title: taskName) { [unowned self] task in
            taskList.append(task)
            let indexPath = IndexPath(row: taskList.count - 1, section: 0)
            tableView.insertRows(at: [indexPath], with: .automatic)
            tableView.scrollToRow(at: indexPath, at: .top, animated: true)
        }

    }
    
    private func update(at taskIndex: IndexPath, newTitle: String) {
        let task = taskList[taskIndex.row]
        
        storage.update(task: task, title: newTitle) { [unowned self] in
            tableView.reloadRows(at: [taskIndex], with: .automatic)
        }
        
    }
    
    private func delete(at taskIndex: IndexPath) {
        let task = taskList[taskIndex.row]
    
        storage.delete(task: task) { [unowned self] in
            taskList.remove(at: taskIndex.row)
            tableView.deleteRows(at: [taskIndex], with: .automatic)
            tableView.reloadRows(at: [taskIndex], with: .automatic)
        }

    }
}

// MARK: - Alert flow
private extension TaskListViewController {
    func showAlert(
        title: String,
        description: String?,
        type: AlertType,
        value: String?,
        completion: @escaping (String?) -> Void
    ) {
        let factory = AlertControllerFactory(
            title: title,
            description: description,
            type: type,
            value: value
        )

        let alert = factory.createAlertController(completion: { value in
             completion(value)
         })
        
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension TaskListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        taskList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        let task = taskList[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = task.title
        cell.contentConfiguration = content
        return cell
    }
}


// MARK: - UITableViewDelegate
extension TaskListViewController {
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            delete(at: indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let task = taskList[indexPath.row]
        
        showAlert(
            title: "Edit",
            description: nil,
            type: .update,
            value: task.title,
            completion: {[unowned self]  value in
                guard let value else { return }
                
                update(at: indexPath, newTitle: value)
            }
        )
    }
}

// MARK: - Setup UI
private extension TaskListViewController {
    func setupNavigationBar() {
        title = "Task List"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.backgroundColor = .milkBlue
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addNewTask)
        )
        
        navigationController?.navigationBar.tintColor = .white
    }
}
