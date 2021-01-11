//
//  TopologyModel.swift
//  AR Coulomb
//
//  Created by Leonidas Mavrotas on 2/12/20.
//  Copyright © 2020 Leonidas Mavrotas. All rights reserved.
//

import Foundation
import UIKit

class TopologyModel {
    var id: ObjectIdentifier
    var pointCharges: [PointChargeModel]
    var image: UIImage
    var name: String
    var descr: String
    
    init(id: ObjectIdentifier, pointCharges: [PointChargeModel], image: UIImage, name: String, description: String) {
        self.id = id
        self.pointCharges = pointCharges
        self.image = image
        self.name = name
        self.descr = description
    }
    
    // MARK: - Getters and setters
    
    func addPointChargeModel (model: PointChargeModel) {
        self.pointCharges.append(model)
    }
    
    func getPointCharges () -> [PointChargeModel] {
        return self.pointCharges
    }
    
    func setImage(image: UIImage) {
        self.image = image
    }
    
    func getImage() -> UIImage {
        return self.image
    }
    
    func setName(name: String) {
        self.name = name
    }
    
    func getName() -> String {
        return self.name
    }
    
    func setDescription(descr: String) {
        self.descr = descr
    }
    
    func getDescription() -> String {
        return self.descr
    }
    

    
    
}
