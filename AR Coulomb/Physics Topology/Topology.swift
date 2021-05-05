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
    /// Anchor Entity of the topology
    var topoAnchorEntity: AnchorEntity = AnchorEntity()
    /// Selected positions for the pointCharges Entities
    var selectedPositions: [SIMD3<Float>]
    /// All the pointCharge Objects
    var pointCharges: [PointChargeClass]
    /// All the netForces
    var netForces: [NetForce]
    /// All Forces
    var forces: [Force]
    /// All distance indicators
    var distanceIndicators: [DistanceIndicator]
    /// All Label Entities
    var labels: [Entity]
    /// A pointChargeEntity Template used for cloning
    var pointChargeEntityTemplate: Entity?
    
    init() {
        self.selectedPositions = []
        self.pointCharges = []
        self.netForces = []
        self.forces = []
        self.distanceIndicators = []
        self.labels = []
        
        /// Import the Point Charge Model, clone the entity as many times as needed
        self.pointChargeEntityTemplate = EntityStore.shared.load_PointCharge()
    }
    
    // MARK: - Topology functions
    
    //  Add the parent viewController and a ARAnchorEntity
    func pinToScene(viewController: ViewController, topoAnchor: AnchorEntity) {
        self.viewController = viewController
        
        /// Add the Anchor Entity to the scene (where the user tapped)
        self.topoAnchorEntity = topoAnchor
        self.viewController?.arView.scene.addAnchor(self.topoAnchorEntity)

        /// Create the Coulomb's Observers (value change or deletion)
        self.viewController?.setupObserverCoulomb()
        self.viewController?.setupObserverPointChargeDeletion()
    }
    
    func placeTopology(topoModel: TopologyModel) {
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
            self.add(pointCharge: pointChargeModel)
        }
        
        /// Add all forces to all the pointCharge Objects
        self.reloadAllForces()
        /// Add all distance indicators
        self.reloadDistanceIndicators()
        
        /// Show Forces and Distance Indicators only for selected pointCharge
        self.showForces(for: selectedPointChargeObj)
        self.showDistaneIndicators(for: selectedPointChargeObj)
    
        
        /// Update Angle Overview Dict
//        self.viewController?.angleOverview.updateForcesDrawings(netForce: selectedPointChargeObj.netForce!)
        
        /// Update Selected ForceDraw
//        self.viewController?.angleOverview.selectForceDrawing(index: selectedPointChargeObj.netForce!.forceId)
        
        /// Update Angle Overview angles
//        self.viewController?.angleOverview.updateAllForcesAngles(netForce: selectedPointChargeObj.netForce!)
    }
    
    func clearTopology() {
        /// Clear all Forces and Distance Indicators
        self.clearAllForces()
        self.clearDistanceIndicators()
        
        /// Clear all PointCharges
        self.removeAllPointCharges()
        
        /// Clear selectedPositions
        self.selectedPositions.removeAll()
        
        /// Clear all Labels
        self.labels.removeAll()
        
        /// Set selected objects to none
        longPressedEntity = Entity()
        trackedEntity = Entity()
        selectedPointChargeObj = PointChargeClass(on: Entity(), inside: self, withValue: 0)
    }
    
    // Show or Hide topology
    func toggleTopology(show: Bool) {
        self.toggleAllForces(show: show)
        self.toggleDistanceIndicators(show: show)
    }
    
}
