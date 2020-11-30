//
//  DatabaseHelper.swift
//  AR Coulomb
//
//  Created by Leonidas Mavrotas on 29/11/20.
//  Copyright © 2020 Leonidas Mavrotas. All rights reserved.
//

import Foundation
import UIKit

class DataBaseHelper {
    static let shareInstance = DataBaseHelper()
    
    let context = PersistenceService.context
    
    func saveTopologyToCoreData(topoDescription: String, imageData: Data, topoName: String, completion: ((Bool, String) -> ())){
        let topologyInstance = TopologyModel(context: context)
        topologyInstance.descr = topoDescription
        topologyInstance.image = imageData
        topologyInstance.name = topoName

        do {
            try context.save()
            print("Topology is saved")
            completion(true, "")
        } catch {
            print(error.localizedDescription)
            completion(false, error.localizedDescription)
        }
    }
}
