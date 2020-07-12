//
//  ViewController.swift
//  AR Fortia
//
//  Created by Leonidas Mavrotas on 1/6/20.
//  Copyright © 2020 Leonidas Mavrotas. All rights reserved.
//

import UIKit
import RealityKit
import ARKit

let cbNotificationKey = "com.leomav.coulombValueChange"

let ZOOM_IN_5_4: Float = 1.25
let ZOOM_OUT_4_5: Float = 0.8

class ViewController: UIViewController {
    
    @IBOutlet var arView: ARView!
    
    //    let coulombViewController = CoulombMenu(nibName: nil, bundle: nil)
    //    let coulombViewMenu = coulombViewController.coulombMenuView
    
    let coulombTextMaterial: SimpleMaterial = {
        var mat = SimpleMaterial()
        mat.metallic = MaterialScalarParameter(floatLiteral: 0.2)
        mat.roughness = MaterialScalarParameter(floatLiteral: 0.1)
        mat.tintColor = UIColor.white
        return mat
    }()
    
    var selectedPositions: [SIMD3<Float>] = []
    
    var trackedEntity: Entity = Entity()
    var longPressedEntity: Entity = Entity()
    
    // Array of PointChargeClass Objects, that contain pointCharge info all
    // (id, entity)
    var pointCharges: [PointChargeClass] = []
    
    // Array of Force Objects that contain force info
    var forces: [Force] = []
    
    // translates autoresizing mask into constraints lets us
    // manually alter the constraints
    let stackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 8
        stack.backgroundColor = .white
        stack.distribution = .fillEqually
        //stack.alignment = .fill
        
