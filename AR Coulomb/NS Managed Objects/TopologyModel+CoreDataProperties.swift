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
    @NSManaged public var descr: String?

}

