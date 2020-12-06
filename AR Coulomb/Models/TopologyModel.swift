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
    var pointCharges: [PointChargeModel]
    var image: UIImage
    
    init(pointCharges: [PointChargeModel], image: UIImage) {
        self.pointCharges = pointCharges
        self.image = image
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
    
    
}
