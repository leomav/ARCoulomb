//
//  Alert.swift
//  AR Coulomb
//
//  Created by Leonidas Mavrotas on 26/8/20.
//  Copyright © 2020 Leonidas Mavrotas. All rights reserved.
//

import UIKit

struct Alert {
    
    private static func showConfirmationAlert(on vc: ViewController, title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (UIAlertAction) in
            // DO NOTHING
        }))
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
            /// Topology remove Point Charge
            vc.topology?.removePointCharge()
            
            /// Enable the Stack View Buttons (add pointChaege, add topo)
            vc.showAndEnableButtons()
            
            /// If the Limit Number is reached, disable the Add Button
            /// Probably impossible since one was just deleted, but whatever, SAFETY FIRST
            if vc.topology?.pointCharges.count == 6 {
                vc.addButton.isEnabled = false
            }
        }))
        vc.present(alert, animated: true, completion: nil)
    }
    
    private static func showBasicAlert(on vc: ViewController, title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (UIAlertAction) in
            // DO NOTHING
        }))
        vc.present(alert, animated: true, completion: nil)
    }
    
    static func showDeletionConfirmation(on vc: ViewController) {
        showConfirmationAlert(on: vc, title: "Confirm", message: "Are you sure you want to delete this Point of Charge?")
    }
    
    static func showPointChargesLimitReached(on vc: ViewController) {
        showBasicAlert(on: vc, title: "Limit reached", message: "The maximum number (6) of point of Charges has been reached.")
    }
    
    
}
