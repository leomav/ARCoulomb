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
    
    var entity: Entity
    var sourceLine: Entity
    var targetLine: Entity
    var labelPivot: Entity = Entity()
    var label: Entity
    
    
    init(from source: PointChargeClass, to target: PointChargeClass) {
        print("Created")
        self.id = DistanceIndicator.count
        DistanceIndicator.count = DistanceIndicator.count + 1
        
        self.sourcePointCharge = source
        self.targetPointCharge = target
        
        self.entity = EntityStore.shared.load_DistanceIndicator()
        
        self.labelPivot.name = "Distance Label Pivot"
        self.labelPivot.setParent(self.entity)
        
        self.label = EntityStore.shared.load_TextEntity(on: self.labelPivot, name: "Distance Label", position: SIMD3<Float>(0, 0, 0))
        
        self.sourceLine = EntityStore.shared.load_DistanceLine()
        self.targetLine = EntityStore.shared.load_DistanceLine()
        
        EntityStore.shared.update_TextEntity(textEntity: self.label, material: EntityStore.shared.textMaterial, stringValue: "\(0)m")
        
        EntityStore.shared.update_DistanceLines(sourceEntity: self.sourceLine, targetEntity: self.targetLine, length: self.distance)
    }
    
    func updateIndicator() {
        self.updatePosition()
        self.updateOrientation()
        self.updateLabel()
        self.updateLines()
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
//        self.entity.setOrientation(simd_quatf(angle: Int(90).degreesToRadians(), axis: SIMD3<Float>(1, 0, 0)), relativeTo: self.entity)

    }
    
    private func updateLabel() {
        EntityStore.shared.update_TextEntity(textEntity: self.label, material: EntityStore.shared.textMaterial, stringValue: "\(0)m")
    }
    
    private func updateLines() {
        EntityStore.shared.update_DistanceLines(sourceEntity: self.sourceLine, targetEntity: self.targetLine, length: self.distance)
    }
    
    
    
    private func twoPointsDistance(x1: Float, x2: Float, y1: Float, y2: Float) -> Float {
        let distance: Float
        distance = sqrt(pow(x2-x1, 2) + pow(y2-y1, 2))
        return distance
    }
}
