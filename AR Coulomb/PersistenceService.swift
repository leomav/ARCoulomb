//
//  PersistenceService.swift
//  AR Coulomb
//
//  Created by Leonidas Mavrotas on 27/11/20.
//  Copyright © 2020 Leonidas Mavrotas. All rights reserved.
//

import Foundation
import CoreData

class PersistenceService {
    
    // Disable initialization
    private init(){}
    
    // The container which contains all the data we want to save
    static var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    static var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Topologies")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    static func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                print("context: saved")
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}


