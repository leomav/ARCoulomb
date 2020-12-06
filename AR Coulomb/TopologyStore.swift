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
            let topo = TopologyModel(pointCharges: [], image: UIImage(named: "kobe")!)
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
                let newTopo = TopologyModel(pointCharges: [], image: UIImage(data: topo.image!)!)
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


