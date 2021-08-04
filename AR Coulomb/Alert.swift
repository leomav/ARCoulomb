//
//  Alert.swift
//  AR Coulomb
//
//  Created by Leonidas Mavrotas on 26/8/20.
//  Copyright © 2020 Leonidas Mavrotas. All rights reserved.
//

import UIKit

struct Alert {
    
    private static func showTripleConfirmationAlert(on vc: ViewController, title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title:"Cancel", style: .cancel, handler: { (UIAlertAction) in
            // DO NOTHING
        }))
        alert.addAction(UIAlertAction(title: "Not Save", style: .destructive, handler: { (UIAlertAction) in
            // New Topology
            vc.performSegueToTopoMenu()
        }))
        alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { action in
            vc.transitionStackViewMenu(to: "camera")
        }))
        vc.present(alert, animated: true, completion: nil)
    }
    
    private static func showConfirmationAlert(on vc: ViewController, title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (UIAlertAction) in
            // DO NOTHING
        }))
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
            /// Topology remove Point Charge
            vc.topology.removePointCharge()
            
            /// Enable the Stack View Buttons (add pointChaege, add topo)
            vc.toggleStackView(hide: false, animated: false)
            
            /// Update Angle Overview
//            vc.angleOverview.updateAllForcesAngles(netForce: selectedPointChargeObj.netForce!)
            
            /// Enable the Angle Overview View
            vc.angleOverview.isHidden = false
            vc.angleLabel.isHidden = false
            
            /// Probably impossible since one was just deleted, but whatever, SAFETY FIRST...
            /// If the Limit Number is reached, disable the Add Button
            if vc.topology.pointCharges.count == 6 {
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
    
    private static func showSuccessAlert(on vc: ViewController, title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        vc.present(alert, animated: true, completion: nil)
        
        // change to desired number of seconds (in this case 5 seconds)
        let when = DispatchTime.now() + 3
        DispatchQueue.main.asyncAfter(deadline: when){
          // your code with delay
          alert.dismiss(animated: true, completion: nil)
        }
    }
    
    /**
    -----------------------------------------------
     */
    
    static func showSuccessfulSaveTopologyAlert(on vc: ViewController) {
        showSuccessAlert(on: vc, title: "Saved", message: "Your topology was saved successfully!")
    }
    
    static func showDeletionConfirmation(on vc: ViewController) {
        showConfirmationAlert(on: vc, title: "Confirm", message: "Are you sure you want to delete this Point of Charge?")
    }
    
    static func showPointChargesLimitReached(on vc: ViewController) {
        showBasicAlert(on: vc, title: "Limit reached", message: "The maximum number (6) of point of Charges has been reached.")
    }
    
    static func showSeagueToTopoMenuConfirmation(on vc: ViewController) {
        showTripleConfirmationAlert(on: vc, title: "Unsaved Topology", message: "Do you want to save the current topology?")
    }
    
    
}
