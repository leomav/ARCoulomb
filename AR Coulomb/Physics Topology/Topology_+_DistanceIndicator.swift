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
                        self.distanceIndicators.append(distanceIndicator)
                        
                        /// Source is ex-Target
                        srcPointCharge = self.pointCharges[counter]
                        counter = counter + 1
                        
                        /// On the last one, complete the circle
                        if counter == self.pointCharges.count {
                            let distanceIndicator = DistanceIndicator(from: trgtPointCharge, to: initialPointCharge)
                            self.distanceIndicators.append(distanceIndicator)
                        }
                    }
                }
                
                self.updateDistanceIndicators()
            }
        }
    }
    
    func showDistaneIndicators(for pointChargeObj: PointChargeClass) {
        self.distanceIndicators.forEach{ indicator in
            /// Disable the Indicator
            indicator.toggle(show: false)
            
            if indicator.sourcePointCharge.id == pointChargeObj.id || indicator.targetPointCharge.id == pointChargeObj.id {
                indicator.toggle(show: true)
            }
        }
    }
    
    func updateDistanceIndicators() {
        self.distanceIndicators.forEach{ indicator in
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
    }
    
    func reloadDistanceIndicators() {
        self.clearDistanceIndicators()
        self.addDistanceIndicators()
    }
}

