//
//  Topology_+_DistanceIndicator.swift
//  AR Coulomb
//
//  Created by Leonidas Mavrotas on 3/1/21.
//  Copyright © 2021 Leonidas Mavrotas. All rights reserved.
//

import RealityKit

extension Topology {
    
    func addDistanceIndicators() {
        self.viewController?.arView.scene.anchors.forEach{ anchor in
            if anchor.name == "Point Charge Scene AnchorEntity" {
                
                if (self.pointCharges.count > 0) {
                    /// Initialize source point charge and counter
                    var srcPointCharge = self.pointCharges[0]
                    let initialPointCharge = srcPointCharge
                    var counter = 1
                    /// On each step, rotate one pointCharge forwards until there are none left
                    /// Create a DistanceIndicator for each couple
                    while counter < self.pointCharges.count {
                        /// Target is the next of Source
                        let trgtPointCharge = self.pointCharges[counter]
                        
                        let distanceIndicator = DistanceIndicator(from: srcPointCharge, to: trgtPointCharge)
                        self.topoAnchorEntity?.addChild(distanceIndicator.entity)
                        self.distanceIndicators.append(distanceIndicator)
                        
                        /// Add distance indicators to pointCharge's collections for distance indicators
                        srcPointCharge.distanceIndicators.append(distanceIndicator)
                        trgtPointCharge.distanceIndicators.append(distanceIndicator)
                        
                        /// Source is ex-Target
                        srcPointCharge = self.pointCharges[counter]
                        counter = counter + 1
                        
                        /// On the last one, complete the circle
                        if counter == self.pointCharges.count {
                            let distanceIndicator = DistanceIndicator(from: trgtPointCharge, to: initialPointCharge)
                            self.topoAnchorEntity?.addChild(distanceIndicator.entity)
                            self.distanceIndicators.append(distanceIndicator)
                            
                            /// Add distance indicators to pointCharge's collections for distance indicators
                            srcPointCharge.distanceIndicators.append(distanceIndicator)
                            trgtPointCharge.distanceIndicators.append(distanceIndicator)
                        }
                    }
                }
                
                self.updateDistanceIndicators()
            }
        }
    }
    
    func showDistaneIndicators(for pointChargeObj: PointChargeClass) {
//        self.distanceIndicators.forEach{ indicator in
//            /// Disable the Indicator
//            indicator.toggle(show: false)
//            
//            if indicator.sourcePointCharge.id == pointChargeObj.id || indicator.targetPointCharge.id == pointChargeObj.id {
//                indicator.toggle(show: true)
//            }
//        }
        
        self.distanceIndicators.forEach{ indicator in
            indicator.toggle(show: false)
        }
        pointChargeObj.distanceIndicators.forEach{ indicator in
            indicator.toggle(show: true)
        }
    }
    
    func updateDistanceIndicators() {
        self.distanceIndicators.forEach{ indicator in
            indicator.updateIndicator()
        }
    }
    
    func updateDistanceIndicators(for pointCharge: PointChargeClass) {
        pointCharge.distanceIndicators.forEach{ indicator in
            indicator.updateIndicator()
        }
    }
    
    func toggleDistanceIndicators(show: Bool) {
        self.distanceIndicators.forEach{ indicator in
            indicator.toggle(show: show)
        }
    }
    
    func clearDistanceIndicators() {
        self.distanceIndicators.forEach{ indicator in
            indicator.entity.removeFromParent()
        }
        self.distanceIndicators.removeAll()
    }
    
    func reloadDistanceIndicators() {
        self.clearDistanceIndicators()
        self.addDistanceIndicators()
    }
}

