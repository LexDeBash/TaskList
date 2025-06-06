//
//  PersistentController.swift
//  TaskList
//
//  Created by Alexey Efimov on 19.05.2025.
//

import CoreData

final class PersistentController {
    static let shared = PersistentController()
    
    var context: NSManagedObjectContext {
        container.viewContext
    }
    
    private let container: NSPersistentContainer
    
    private init() {
        container = NSPersistentContainer(name: "TaskList")
        
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }
    
    
}
