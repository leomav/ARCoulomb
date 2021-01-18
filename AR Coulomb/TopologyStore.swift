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
    
    private func eraseTopology(topology: TopologyModel) {
        /// Delete topo from savedTopologies[]
        savedTopologies.removeAll { (topo) -> Bool in
            topo.id == topology.id
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
                /// Save TopologyModel to savedTopologies[]
                savedTopologies.append(newTopo)
            }
            
        } catch {
            print("No saved topologies!")
        }
    }
    
//    private func loadDefaultTopologies() {
//        for positions in defaultPositions {
//            let topo = TopologyModel(id: <SomeObjectIdentifier>, pointCharges: [], image: UIImage(named: "kobe")!, name: "Some name", description: "Some Description")
//            for pos in positions {
//                topo.addPointChargeModel(model: PointChargeModel(position: pos, value: 5))
//            }
//            savedTopologies.append(topo)
//        }
//
//    }
    
    func saveDefaultTopologiesToCoreData() {
        
        for positions in defaultPositions {
            // Save the topology
            let topology = NSTopology(context: PersistenceService.context)
            topology.name = "Default Topology"
            topology.descr = "Description"
            topology.image = UIImage(named: "kobe")?.pngData()
            PersistenceService.saveContext()
            
            // Save pointCharges info
            for pos in positions {
                let pointCharge = NSPointCharge(context: PersistenceService.context)
                pointCharge.posX = pos.x
                pointCharge.posY = pos.y
                pointCharge.posZ = pos.z
                pointCharge.multiplier = PointChargeClass.multiplier
                pointCharge.value = 5
                pointCharge.topology = topology
                PersistenceService.saveContext()
            }
        }
        
        // Reload the savedTopologies
        TopologyStore.sharedInstance.reloadTopologies()
    
    }
    func deleteDefaultTopologiesFromCoreData() {
        let fetchRequest: NSFetchRequest<NSTopology> = NSTopology.fetchRequest()
        do {
            let savedTopos = try PersistenceService.context.fetch(fetchRequest)
            
            for topo in savedTopos {
                if topo.name == "Default Topology" {
                    print("Delete that shit")
                    deleteTopologyFromCoreData(topology: topo)
                }
            }
        } catch {}
//        savedTopologies.forEach{ savedTopo in
//            if savedTopo.getName() == "Default Topology"  {
//                print("Delete that shit")
//                deleteSavedTopologyFromCoreData(topology: savedTopo)
//            }
//        }
    }
    
    func deleteTopologyFromCoreData(topology: NSTopology) {
        /// Delete the NS topo from Core Data
        PersistenceService.context.delete(topology)
        /// Save context
        PersistenceService.saveContext()
    }
    
    func deleteSavedTopologyFromCoreData(topology: TopologyModel) {
        
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
    
    }
    
    func reloadTopologies() {
        ///  First, delete previous topologies
        self.eraseTopologies()
        
        /// Load the saved ones again and reverse it so recent ones are first
        self.loadSavedTopologies()
        savedTopologies.reverse()
        
        /// Move default topologies to the end of the array[]
        /// Use tempDefault to store the defaults, the tempSaved to store the saved
        var tempDefault: [TopologyModel] = []
        var tempSaved: [TopologyModel] = []
        
        for savedTopo in savedTopologies {
            if savedTopo.name == "Default Topology" {
                tempDefault.append(savedTopo)
            } else {
                tempSaved.append(savedTopo)
            }
        }
        savedTopologies.removeAll()
        savedTopologies += tempSaved
        savedTopologies += tempDefault
//        print(savedTopologies.count)
        
        
        /// Load the default ones
//        self.loadDefaultTopologies()

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


