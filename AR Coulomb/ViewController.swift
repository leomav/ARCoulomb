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

// MARK: - Global Properties

let cbNotificationKey = "com.leomav.coulombValueChange"
let topoNotificationKey = "com.leomav.topologyChange"
let removalNotificationKey = "com.leomav.coulombRemoval"
let dismissalNotificationKey = "com.leomav.coulombMenuDismissal"

///// Add object Interaction and Gestures
//var virtualObjectInteraction: VirtualObjectInteraction?

/// PointCharge
var selectedPointChargeObj: PointChargeClass = PointChargeClass(onEntity: Entity(), withValue: 0)
var longPressedEntity: Entity = Entity()
var trackedEntity: Entity = Entity()

/// Coulomb Text Material
let coulombTextMaterial: SimpleMaterial = {
    var mat = SimpleMaterial()
    mat.metallic = MaterialScalarParameter(floatLiteral: 0.2)
    mat.roughness = MaterialScalarParameter(floatLiteral: 0.1)
    mat.tintColor = UIColor.white
    return mat
}()

/// Captured Image for saving
var capturedImage: UIImage = UIImage()

let ZOOM_IN_5_4: Float = 1.25
let ZOOM_OUT_4_5: Float = 0.8

let Ke: Float = 9 * pow(10, 9)

// MARK: - ViewController (main)

class ViewController: UIViewController, UIGestureRecognizerDelegate {
    
    // MARK: - IBOutlets
    
    @IBOutlet var arView: ARView!
    
    let shutterView: UIView = {
        let view = UIView()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    let messagePanel: UIView = {
        let panel = UIView()
        
        panel.translatesAutoresizingMaskIntoConstraints = false
        
        return panel
    }()
    
    let messageLabel: UIPaddingLabel = {
        let label = UIPaddingLabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    let restartExperienceButton: UIButton = {
        let btn = UIButton()
        
        btn.translatesAutoresizingMaskIntoConstraints = false
        
        btn.addTarget(self, action: #selector(restartExperience(sender:)), for: .touchUpInside)
        
        
        return btn
    }()
    @objc
    func restartExperience(sender: UIButton) {
        self.restartExperience()
    }
    
    let stackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        
        return stack
    }()
    
    let cancelCaptureButton: UIButton = {
        let btn = UIButton()
        
        btn.translatesAutoresizingMaskIntoConstraints = false
        
        btn.addTarget(self, action: #selector(goBack(sender:)), for: .touchUpInside)
        
        
        return btn
    }()
    
    @objc
    func goBack(sender: UIButton){
        // - TODO:
        self.transitionStackViewMenu(to: "main")
    }
    
    let captureButton: UIButton = {
        let btn = UIButton()
        
        btn.translatesAutoresizingMaskIntoConstraints = false
        
        btn.addTarget(self, action: #selector(captureSnapshot(sender:)), for: .touchUpInside)
        
        
        return btn
    }()
    
    @objc
    func captureSnapshot(sender: UIButton) {
        
        /// Hide all subviews (buttons, labels)
        //        self.toggleAllSubviews(of: self.arView, hide: true)
        
        self.shutterView.alpha = 1
        self.shutterView.isHidden = false
        UIView.animate(withDuration: 1.0, animations: {
            self.shutterView.alpha = 0
        }) { (finished) in
            self.shutterView.isHidden = true
            
            //            let rect = CGRect(x: 0, y: 0, width: self.cameraView.bounds.width, height: self.cameraView.bounds.height - 30)
            let screenshot = self.arView.snapshot()
            capturedImage = screenshot
            
            // performSeague to CapturedImageViewController
            self.performSegueToCapturedImageVC(image: screenshot)
        }
    }
    
    let saveButton: UIButton = {
        let btn = UIButton()
        
        btn.translatesAutoresizingMaskIntoConstraints = false
        
        btn.addTarget(self, action: #selector(openCaptureMenu(sender:)), for: .touchUpInside)
        
        return btn
    }()
    
    @objc
    func openCaptureMenu(sender: UIButton) {
        self.transitionStackViewMenu(to: "camera")
    }
    
    let newTopoButton: UIButton = {
        let btn = UIButton()
        
        btn.translatesAutoresizingMaskIntoConstraints = false
        
        btn.addTarget(self, action: #selector(confirmSeagueToTopoMenu(sender:)), for: .touchUpInside)
        
        return btn
    }()
    
    @objc
    func confirmSeagueToTopoMenu(sender: UIButton) {
        Alert.showSeagueToTopoMenuConfirmation(on: self)
    }
    
    let addButton: UIButton = {
        let btn = UIButton()
        
        btn.translatesAutoresizingMaskIntoConstraints = false
        
        btn.addTarget(self, action: #selector(performAddition(sender:)), for: .touchUpInside)
        
        return btn
    }()
    
    @objc
    func performAddition(sender: UIButton) {
        
        self.status?.cancelScheduledMessage(for: .contentPlacement)
        
        self.topology?.addPointChargeWithRandomPosition()
    }
    
    // MARK: - UI Elements
    
    let coachingOverlay = ARCoachingOverlayView()
    
    /// Marks if the AR experience is available for restart.
    var isRestartAvailable = true
    
    /// Menu Dictionary for Main or Capture Buttons Menu in StackView
    var menuDict:[String:[UIButton]]?
    
    var status: Status?
    
    // MARK: - Properties
    
    var topology: Topology?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.arView.session.delegate = self
        
        /// Intialize status
        self.status = Status(for: self)
        
        self.status!.restartExperienceHandler = { [self] in
            self.restartExperience()
        }
        
        /// Initialize dicitionary
        self.menuDict = [
            "main": [self.saveButton, self.newTopoButton, self.addButton],
            "camera": [self.captureButton, self.cancelCaptureButton]
        ]
        
        /// Set up ARView
        self.setupARView()
        
        /// First tap gesture recognizer, will be deleted after first point of charge is added
        self.setupTapGestureRecognizer()
        
        /// Long Press Recognizer to enable parameters interaction with Point Charge (min press 1 sec)
        self.setupLongPressRecognizer()
        
        /// Set up  the Top Message Panel
        self.configureMessagePanel()
        
        /// Set up the Buttons Stack View in right hand side
        self.configureStackView()
        
        /// Set up the Shutter View (Used for Visual Effect when screenshot happens)
        self.configureShutterView()
        
        /// Set up coaching overlay.
        /// Careful to set it up after setting up the GestureRecognizers.
        self.setupCoachingOverlay()
        
        /// Create the Topology Notification Observer
        self.setupObserverNewTopo()
        
        /// Create the CoulombMenu Dismissal Observer
        self.setupObserverMenuDismissal()
        
        //        /// Set up the Top Guide Text (helper text to place the topology)
        //        self.configureGuideTextView()
    }
    
    // MARK: - Private Setup startup Functions
    
    private func setupARView() {
        self.arView.automaticallyConfigureSession = false
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal, .vertical]
        config.environmentTexturing = .automatic
        
        self.arView.session.run(config, options: [.resetTracking, .removeExistingAnchors])
    }
    
    private func setupTapGestureRecognizer() {
        let firstPointTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer:)))
        firstPointTapRecognizer.name = "First Point Recognizer"
        self.arView.addGestureRecognizer(firstPointTapRecognizer)
    }
    
    private func setupLongPressRecognizer() {
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(recognizer:)))
        longPressRecognizer.name = "Long Press Recognizer"
        longPressRecognizer.minimumPressDuration = 1
        self.arView.addGestureRecognizer(longPressRecognizer)
        longPressRecognizer.isEnabled =  false
    }
    
