//
//  TopologyModel+CoreDataProperties.swift
//  AR Coulomb
//
//  Created by Leonidas Mavrotas on 30/11/20.
//  Copyright © 2020 Leonidas Mavrotas. All rights reserved.
//
//

import Foundation
import CoreData


extension TopologyModel {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TopologyModel> {
        return NSFetchRequest<TopologyModel>(entityName: "TopologyModel")
    }

    @NSManaged public var descr: String?
    @NSManaged public var image: Data?
    @NSManaged public var name: String?
    @NSManaged public var pointCharges: NSOrderedSet?

}

// MARK: Generated accessors for pointCharges
extension TopologyModel {

    @objc(insertObject:inPointChargesAtIndex:)
    @NSManaged public func insertIntoPointCharges(_ value: PointChargeModel, at idx: Int)

    @objc(removeObjectFromPointChargesAtIndex:)
    @NSManaged public func removeFromPointCharges(at idx: Int)

    @objc(insertPointCharges:atIndexes:)
    @NSManaged public func insertIntoPointCharges(_ values: [PointChargeModel], at indexes: NSIndexSet)

    @objc(removePointChargesAtIndexes:)
    @NSManaged public func removeFromPointCharges(at indexes: NSIndexSet)

    @objc(replaceObjectInPointChargesAtIndex:withObject:)
    @NSManaged public func replacePointCharges(at idx: Int, with value: PointChargeModel)

    @objc(replacePointChargesAtIndexes:withPointCharges:)
    @NSManaged public func replacePointCharges(at indexes: NSIndexSet, with values: [PointChargeModel])

    @objc(addPointChargesObject:)
    @NSManaged public func addToPointCharges(_ value: PointChargeModel)

    @objc(removePointChargesObject:)
    @NSManaged public func removeFromPointCharges(_ value: PointChargeModel)

    @objc(addPointCharges:)
    @NSManaged public func addToPointCharges(_ values: NSOrderedSet)

    @objc(removePointCharges:)
    @NSManaged public func removeFromPointCharges(_ values: NSOrderedSet)

}

extension TopologyModel : Identifiable {

}
