//
//  StorageManager.swift
//  TaskList
//
//  Created by Perejro on 16/12/2024.
//

import Foundation
import CoreData

final class StorageManager {
    static let shared = StorageManager()
    static let containerName = "TaskList"
    
    private init() {}
    
    let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: StorageManager.containerName)
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    private var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    // MARK: - fetch DATA
    func fetch(completion: (Result<[ToDoTask], Error>) -> Void) {
        do {
            let list = try context.fetch(ToDoTask.fetchRequest())
            completion(.success(list))
        } catch {
            completion(.failure(error))
        }
    }
    
    // MARK: - CRUD
    func create(title: String, completion: @escaping (ToDoTask) -> Void) {
        let task = ToDoTask(context: context)
        task.title = title
        saveContext()
        completion(task)
    }
    
    func update(task: ToDoTask, title: String, completion: () -> Void) {
        task.title = title
        saveContext()
        completion()
    }
    
    func delete(task: ToDoTask, completion: () -> Void) {
        context.delete(task)
        saveContext()
        completion()
    }
}
