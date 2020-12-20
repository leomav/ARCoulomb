//
//  Topology.swift
//  AR Coulomb
//
//  Created by Leonidas Mavrotas on 24/8/20.
//  Copyright © 2020 Leonidas Mavrotas. All rights reserved.
//

import UIKit
import ARKit
import RealityKit

class Topology {
    
    /// The ViewController which contains the topology
    var viewController: ViewController?
    /// Anchor of the topology in the scene
    var topoAnchor: ARAnchor?
    /// Anchor Entity of the topology
    var topoAnchorEntity: AnchorEntity?
    /// Selected positions for the pointCharges Entities
    var selectedPositions: [SIMD3<Float>]
    /// All the pointCharge Objects
    var pointCharges: [PointChargeClass]
    /// All the netForces
    var netForces: [NetForce]
    /// A pointChargeEntity Template used for cloning
    var pointChargeEntityTemplate: Entity?
    
    init() {
//        self.viewController = viewController
//        self.topoAnchor = topoAnchor
        self.selectedPositions = []
        self.pointCharges = []
        self.netForces = []
        
        /// Import the Point Charge Model, clone the entity as many times as needed
//        let pointChargeAnchor = try! PointCharge.load_PointCharge()
//        self.pointChargeEntityTemplate = pointChargeAnchor.pointCharge!
        
        //  TEST: New way to load pointCharge
        self.pointChargeEntityTemplate = EntityStore.shared.load_PointChargeEntity()
        
        print(self.pointChargeEntityTemplate?.components)
    }
    
    // MARK: - Topology functions
    
    //  Add the parent viewController and a ARAnchor
    func pinToScene(viewController: ViewController, topoAnchor: ARAnchor) {
        self.viewController = viewController
        self.topoAnchor = topoAnchor
        
        /// Add the Anchor Entity to the scene (where the user tapped)
        self.topoAnchorEntity = AnchorEntity(anchor: topoAnchor)
        self.topoAnchorEntity?.name = "Point Charge Scene AnchorEntity"
        self.viewController?.arView.scene.addAnchor(self.topoAnchorEntity!)
        
        /// Create the Coulomb's Observers (value change or deletion)
        self.viewController?.createCbObserver()
        self.viewController?.setupObserverPointChargeDeletion()
    }
    
    func placeTopology(topoModel: TopologyModel) {
//    func placeTopology(positions: [SIMD3<Float>]) {
        /// Clear the topology, if there was one
        self.clearTopology()
        
        /// Set new selectedPositions
        self.selectedPositions = {
            var positions: [SIMD3<Float>] = []
            topoModel.pointCharges.forEach{ p in
                positions.append(p.position)
            }
            return positions
        }()
        
        /// Create PointCharges in the selected Positions
        for pointChargeModel in topoModel.pointCharges {
//        for pos in self.selectedPositions {
            self.add(pointCharge: pointChargeModel)
//            self.addPointCharge(to: pos)
        }
        
        /// Add all forces to all the pointCharge Objects
        self.reloadAllForces()
        
        
        self.showForces(for: selectedPointChargeObj)
        
        
    }
    
    func clearTopology() {
        /// Clear all Forces
        self.clearAllForces()
        
        /// Clear all PointCharges
        self.removeAllPointCharges()
        
        /// Clear selectedPositions
        self.selectedPositions.removeAll()
        
        /// Set selected objects to none
        longPressedEntity = Entity()
        trackedEntity = Entity()
        selectedPointChargeObj = PointChargeClass(onEntity: Entity(), withValue: 0)
    }
    
    // Show or Hide topology
    func toggleTopology(show: Bool) {
        self.toggleAllForces(show: show)
        self.toggleAllForces(show: show)
    }
    
}
