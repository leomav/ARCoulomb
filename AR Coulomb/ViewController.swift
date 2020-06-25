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

class PointChargeEntity: Entity, HasModel, HasCollision, HasPhysicsBody {
    required init(color: UIColor, charge: String) {
        super.init()
        self.model = ModelComponent(mesh: .generateSphere(radius: 0.04), materials: [SimpleMaterial(color: color, isMetallic: true)])
        self.name = charge
        self.generateCollisionShapes(recursive: true)
    }
    
    required init() {
        fatalError("init() has not been implemented")
    }
}



class ViewController: UIViewController {
    
    @IBOutlet var arView: ARView!
    
    var pointsChargeScenesDict: [Int: Dictionary<String, [SIMD3<Float>]>] = [
        1: [
            "startingPos": [SIMD3<Float>(-0.1, 0, 0), SIMD3<Float>(0.1, 0, 0)],
            "currentPos": [SIMD3<Float>(-0.1, 0, 0), SIMD3<Float>(0.1, 0, 0)],
            ],
        2: [
            "startingPos": [SIMD3<Float>(-0.1, 0, 0.1), SIMD3<Float>(0.1, 0, 0.1), SIMD3<Float>(0.1, 0, -0.1)],
            "currentPos": [SIMD3<Float>(-0.1, 0, 0.1), SIMD3<Float>(0.1, 0, 0.1), SIMD3<Float>(0.1, 0, -0.1)]
            ],
        3: [
            "startingPos": [SIMD3<Float>(-0.1, 0, 0.1), SIMD3<Float>(-0.1, 0, -0.1), SIMD3<Float>(0.1, 0, 0.1)],
            "currentPos": [SIMD3<Float>(-0.1, 0, 0.1), SIMD3<Float>(-0.1, 0, -0.1), SIMD3<Float>(0.1, 0, 0.1)]
            ],
        4: [
            "startingPos": [SIMD3<Float>(-0.1, 0, 0.1), SIMD3<Float>(-0.1, 0, -0.1), SIMD3<Float>(0.1, 0, 0.1), SIMD3<Float>(0.1, 0, -0.1)],
            "currentPos": [SIMD3<Float>(-0.1, 0, 0.1), SIMD3<Float>(-0.1, 0, -0.1), SIMD3<Float>(0.1, 0, 0.1), SIMD3<Float>(0.1, 0, -0.1)]
            ],
        5: [
            "startingPos": [SIMD3<Float>(-0.1, 0, 0), SIMD3<Float>(0, 0, 0), SIMD3<Float>(0.1, 0, 0)],
            "currentPos": [SIMD3<Float>(-0.1, 0, 0), SIMD3<Float>(0, 0, 0), SIMD3<Float>(0.1, 0, 0)]
            ],
        6: [
            "startingPos": [SIMD3<Float>(-0.2, 0, 0.1), SIMD3<Float>(0, 0, 0.1), SIMD3<Float>(0, 0, -0.1), SIMD3<Float>(0.2, 0, 0.1)],
            "currentPos": [SIMD3<Float>(-0.2, 0, 0.1), SIMD3<Float>(0, 0, 0.1), SIMD3<Float>(0, 0, -0.1), SIMD3<Float>(0.2, 0, 0.1)]
            ]
    ]
    
//    var simpleMaterial = SimpleMaterial()
//    simpleMaterial.metallic = MaterialScalarParameter(floatLiteral: 0.2)
//    simpleMaterial.roughness = MaterialScalarParameter(floatLiteral: 0.1)
//    simpleMaterial.tintColor = UIColor.white
    
    let coulombTextMaterial: SimpleMaterial = {
        var mat = SimpleMaterial()
        mat.metallic = MaterialScalarParameter(floatLiteral: 0.2)
        mat.roughness = MaterialScalarParameter(floatLiteral: 0.1)
        mat.tintColor = UIColor.white
        return mat
    }()
    
    var selectedPositions: [SIMD3<Float>] = []
    
    var startingWorldPosition: SIMD3<Float> = SIMD3<Float>(0, 0, 0)
    
