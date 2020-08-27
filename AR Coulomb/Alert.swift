//
//  Alert.swift
//  AR Coulomb
//
//  Created by Leonidas Mavrotas on 26/8/20.
//  Copyright © 2020 Leonidas Mavrotas. All rights reserved.
//

import UIKit

struct Alert {
    
    private static func showBasicAlert(on vc: ViewController, title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (UIAlertAction) in
            // DO NOTHING
        }))
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
            /// Topology remove Point Charge
            vc.topology?.removePointCharge()
            
            /// Enable the ADD Button
            vc.showAndEnableButton(btn: vc.addButton)
        }))
        vc.present(alert, animated: true, completion: nil)
    }
    
    static func showDeletionConfirmation(on vc: ViewController) {
        showBasicAlert(on: vc, title: "Confirm", message: "Are you sure you want to delete this Point of Charge?")
    }
    
    
}
