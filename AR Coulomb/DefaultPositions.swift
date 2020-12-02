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

let defaultPositions: [Int: [SIMD3<Float>]] = [
    1: [SIMD3<Float>(-0.1, 0, 0), SIMD3<Float>(0.1, 0, 0)],
    2: [SIMD3<Float>(-0.1, 0, 0.1), SIMD3<Float>(0.1, 0, 0.1), SIMD3<Float>(0.1, 0, -0.1)],
    3: [SIMD3<Float>(-0.1, 0, 0.1), SIMD3<Float>(-0.1, 0, -0.1), SIMD3<Float>(0.1, 0, 0.1)],
    4: [SIMD3<Float>(-0.1, 0, 0.1), SIMD3<Float>(-0.1, 0, -0.1), SIMD3<Float>(0.1, 0, 0.1), SIMD3<Float>(0.1, 0, -0.1)],
    5: [SIMD3<Float>(-0.1, 0, 0), SIMD3<Float>(0, 0, 0), SIMD3<Float>(0.1, 0, 0)],
    6: [SIMD3<Float>(-0.2, 0, 0.1), SIMD3<Float>(0, 0, 0.1), SIMD3<Float>(0, 0, -0.1), SIMD3<Float>(0.2, 0, 0.1)]
]


class SavedTopologies {
    static let sharedInstance = SavedTopologies()
    
    /// savedTopologies:  All topologies that will be displayed in topomenu. (defaults  + saved)
    var savedTopologies: [TopologyModel] = []
    /// defaultTopos: The topologies offered by default by the app
    var defaultTopos: [TopologyModel] = []
    
    func getSize() -> Int{
        return self.savedTopologies.count
    }
    
    private func createDefaultTopologies() {
        for (indx, topo) in defaultPositions {
            
            /// Load context
            let context = PersistenceService.context
            
            /// new topo model
            let t = TopologyModel(context: context)
            t.name = "Default Topology" + String(indx)
            t.descr = "Default Topology" + String(indx)
            t.image = UIImage(named: "kobe")?.pngData()
            
            /// Add pointcharges to topo
            topo.forEach{ pos in
                let pc = PointChargeModel(context: context)
                pc.posX = pos.x
                pc.posY = pos.y
                pc.posZ = pos.z
                pc.value = 5
                pc.multiplier = 0.000001
                
                t.addToPointCharges(pc)
            }
            
            defaultTopos.append(t)
        }
    }
    
    private func revokeSavedTopologies() {
        let fetchRequest: NSFetchRequest<TopologyModel> = TopologyModel.fetchRequest()
        
        do {
            savedTopologies += try PersistenceService.context.fetch(fetchRequest)
        } catch {
            print("No saved topologies!")
        }
    }
    
    func loadTopologies() {
        self.revokeSavedTopologies()
        self.createDefaultTopologies()
        savedTopologies = defaultTopos + savedTopologies
        
        /// Most recent shown first
        savedTopologies.reverse()
        
        /// Test
        print(savedTopologies)
    }
    
    
    
}