    // MARK: - Prepare Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toCapturedImageVCSegue" {
            if let capturedImageVC = segue.destination as? CapturedImageVC{
                capturedImageVC.image = capturedImage
            }
        }
    }
    
    // MARK: - Perform Seague
    
    func performSegueToTopoMenu() {
        /// Disable and hide the StackView Buttons (add new pointCharge, add new topo)
        self.toggleStackView(hide: true, animated: false)
        
        self.status?.cancelScheduledMessage(for: .contentPlacement)
        
        /// Open the bottom Coulomb Topology menu to choose topology
        performSegue(withIdentifier: "toTopoMenuSegue", sender: nil)
    }
    
    func performSegueToCapturedImageVC(image: UIImage) {
        performSegue(withIdentifier: "toCapturedImageVCSegue", sender: image)
    }
    
    // MARK: - Restart Experience
    
    func restartExperience() {
        //        guard isRestartAvailable, !virtualObjectLoader.isLoading else { return }
        guard isRestartAvailable else { return }
        isRestartAvailable = false
        
        status!.cancelAllScheduledMessages()
        
        topology?.clearTopology()
        
        resetTracking()
        
        // Disable restart for a while in order to give the session time to restart.
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            self.isRestartAvailable = true
            self.messagePanel.isHidden = false
        }
    }
    
    // MARK: - Reset Tracking
    
    func resetTracking() {
        selectedPointChargeObj = PointChargeClass(onEntity: Entity(), withValue: 0)
        longPressedEntity = Entity()
        trackedEntity = Entity()
        
        self.arView.gestureRecognizers?.first(where: {$0.name == "First Point Recognizer"})?.isEnabled = true
        self.arView.gestureRecognizers?.first(where: {$0.name == "Long Press Recognizer"})?.isEnabled = false
        
        self.setupARView()
        
        self.status?.scheduleMessage("FIND A SURFACE TO PLACE A TOPOLOGY", inSeconds: 7.5, messageType: .planeEstimation)
    }
    
    // MARK: - (De)emphasize the tracked pointCharge Entity
    
    func pointChargeInteract(zoom: Float, showLabel: Bool) {
        /// (De)emphasize the Point Charge by scaling it down/up 0.8/1.25
        trackedEntity.setScale(SIMD3<Float>(zoom, zoom, zoom), relativeTo: trackedEntity)
        /// Show/Hide the value label
        trackedEntity.children.forEach{ child in
            if child.name == "text" {
                child.isEnabled = showLabel
            }
        }
    }
}

// MARK: - CONVERTER: Degrees <--> Radians
extension BinaryInteger {
    func degreesToRadians<F: FloatingPoint>() -> F {  F(self) * .pi / 180 }
}

extension FloatingPoint {
    var degreesToRadians: Self { self * .pi / 180 }
    var radiansToDegrees: Self { self * 180 / .pi }
}

@IBDesignable class UIPaddingLabel: UILabel {
    @IBInspectable var topInset: CGFloat = 8.0
    @IBInspectable var bottomInset: CGFloat = 8.0
    @IBInspectable var leftInset: CGFloat = 8.0
    @IBInspectable var rightInset: CGFloat = 8.0
    
    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets.init(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
        super.drawText(in: rect.inset(by: insets))
    }
    
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + leftInset + rightInset,
                      height: size.height + topInset + bottomInset)
    }
}
