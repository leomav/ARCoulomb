//
//  DistanceIndicator.swift
//  AR Coulomb
//
//  Created by Leonidas Mavrotas on 3/1/21.
//  Copyright © 2021 Leonidas Mavrotas. All rights reserved.
//

import Foundation
import RealityKit

class DistanceIndicator {
    static var count: Int = 0
    var id: Int
    var sourcePointCharge: PointChargeClass
    var targetPointCharge: PointChargeClass
    var distance: Float {
        let distance = twoPointsDistance(x1: sourcePointCharge.entity.position.x,
                                         x2: targetPointCharge.entity.position.x,
                                         y1: sourcePointCharge.entity.position.z,
                                         y2: targetPointCharge.entity.position.z)
        return distance
    }
    var previousDistance: Float = 0
    
    var entity: Entity
    var sourceLine: Entity
    var targetLine: Entity
    var label: Entity
    var topology: Topology
    
    static let lineMaterial = UnlitMaterial(color: .yellow)
    
    
    init(on topology: Topology, from source: PointChargeClass, to target: PointChargeClass) {
        self.id = DistanceIndicator.count
        DistanceIndicator.count = DistanceIndicator.count + 1
        
        print("DistanceIndicator init \(self.id)")

        self.sourcePointCharge = source
        self.targetPointCharge = target
        self.topology = topology
        
        /// Initialize the root entity of the Distance Indicator
        self.entity = EntityStore.shared.load_DistanceIndicator()
        
        /// Load label and lines Entities
        self.label = EntityStore.shared.load_TextEntity(on: self.entity, inside: self.topology, name: "Distance Label", position: SIMD3<Float>(0, 0, 0))
        self.sourceLine = EntityStore.shared.load_DistanceLine(on: self.entity)
        self.targetLine = EntityStore.shared.load_DistanceLine(on: self.entity)
        
        /// Initialize the previousDistance as distance
        self.previousDistance = self.distance
        
        /// Update Label and Lines Entities
        self.updateLabel()
        self.updateLines()
    }
    
    deinit {
        /// Delete the label entity when pointCharge gets deleted
        self.topology.labels.removeAll { (label) -> Bool in
            return label.id == self.label.id
        }
        
    }
    
    func updateIndicator() {
        self.updatePosition()
        self.updateOrientation()
        self.updateLines()
        /// Update labels only if difference is >= 0.01 m
        if abs(self.distance - self.previousDistance) >= 0.01 {
            self.updateLabel()
            
            /// Update new previous distance as the current one
            self.previousDistance = self.distance
        }
    }
    
    func toggle(show: Bool) {
        self.entity.isEnabled = show
    }
    
    private func updatePosition() {
        let xdif = (self.targetPointCharge.entity.position.x - self.sourcePointCharge.entity.position.x)/2
        let zdif = (self.targetPointCharge.entity.position.z - self.sourcePointCharge.entity.position.z)/2
        
        self.entity.setPosition(SIMD3<Float>(xdif, 0, zdif), relativeTo: self.sourcePointCharge.entity)
    }
    
    private func updateOrientation() {
        self.entity.look(at: targetPointCharge.entity.position, from: self.entity.position, relativeTo: self.entity.parent)
        
        /// Place it on the surface that the PointCharges sit on
        let ydif = -(1.5 * PointChargeClass.pointChargeRadius)
        self.entity.setPosition(SIMD3<Float>(0, ydif, 0), relativeTo: self.entity)

        
        self.entity.setOrientation(simd_quatf(angle: Int(270).degreesToRadians(), axis: SIMD3<Float>(0, 1.0, 0)), relativeTo: self.entity)
    }
    
    private func updateLabel() {
        EntityStore.shared.update_TextEntity(textEntity: self.label, material: EntityStore.shared.textMaterial, stringValue: String(format: "%.2fm", self.distance), fontSize: 0.008)
    }
    
    private func updateLines() {
        EntityStore.shared.update_DistanceLines(sourceLine: self.sourceLine, targetLine: self.targetLine, length: self.distance)
    }
    
    
    
    private func twoPointsDistance(x1: Float, x2: Float, y1: Float, y2: Float) -> Float {
        let distance: Float
        distance = sqrt(pow(x2-x1, 2) + pow(y2-y1, 2))
        return distance
    }
}
