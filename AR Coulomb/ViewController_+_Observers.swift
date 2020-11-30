//
//  ViewController_+_Observers.swift
//  AR Coulomb
//
//  Created by Leonidas Mavrotas on 27/8/20.
//  Copyright © 2020 Leonidas Mavrotas. All rights reserved.
//


import UIKit

extension ViewController {

    //  (1)
    //  MARK: - CoulombMenu ViewController dismissed
    
    /// CoulombMenu Dismissal Observer: When CoulombMenu VC is dismissed without any action (like pointCharge deletion)
    func setupObserverMenuDismissal() {
        let notifName = Notification.Name(rawValue: dismissalNotificationKey)
        NotificationCenter.default.addObserver(self, selector: #selector(recoverAddButton(notification:)), name: notifName, object: nil)
    }
    
    @objc
    func recoverAddButton(notification: Notification) {
        /// Enable the StackView Buttons (add new pointCharge, add new topo)
        self.toggleStackView(hide: false, animated: false)
        
        /// If the Limit Number is reached, disable the Add Button
        if self.topology?.pointCharges.count == 6 {
            self.addButton.isEnabled = false
        }
    }
    
    //  (2)
    //  MARK: - Topology Observer
    
    /// Topology Observer: When new topology is selected
    func setupObserverNewTopo() {
        let notifName = Notification.Name(rawValue: topoNotificationKey)
        NotificationCenter.default.addObserver(self, selector: #selector(addTopology(notification:)), name: notifName, object: nil)
    }
    /// update the selected Positions
    @objc
    func addTopology(notification: Notification) {
        if let newValue = (notification.userInfo?["updatedValue"]) as? [SIMD3<Float>] {

            /// Get the new positions from the Notification
            let newPositions = newValue
            
            /// Place the selected Topology on the AnchorEntity placed in scene
            if topology!.topoAnchor != nil {
                topology!.placeTopology(positions: newPositions)
            } else {
                print("Error: No anchor is selected for topology placement!")
            }
            
            /// Enable the StackView Buttons (add new pointCharge, add new topo)
            self.toggleStackView(hide: false, animated: false)
            
            /// If the Limit Number is reached, disable the Add Button
            if self.topology?.pointCharges.count == 6 {
                self.addButton.isEnabled = false
            }

        } else {
            print("Error: Not updated topology!")
        }
    }
    
    //  (3)
    //  MARK: - Coulomb Removal Observer
    
    /// When a coulomb is deleted in the CoulombMenu ViewController
    func setupObserverPointChargeDeletion() {
        let notifName = Notification.Name(rawValue: removalNotificationKey)
        NotificationCenter.default.addObserver(self, selector: #selector(removePointCharge(notification: )), name: notifName, object: nil)
    }
    /// Remove the selected pointCharge
    @objc
    func removePointCharge(notification: Notification) {
        
        print("--------- Observer: Delete.")
        Alert.showDeletionConfirmation(on: self)
    }
    
    //  (4)
    //  MARK: - Coulomb Value Observer
    
    /// When new value occurs for the selected PointChargeObj
    func createCbObserver() {
        let notifName = Notification.Name(rawValue: cbNotificationKey)
        NotificationCenter.default.addObserver(self, selector: #selector(updateCoulombValue(notification:)), name: notifName, object: nil)
    }
    /// Set the new selected Point Charge obj's value, update its text, update its text, update all forces
    @objc
    func updateCoulombValue(notification: Notification) {
        if let newValue = (notification.userInfo?["updatedValue"]) as? Float {
            
            selectedPointChargeObj.value = newValue
            
            PointChargeClass.loadText(textEntity: longPressedEntity.children[1], material: coulombTextMaterial, coulombStringValue: "\(newValue) Cb")
            
            self.topology?.updateForces()
            
        } else {
            print("Error: Not updated coulomb value!")
        }
    }
    
    
    // (5)
    // MARK: - Topology Captured Image View was dismissed
    
    func createCapturedImageObserver() {
        let notifName = Notification.Name(rawValue: photoTakenNotificationKey)
        NotificationCenter.default.addObserver(self, selector: #selector(saveTopologyToCoreData(notification:)), name: notifName, object: nil)

    }
    
    @objc
    func saveTopologyToCoreData(notification: Notification)  {
        print("Observer awaken")
        if let capturedImage = (notification.userInfo?["imageData"] as? Data) {
            print("Observer awaken VALID")
            
            // TODO:  Open dialog to enter new topology's name and description
            let alertController = UIAlertController(title: "Topology Details", message: "Enter a name and a description", preferredStyle: .alert)
            
            alertController.addTextField{ (textField) in
                textField.placeholder = "Name"
            }
            
            alertController.addTextField{ (textField) in
                textField.placeholder = "Description"
            }
            
            let confirmAction = UIAlertAction(title: "OK", style: .default) { (_) in
                let name = alertController.textFields?[0].text
                let description = alertController.textFields?[1].text
                
                
                // Save the topology
                let topology = TopologyModel(context: PersistenceService.context)
                topology.name = name
                topology.descr = description
                topology.image = capturedImage 
                PersistenceService.saveContext()
                
                // Save pointCharges info
                self.topology?.pointCharges.forEach{ pointChargeObj in
                    let pointCharge = PointChargeModel(context: PersistenceService.context)
                    pointCharge.posX = pointChargeObj.getPositionX()
                    pointCharge.posY = pointChargeObj.getPositionY()
                    pointCharge.posZ = pointChargeObj.getPositionZ()
                    pointCharge.multiplier = pointChargeObj.multiplier
                    pointCharge.value = pointChargeObj.value
                    pointCharge.topology = topology
                    PersistenceService.saveContext()
                }
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
            
            alertController.addAction(confirmAction)
            alertController.addAction(cancelAction)
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
}
