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
        
        /// Enable Angle Overview View
        self.angleOverview.isHidden = false
        self.angleLabel.isHidden = false
        
        /// If the Limit Number is reached, disable the Add Button
        if self.topology.pointCharges.count == 6 {
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
        if let newValue = (notification.userInfo?["updatedValue"]) as? TopologyModel {
//        if let newValue = (notification.userInfo?["updatedValue"]) as? [SIMD3<Float>] {

            /// Get the new positions from the Notification
            let newTopoModel = newValue
            
            /// Place the selected Topology on the AnchorEntity placed in scene
            if topology.topoAnchorEntity != nil {
                topology.placeTopology(topoModel: newTopoModel)
            } else {
                print("Error: No anchor is selected for topology placement!")
            }
            
            /// Enable the StackView Buttons (add new pointCharge, add new topo)
            self.toggleStackView(hide: false, animated: false)
            
            /// Enable the Angle Overview View
            self.angleOverview.isHidden = false
            self.angleLabel.isHidden = false
            
            /// If the Limit Number is reached, disable the Add Button
            if self.topology.pointCharges.count == 6 {
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
        Alert.showDeletionConfirmation(on: self)
    }
    
    //  (4)
    //  MARK: - Coulomb Value Observer
    
    /// When new value occurs for the selected PointChargeObj
    func setupObserverCoulomb() {
        let notifName = Notification.Name(rawValue: cbNotificationKey)
        NotificationCenter.default.addObserver(self, selector: #selector(updateCoulombValue(notification:)), name: notifName, object: nil)
    }
    /// Set the new selected Point Charge obj's value, update its text, update its text, update all forces
    @objc
    func updateCoulombValue(notification: Notification) {
        if let newValue = (notification.userInfo?["updatedValue"]) as? Float {
            
            selectedPointChargeObj.value = newValue
            
            EntityStore.shared.update_TextEntity(textEntity: selectedPointChargeObj.label, stringValue: "\(newValue) Cb")
            // Find text entity of pointCharge
//            for entity in longPressedEntity.children {
//                if entity.name == "Coulomb Text" {
//                    EntityStore.shared.update_TextEntity(textEntity: entity, stringValue: "\(newValue) Cb")
////                    PointChargeClass.loadText(textEntity: entity, material: coulombTextMaterial, coulombStringValue: "\(newValue) Cb")
//                    break
//                }
//            }
//            PointChargeClass.loadText(textEntity: longPressedEntity.children[1], material: coulombTextMaterial, coulombStringValue: "\(newValue) Cb")
            
            self.topology.updateForces()
            
        } else {
            print("Error: Not updated coulomb value!")
        }
    }
    
    
    // (5)
    // MARK: - Topology Captured Image View was dismissed
    
    func setupObserverCapturedImage() {
        let notifName = Notification.Name(rawValue: photoTakenNotificationKey)
        NotificationCenter.default.addObserver(self, selector: #selector(saveTopologyToCoreData(notification:)), name: notifName, object: nil)

    }
    
    @objc
    func saveTopologyToCoreData(notification: Notification)  {
        if let capturedImage = (notification.userInfo?["imageData"] as? Data) {
            
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
                
                TopologyStore.sharedInstance.saveTopologyToCoreData(pointCharges: self.topology.pointCharges, name: name!, description: description!, capturedImage: capturedImage)
//                // Save the topology
//                let topology = NSTopology(context: PersistenceService.context)
//                topology.name = name
//                topology.descr = description
//                topology.image = capturedImage
//                PersistenceService.saveContext()
//                
//                // Save pointCharges info
//                self.topology.pointCharges.forEach{ pointChargeObj in
//                    let pointCharge = NSPointCharge(context: PersistenceService.context)
//                    pointCharge.posX = pointChargeObj.getPositionX()
//                    pointCharge.posY = pointChargeObj.getPositionY()
//                    pointCharge.posZ = pointChargeObj.getPositionZ()
//                    pointCharge.multiplier = PointChargeClass.multiplier
//                    pointCharge.value = pointChargeObj.value
//                    pointCharge.topology = topology
//                    PersistenceService.saveContext()
//                }
//
//                // Reload the savedTopologies
//                TopologyStore.sharedInstance.reloadSavedTopologies()
//                //
//                PersistenceService.saveContext()
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
            
            alertController.addAction(confirmAction)
            alertController.addAction(cancelAction)
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    // (6)
    // MARK: - New Selected Point Charge Object
    
    func setupObserverNewSelectedPointChargeObject() {
        let notifName = Notification.Name(rawValue: newSelectedPointChargeNotificationKey)
        NotificationCenter.default.addObserver(self, selector: #selector(updateAnglesOverviewView(notification:)), name: notifName, object: nil)

    }
    
    @objc
    func updateAnglesOverviewView(notification: Notification) {
//        print(previouslySelectedForceAngleFloatValue.radiansToDegrees, selectedForceAngleFloatValue.radiansToDegrees)
        self.angleOverview.setNeedsDisplay()
        self.angleLabel.setNeedsDisplay()
    }
    
    
    // (7)
    // MARK: - New Selected Force
    
    func setupObserverNewSelectedForceValue() {
        let notifName = Notification.Name(rawValue: newSelectedForceValueNotificationKey)
        NotificationCenter.default.addObserver(self, selector: #selector(updateAnglesLabel(notification:)), name: notifName, object: nil)

    }
    
    @objc
    func updateAnglesLabel(notification: Notification) {
        self.angleLabel.text = selectedForceValue
    }
}
