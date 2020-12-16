//
//  NSPointCharge+CoreDataProperties.swift
//  AR Coulomb
//
//  Created by Leonidas Mavrotas on 30/11/20.
//  Copyright © 2020 Leonidas Mavrotas. All rights reserved.
//
//

import Foundation
import CoreData


extension NSPointCharge {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NSPointCharge> {
        return NSFetchRequest<NSPointCharge>(entityName: "NSPointCharge")
    }

    @NSManaged public var value: Float
    @NSManaged public var multiplier: Float
    @NSManaged public var posX: Float
    @NSManaged public var posY: Float
    @NSManaged public var posZ: Float
    @NSManaged public var topology: NSTopology?

}

extension NSPointCharge : Identifiable {

}
