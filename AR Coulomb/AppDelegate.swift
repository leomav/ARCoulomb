//
//  AppDelegate.swift
//  AR Coulomb
//
//  Created by Leonidas Mavrotas on 17/6/20.
//  Copyright © 2020 Leonidas Mavrotas. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        /// First delete Default topologies, if any falsely still saved
//        let fetchRequest: NSFetchRequest<NSTopology> = NSTopology.fetchRequest()
//        do {
//            let savedTopos = try PersistenceService.context.fetch(fetchRequest)
//            for topo  in savedTopos {
//                print(topo.name)
//            }
//        } catch {}
        
        TopologyStore.sharedInstance.deleteDefaultTopologiesFromCoreData()
        PersistenceService.saveContext()
//        do {
//            let savedTopos = try PersistenceService.context.fetch(fetchRequest)
//            print("After Deletion: \(savedTopos.count)")
//        } catch {}
        /// Save the deafult topologies to Core Data
        TopologyStore.sharedInstance.saveDefaultTopologiesToCoreData()
//        do {
//            let savedTopos = try PersistenceService.context.fetch(fetchRequest)
//            print("After Save: \(savedTopos.count)")
//        } catch {}
        /// Load the default + saved Topologies into sharedInstance
        /// SharedInstance is now ready for use around the app, containing all information
        /// about topologies in a TopologyModel and PointChargeModel form.
        /// All the topologies are stored in sharedInstanc.savedTopologies
        TopologyStore.sharedInstance.reloadSavedTopologies()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        
        // Delete default topos from core data
        TopologyStore.sharedInstance.deleteDefaultTopologiesFromCoreData()
        
        // save context
        PersistenceService.saveContext()
        
    }
    
    

}

