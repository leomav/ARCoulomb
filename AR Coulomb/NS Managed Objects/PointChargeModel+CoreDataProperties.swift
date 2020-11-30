//
//  PointChargeModel+CoreDataProperties.swift
//  AR Coulomb
//
//  Created by Leonidas Mavrotas on 30/11/20.
//  Copyright © 2020 Leonidas Mavrotas. All rights reserved.
//
//

import Foundation
import CoreData


extension PointChargeModel {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PointChargeModel> {
        return NSFetchRequest<PointChargeModel>(entityName: "PointChargeModel")
    }

    @NSManaged public var value: Float
    @NSManaged public var multiplier: Float
    @NSManaged public var posX: Float
    @NSManaged public var posY: Float
    @NSManaged public var posZ: Float
    @NSManaged public var topology: TopologyModel?

}

extension PointChargeModel : Identifiable {

}
