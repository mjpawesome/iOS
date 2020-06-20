//
//  CoreDataManager.swift
//  WaterMyPlants
//
//  Created by Shawn James on 6/19/20.
//  Copyright © 2020 Shawn James. All rights reserved.
//

import Foundation
import CoreData

/// Used to manage CoreData objects
class CoreDataManager {
    
    // create singleton
    static let shared = CoreDataManager()
    
    // create container
    lazy var container: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "WaterMyPlants")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Failed loading persistent stores: \(error)")
            }
        }
        return container
    }()
    
    // create context -> everything done in the app uses the context
    var mainContext: NSManagedObjectContext {
        container.viewContext
    }
    
    func save(context: NSManagedObjectContext = CoreDataManager.shared.mainContext) throws {
        var saveError: Error?
        context.performAndWait {
            do {
                try context.save()
            } catch {
                context.reset()
                saveError = error
            }
        }
        if let error = saveError {throw error}
    }
}
