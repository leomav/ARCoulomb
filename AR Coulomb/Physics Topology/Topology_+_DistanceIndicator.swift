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
            if anchor.name == "Topology" {
                
                if (self.pointCharges.count > 1) {
                    var finished: [PointChargeClass] = []
                    
                    self.pointCharges.forEach{ pointCharge in
                        self.pointCharges.forEach{ otherPointCharge in

                            /// If the two point charges are not the same, and we haven't created all distance indicators for "otherPointCharge" yet...
                            /// ... create one for these two
                            if otherPointCharge.id != pointCharge.id && !finished.contains(where: { (point) -> Bool in
                                return point.id == otherPointCharge.id
                            }) {
                                
                                /// Create distance indicator, from pointcharge to otherPointcharge
                                let distanceIndicator = DistanceIndicator(on: self, from: pointCharge, to: otherPointCharge)
                                /// Add the distance indicator entity to the topo Anchor Entity
                                self.topoAnchorEntity.addChild(distanceIndicator.entity)
                                /// Append the distance indicator to the topology's array
                                self.distanceIndicators.append(distanceIndicator)
                                
                                /// Add distance indicators to pointCharges' collections for distance indicators
                                pointCharge.distanceIndicators.append(distanceIndicator)
                                otherPointCharge.distanceIndicators.append(distanceIndicator)
                                
                            }
                        }
                        
                        /// Mark the pointCharge as "finished" in terms of Distance Indicators
                        finished.append(pointCharge)
                    }
                }
                
                self.updateDistanceIndicators()
            }
        }
    }
    
    func showDistaneIndicators(for pointChargeObj: PointChargeClass) {
        
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
        self.pointCharges.forEach{ pointCharge in
            pointCharge.distanceIndicators.forEach{ indicator in
                indicator.entity.removeFromParent()
            }
            pointCharge.distanceIndicators.removeAll()
        }
        /// Remove them from topology's array too
        self.distanceIndicators.removeAll()
    }
    
    func reloadDistanceIndicators() {
        self.clearDistanceIndicators()
        self.addDistanceIndicators()
    }
}