    var trackedEntity: Entity = Entity()
    var tappedEntity: Entity = Entity()
    
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
            let dict = pointsChargeScenesDict[btnsend.tag]!
            selectedPositions.append(contentsOf: dict["startingPos"]!)
        }
    }
    
    
    func placeObject(for anchor: ARAnchor) {
        // Add the anchor of the scene where the user tapped
        let anchorEntity = AnchorEntity(anchor: anchor)
        anchorEntity.name = "Point Charge Scene AnchorEntity"
        arView.scene.addAnchor(anchorEntity)
        
        // Import the Point Charge Model, clone the entity as many times as needed
        let pointChargeAnchor = try! PointCharge.load_PointCharge()
        let pointChargeEntity = pointChargeAnchor.pointCharge!
        
        for pos in selectedPositions {
            let point = pointChargeEntity.clone(recursive: true)
            anchorEntity.addChild(point)
            point.setPosition(pos, relativeTo: anchorEntity)
            
            // Create Text Entity for the particle
            let textEntity = createTextEntity(pointEntity: point)
            // Load the mesh and material for the model of the text entity
            loadText(textEntity: textEntity, material: coulombTextMaterial, coulomb: 1)
            
            // Install gestures
            point.generateCollisionShapes(recursive: false)
            arView.installGestures([.translation, .rotation, .scale], for: point as! HasCollision)
        }
        
        arView.gestureRecognizers?.forEach { recognizer in
            // remove gesture recognizer for the first point of charge
            if recognizer.name == "First Point Recognizer" {
//                arView.removeGestureRecognizer(recognizer)
                recognizer.isEnabled = false
            }
            // enable the point long tap recognizer
            if recognizer.name == "Long Press Recognizer" {
                recognizer.isEnabled = true
            }
            
            // Installed gestures (EntityGesturesRecognizers for each point charge) were cancelling
            // other touches, so turn that to false
            recognizer.cancelsTouchesInView = false
        }
        
    }
    
    
    
    
    // ---------------------------------------------------------------------------------
    // --------------------------- TEXT ENTITY -----------------------------------------
    func createTextEntity(pointEntity: Entity) -> Entity {
        let textEntity: Entity = Entity()
        textEntity.name = "text"
        textEntity.setParent(pointEntity)
        textEntity.setPosition(SIMD3<Float>(-0.02, -0.03, 0.03), relativeTo: pointEntity)

        textEntity.setOrientation(simd_quatf(ix: -0.45, iy: 0, iz: 0, r: 0.9), relativeTo: pointEntity)
        
        return textEntity
    }
    
    func loadText(textEntity: Entity, material: SimpleMaterial, coulomb: Float) {
        let model: ModelComponent = ModelComponent(mesh: .generateText("\(coulomb) Cb",
                                                                       extrusionDepth: 0.003,
                                                                       font: .systemFont(ofSize: 0.02),
                                                                       containerFrame: CGRect.zero,
                                                                       alignment: .left,
                                                                       lineBreakMode: .byCharWrapping),
                                                   materials: [material])
        textEntity.components.set(model)
    }
    
    
    
    
    // ---------------------------------------------------------------------------
    // -------------------- Gesture Recognizer HANDLERS --------------------------
    @objc func handleTap(recognizer: UITapGestureRecognizer) {
        let location = recognizer.location(in: arView)
        
        let results = arView.raycast(from: location, allowing: .estimatedPlane, alignment: .horizontal)
        
        if let firstResult = results.first {
            let anchor = ARAnchor(name: "PointCharge", transform: firstResult.worldTransform)
            arView.session.add(anchor: anchor)
        } else {
            print("No horizontal surface found.")
        }
    }
    
    @objc func handleLongPress(recognizer: UILongPressGestureRecognizer) {
        let location = recognizer.location(in: arView)
        
        guard let hitEntity = arView.entity(at: location) else {return}
        
        if recognizer.state == .began {
            print("long press started")
            
            if hitEntity.name == "pointCharge" {
            }
        }
        
        if recognizer.state == .ended {
            print("long press ended")
            if hitEntity.name == "pointCharge" {
            }
        }
    }
    
    
    
    
    // ---------------------------------------------------------------------------------
    // -------------------------- DRAG & DROP pointCharge ------------------------------
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let location = touches.first?.location(in: arView) else {return}
        guard let hitEntity = arView.entity(at: location) else {return}
        
        if hitEntity.name == "pointCharge" {
            trackedEntity = hitEntity
            
            // Emphasize the pointCharge by scaling it up 50%
            trackedEntity.setScale(SIMD3<Float>(3/2, 3/2, 3/2), relativeTo: trackedEntity)
            // Hide the (text) value (coulomb) label
            trackedEntity.children.forEach{ child in
                if child.name == "text" {
                    child.isEnabled = false
                }
            }
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        //
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        /// If tracked entity is a pointCharge, check if its alignment differ less than 0.05m from the other particles.
        /// If so, align it to them
        if trackedEntity.name == "pointCharge" {
            /// De emphasize the Point Charge by scaling it down 50%
            trackedEntity.setScale(SIMD3<Float>(2/3, 2/3, 2/3), relativeTo: trackedEntity)
            /// Bring back the value label
            trackedEntity.children.forEach{ child in
                if child.name == "text" {
                    child.isEnabled = true
                }
            }
            
            let x = trackedEntity.position.x
            let z = trackedEntity.position.z
            
            /// Loop through the scene anchors to find our "Point Charge Scene Anchor"
            arView.scene.anchors.forEach{ anchor in
                if anchor.name == "Point Charge Scene AnchorEntity" {
                    /// Loop through its children (pointChargeEntities) and check their (x, z) differences
                    anchor.children.forEach{ child in
                        if child.position.x != x && child.position.z != z{
                            if abs(child.position.x - x) < 0.05 {
                                trackedEntity.position.x = child.position.x
                            }
                            if abs(child.position.z - z) < 0.05 {
                                trackedEntity.position.z = child.position.z
                            }
                        }
                    }
                }
            }
            /// When touches end, no entity is tracked by the gesture
            trackedEntity = Entity()
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



extension ViewController: ARSessionDelegate {
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        for anchor in anchors {
            if let anchorName = anchor.name, anchorName == "PointCharge" {
                
                placeObject(for: anchor)
            }
        }
        
        
    }
}
