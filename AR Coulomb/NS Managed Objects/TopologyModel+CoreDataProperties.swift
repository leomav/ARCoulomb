//
//  TopologyModel+CoreDataProperties.swift
//  AR Coulomb
//
//  Created by Leonidas Mavrotas on 27/11/20.
//  Copyright © 2020 Leonidas Mavrotas. All rights reserved.
//
//

import Foundation
import CoreData


extension TopologyModel {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TopologyModel> {
        return NSFetchRequest<TopologyModel>(entityName: "TopologyModel")
    }

    @NSManaged public var name: String?
    @NSManaged public var image: NSObject?
    @NSManaged public var positions: NSObject?
    @NSManaged public var descr: String?
    @NSManaged public var topoID: UUID?
    @NSManaged public var topology_to_pointCharges: NSSet?

}

// MARK: Generated accessors for topology_to_pointCharges
extension TopologyModel {

    @objc(addTopology_to_pointChargesObject:)
    @NSManaged public func addToTopology_to_pointCharges(_ value: PointChargeModel)

    @objc(removeTopology_to_pointChargesObject:)
    @NSManaged public func removeFromTopology_to_pointCharges(_ value: PointChargeModel)

    @objc(addTopology_to_pointCharges:)
    @NSManaged public func addToTopology_to_pointCharges(_ values: NSSet)

    @objc(removeTopology_to_pointCharges:)
    @NSManaged public func removeFromTopology_to_pointCharges(_ values: NSSet)

}

extension TopologyModel : Identifiable {

}
