//
//  PointCharge.swift
//  AR Coulomb
//
//  Created by Leonidas Mavrotas on 30/6/20.
//  Copyright © 2020 Leonidas Mavrotas. All rights reserved.
//

import UIKit
import RealityKit

class PointChargeClass {
    static var count: Int = 0
    let id: Int
    
    /// The Point Charge Entity (sphere mesh)
    let entity: Entity
    /// The Entity's mesh (sphere) radius
    static var pointChargeRadius: Float = 0.02
    /// Topology
    var topology: Topology
    /// 3D Text Mesh for Value Labeling
    var label: Entity
    /// Numeric Value Rendered (Coulomb)
    var value: Float
    /// The Net Force applied to the point of charge
    var netForce: NetForce?
    /// The forces applied to other points from this one
    var forcesOnOthers: [SingleForce]
    /// The distance Indicators on this point of charge
    var distanceIndicators: [DistanceIndicator]
    /// The Real Value Multiplier (C, mC. uC, nC)
    static var multiplier: Float = 0.000001
    
    init(on entity: Entity, inside topology: Topology, withValue value: Float) {
        PointChargeClass.count += 1
        
        self.id = PointChargeClass.count
        self.entity = entity
        self.value = value
        self.topology = topology
        
        /// Set up Label Entity
        let textPos = SIMD3<Float>(0, (PointChargeClass.pointChargeRadius + 0.01), 0)
        self.label = EntityStore.shared.load_TextEntity(on: self.entity, inside: self.topology, name: "Coulomb Text", position: textPos)
        EntityStore.shared.update_TextEntity(textEntity: self.label, stringValue: "\(self.value) Cb")

        
        self.forcesOnOthers = []
        self.distanceIndicators = []
    }
    
    deinit {
        /// Delete the label entity when pointCharge gets deleted
        self.topology.labels.removeAll { (label) -> Bool in
            return label.id == self.label.id
        }
        
    }
    
    static func ==(lhs: PointChargeClass, rhs: PointChargeClass) -> Bool {
        return lhs.id == rhs.id
    }
    
    func getPositionX() -> Float {
        return self.entity.position.x
    }
    
    func getPositionY() ->  Float{
        return self.entity.position.y
    }
    
    func getPositionZ() -> Float{
        return self.entity.position.z
    }
    
    
    
}
