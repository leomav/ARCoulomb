//
//  DefaultPositions.swift
//  AR Coulomb
//
//  Created by Leonidas Mavrotas on 12/7/20.
//  Copyright © 2020 Leonidas Mavrotas. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class TopologyStore {
    static let sharedInstance = TopologyStore()
    
    /// savedTopologies:  All topologies that will be displayed in topomenu. (defaults  + saved)
    var savedTopologies: [TopologyModel] = []
    
    func totalTopologies() -> Int{
        return self.savedTopologies.count
    }
    
    private func eraseTopologies() {
        self.savedTopologies.removeAll()
    }
    
    
    private func loadDefaultTopologies() {
        for positions in defaultPositions {
            let topo = TopologyModel(id: <SomeObjectIdentifier>, pointCharges: [], image: UIImage(named: "kobe")!, name: "Some name", description: "Some Description")
            for pos in positions {
                topo.addPointChargeModel(model: PointChargeModel(position: pos, value: 5))
            }
            savedTopologies.append(topo)
        }

    }
    
    private func loadSavedTopologies() {
        let fetchRequest: NSFetchRequest<NSTopology> = NSTopology.fetchRequest()
        
        do {
            /// Load saved topos from CORE DATA
            let savedTopos = try PersistenceService.context.fetch(fetchRequest)
            
            /// Convert NSTopology items to TopologyModel items
            for topo in savedTopos {
                let newTopo = TopologyModel(id: topo.id, pointCharges: [], image: UIImage(data: topo.image!)!, name: topo.name ?? "", description: topo.descr ?? "")
                for pointCharge in topo.pointCharges! {
                    let p: NSPointCharge = (pointCharge as AnyObject) as! NSPointCharge
                    let x: Float = p.posX
                    let y: Float = p.posY
                    let z: Float = p.posZ
                    let pos: SIMD3<Float> = SIMD3<Float>(x, y, z)
                    
                    let val: Float = p.value
                    
                    let newPoint = PointChargeModel(position: pos, value: val)
                    
                    newTopo.addPointChargeModel(model: newPoint)
                }
                
                savedTopologies.append(newTopo)
                
                
            }
            
        } catch {
            print("No saved topologies!")
        }
    }
    
    func saveDefaultTopologies() {
        if let capturedImage = (notification.userInfo?["imageData"] as? Data) {
            
            // TODO:  Open dialog to enter new topology's name and description
            let alertController = UIAlertController(title: "Topology Details", message: "Enter a name and a description", preferredStyle: .alert)
            
            alertController.addTextField{ (textField) in
                textField.placeholder = "Name"
            }
            
            alertController.addTextField{ (textField) in
                textField.placeholder = "Description"
            }
            
            let confirmAction = UIAlertAction(title: "OK", style: .default) { (_) in
                let name = alertController.textFields?[0].text
                let description = alertController.textFields?[1].text
                
                
                // Save the topology
                let topology = NSTopology(context: PersistenceService.context)
                topology.name = name
                topology.descr = description
                topology.image = capturedImage
                PersistenceService.saveContext()
                
                // Save pointCharges info
                self.topology.pointCharges.forEach{ pointChargeObj in
                    let pointCharge = NSPointCharge(context: PersistenceService.context)
                    pointCharge.posX = pointChargeObj.getPositionX()
                    pointCharge.posY = pointChargeObj.getPositionY()
                    pointCharge.posZ = pointChargeObj.getPositionZ()
                    pointCharge.multiplier = PointChargeClass.multiplier
                    pointCharge.value = pointChargeObj.value
                    pointCharge.topology = topology
                    PersistenceService.saveContext()
                }
                
                // Reload the savedTopologies
                TopologyStore.sharedInstance.loadTopologies()
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
            
            alertController.addAction(confirmAction)
            alertController.addAction(cancelAction)
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func deleteSavedTopology(topology: TopologyModel) {
        /// Delete topo from savedTopologies[]
        savedTopologies.removeAll { (topo) -> Bool in
            topo.id == topology.id
        }
        
        let fetchRequest: NSFetchRequest<NSTopology> = NSTopology.fetchRequest()
        
        do {
            let savedTopos = try PersistenceService.context.fetch(fetchRequest)
            
            for topo in savedTopos {
                if topology.id == topo.id {
                    /// Delete the NS topo from Core Data
                    PersistenceService.context.delete(topo)
                    /// Save context
                    PersistenceService.saveContext()
                }
            }
        } catch {
            print("No saved topologies!")
        }
        
        
//        PersistenceService.context.delete
    }
    
    func loadTopologies() {
        ///  First, delete previous topologies
        self.eraseTopologies()
        
        /// Load the saved ones again and reverse it so recent ones are first
        self.loadSavedTopologies()
        savedTopologies.reverse()
        
        /// Load the default ones
        self.loadDefaultTopologies()

        /// Now, savedTopologies contain all topologies, starting from most recent saved ones
        /// and continueing with the  default ones
    }
    
    
    
    // MARK: - Debug Print Functions
    
    func printTopology(topo: TopologyModel) {
        print("Photo: \(topo.getImage().pngData())")
        topo.pointCharges.forEach{ p in
            print("PointCharge position: \(p.getPosition()), value: \(p.value)")
        }
    }
    
    func printTopologies() {
        TopologyStore.sharedInstance.savedTopologies.forEach{ topo in
            printTopology(topo: topo)
        }
    }
    
}