        return stack
    }()
    
    let scrollView: UIScrollView = {
        let scroll = UIScrollView()
        // When the next line was not present, the ScrollView crashed
        scroll.translatesAutoresizingMaskIntoConstraints = false
        
        return scroll
    }()
    
    let slider: UISlider = {
        let slider = UISlider()
        return slider
    }()
    
    let coulombViewController = CoulombMenu_ViewController(nibName: nil, bundle: nil)
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        arView.session.delegate = self
        
        setupARView()
        
        addStackView()
        
        // First tap gesture recognizer, will be deleted after first point of charge is added
        let firstPointTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer:)))
        firstPointTapRecognizer.name = "First Point Recognizer"
        arView.addGestureRecognizer(firstPointTapRecognizer)
        
        // Long Press Recognizer to enable parameters interaction with Point Charge (min press 1 sec)
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(recognizer:)))
        longPressRecognizer.name = "Long Press Recognizer"
        longPressRecognizer.minimumPressDuration = 1
        arView.addGestureRecognizer(longPressRecognizer)
        longPressRecognizer.isEnabled =  false
        
    }
    
    func setupARView() {
        arView.automaticallyConfigureSession = false
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal, .vertical]
        config.environmentTexturing = .automatic
        arView.session.run(config)
        
    }
    
    func addStackView() {
        // You simply cannot constrain a view to another view if the view isn’t even on the screen yet.
        arView.addSubview(scrollView)
        scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        scrollView.topAnchor.constraint(equalTo: view.bottomAnchor, constant: -150).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20).isActive = true
        
        scrollView.addSubview(stackView)
        stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
        stackView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
        
        stackView.heightAnchor.constraint(equalTo: scrollView.heightAnchor).isActive = true
        
        // Create the buttons in the scroll-stack view, one for each topology
        for i in 0...5 {
            let btn = UIButton()
            btn.setBackgroundImage(UIImage(named: "kobe"), for: .normal)
            btn.addTarget(self, action: #selector(self.buttonAction(sender:)), for: .touchUpInside)
            btn.isEnabled = true
            btn.tag = i + 1
            btn.widthAnchor.constraint(equalToConstant: 120).isActive = true
            
            // Add the button to the view
            stackView.addArrangedSubview(btn)
        }
        
    }
    
    @objc func buttonAction(sender: UIButton!) {
        let btnsend: UIButton = sender
        if btnsend.tag > 0 && btnsend.tag < 7 {
            // Empty the current points of charge positions
            selectedPositions.removeAll()
            // Get the new ones
            let pos = defaultPositions[btnsend.tag]!
            selectedPositions.append(contentsOf: pos)
        }
    }
    
    
    // ---------------------------------------------------------------------------------
    // --------------------------- TEXT ENTITY -----------------------------------------
    func createTextEntity(pointEntity: Entity) -> Entity {
        let textEntity: Entity = Entity()
        textEntity.name = "text"
        textEntity.setParent(pointEntity)
//        textEntity.setPosition(SIMD3<Float>(-0.02, -0.03, 0.03), relativeTo: pointEntity)
        textEntity.setPosition(SIMD3<Float>(-0.02, -0.03, 0), relativeTo: pointEntity)
        textEntity.setOrientation(simd_quatf(angle: Int(90).degreesToRadians(), axis: SIMD3<Float>(1, 0, 0)), relativeTo: pointEntity)
//        textEntity.setOrientation(simd_quatf(ix: -0.45, iy: 0, iz: 0, r: 0.9), relativeTo: pointEntity)
        
        return textEntity
    }
    
    func loadText(textEntity: Entity, material: SimpleMaterial, coulombStringValue: String) {
        let model: ModelComponent = ModelComponent(mesh: .generateText(coulombStringValue,
                                                                       extrusionDepth: 0.003,
                                                                       font: .systemFont(ofSize: 0.02),
                                                                       containerFrame: CGRect.zero,
                                                                       alignment: .left,
                                                                       lineBreakMode: .byCharWrapping),
                                                   materials: [material])
        textEntity.components.set(model)
    }
    
    
    
    // ---------------------------------------------------------------------------------
    // -------------------------- Notification OBSERVER --------------------------------
    func createObserver() {
        let notifName = Notification.Name(rawValue: cbNotificationKey)
        NotificationCenter.default.addObserver(self, selector: #selector(updateCoulombValue(notification:)), name: notifName, object: nil)
    }
    
    @objc func updateCoulombValue(notification: Notification) {
        if let newValue = (notification.userInfo?["updatedValue"]) as? Float {
            loadText(textEntity: longPressedEntity.children[1], material: coulombTextMaterial, coulombStringValue: "\(newValue) Cb")
        } else {
            print("Error: updated coulomb value")
        }
        
    }
    
    
    // ---------------------------------------------------------------------------------
    // -------------------------- Add FORCE (Obj & Entity) -----------------------------
    func addForces() {
        arView.scene.anchors.forEach{ anchor in
            if anchor.name == "Point Charge Scene AnchorEntity" {
                
                let arrowAnchor = try! Experience.loadBox()
                let arrowEntity = arrowAnchor.arrow!
                
                // Add a Force Object and Entity for every pointCharge<->pointCharge combo
                pointCharges.forEach{ pointChargeObj in
                    pointCharges.forEach{ otherPointChargeObj in
                        if pointChargeObj.id != otherPointChargeObj.id {
                            
                            let arrow = arrowEntity.clone(recursive: true)
                            pointChargeObj.entity.addChild(arrow)
                            
                            /// Create instance of Force with arrow entity
                            let force = Force(magnetude: 5, entity: arrow, from: otherPointChargeObj.entity, to: pointChargeObj.entity)
                            forces.append(force)
                        }
                    }
                }
            
                updateArrows()
            }
        }
    }
    
    
    
    // ---------------------------------------------------------------------------------
    // -------------------------- Update FORCES ARROWS ---------------------------------
    func updateArrows() {
        forces.forEach{ forceObj in
            let from = forceObj.sourceEntity
            let at = forceObj.targetEntity
            let arrow = forceObj.entity
            
            /// First set look(at:_) cause it reinitialize the scale. Then set the scale x 0.1 and the position again
            /// to the center of the pointCharge.
            /// CAREFUL: The arrow entity points with its tail, so reverse the look direction to get what you want
            arrow.look(at: from.position, from: at.position, relativeTo: at)
            arrow.setScale(SIMD3<Float>(0.1, 0.1, 0.1), relativeTo: arrow)
            arrow.setPosition(SIMD3<Float>(0, 0, 0), relativeTo: at)
            arrow.setOrientation(simd_quatf(angle: 180.degreesToRadians(), axis: SIMD3<Float>(0, 1.0, 0)), relativeTo: arrow)
        }
                    
        
    }
    
    // ---------------------------------------------------------------------------------
    // -------------------------- pointCharge INTERACTION ------------------------------
    // Emphasize or Deemphasize
    func pointChargeInteraction(zoom: Float, showLabel: Bool) {
        /// (De))emphasize the Point Charge by scaling it down/up 50%
        trackedEntity.setScale(SIMD3<Float>(zoom, zoom, zoom), relativeTo: trackedEntity)
        /// Show/Hide the value label
        trackedEntity.children.forEach{ child in
            if child.name == "text" {
                child.isEnabled = showLabel
            }
        }
    }
    
    //    // Add  Coaching View to help user
    //    func overlayCoachingView() {
    //        let coachingView = ARCoachingOverlayView(frame: CGRect(x: 0, y:0, width: arView.frame.width, height: arView.frame.height))
    //
    //        coachingView.session = arView.session
    //        coachingView.activatesAutomatically = true
    //        coachingView.goal = .horizontalPlane
    //
    //        view.addSubview(coachingView)
    //    }
    
}

extension Int {
    func degreesToRadians() -> Float {
        return Float(self) * Float.pi / 180.0
    }
}

