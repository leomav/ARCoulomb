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
    let viewController: ViewController
    /// Anchor of the topology in the scene
    var topoAnchor: ARAnchor?
    /// Anchor Entity of the topology
    var topoAnchorEntity: AnchorEntity
    /// Selected positions for the pointCharges Entities
    var selectedPositions: [SIMD3<Float>]
    /// All the pointCharge Objects
    var pointCharges: [PointChargeClass]
    /// All the netForces
    var netForces: [NetForce]
    /// A pointChargeEntity Template that gets used for cloning
    let pointChargeEntityTemplate: Entity
    
    init(viewController: ViewController, topoAnchor: ARAnchor) {
        self.viewController = viewController
        self.topoAnchor = topoAnchor
        self.selectedPositions = []
        self.pointCharges = []
        self.netForces = []
        
        /// Import the Point Charge Model, clone the entity as many times as needed
        let pointChargeAnchor = try! PointCharge.load_PointCharge()
        self.pointChargeEntityTemplate = pointChargeAnchor.pointCharge!
        
        /// Add the Anchor Entity to the scene (where the user tapped)
        self.topoAnchorEntity = AnchorEntity(anchor: topoAnchor)
        self.topoAnchorEntity.name = "Point Charge Scene AnchorEntity"
        self.viewController.arView.scene.addAnchor(self.topoAnchorEntity)
    }
    
    // MARK: - Topology functions
    
    func placeTopology(positions: [SIMD3<Float>]) {
        /// Clear the topology, if there was one
        self.clearTopology()
        
        /// Set new selectedPositions
        self.selectedPositions = positions
        
        /// Create PointCharges in the selected Positions
        for pos in self.selectedPositions {
            self.addPointCharge(to: pos)
        }
        /// Remove gesture recognizer needed for the Topology Anchor Placement
        self.disableRecognizers(withName: "First Point Recognizer")
        
        /// Enable the pointCharge LongPress Recognizer
        self.enableRecognizers(withName: "Long Press Recognizer")
        
        /// Create observer for changes in selected PointChargObj's coulomb Value
        self.viewController.createCbObserver()
        
        /// Create observer for any PointCharge Removal
        self.viewController.setupObserverPointChargeDeletion()
        
        /// Add all forces to all the pointCharge Objects
        self.reloadAllForces()
        
        self.showForcesFor(for: selectedPointChargeObj)
        
        /// Hide the top Helper Text
        self.viewController.guideText.isHidden = true
    }
    
    private func clearTopology() {
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
    
    func enableRecognizers(withName name: String) {
        self.viewController.arView.gestureRecognizers?.forEach{ recognizer in
            
            /// Enable the pointCharge LongPressRecognizer
            if recognizer.name == name {
                recognizer.isEnabled = true
            }
            
            /// Installed gestures (EntityGesturesRecognizers for each point charge) were cancelling
            /// other touches, so turn that to false
            recognizer.cancelsTouchesInView = false
        }
    }
    
    func disableRecognizers(withName name: String) {
        self.viewController.arView.gestureRecognizers?.forEach{ recognizer in
            
            /// Enable the pointCharge LongPressRecognizer
            if recognizer.name == name {
                recognizer.isEnabled = false
            }
        }
    }
    
    
    
}
