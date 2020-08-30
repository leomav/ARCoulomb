//
//  CameraVC.swift
//  AR Coulomb
//
//  Created by Leonidas Mavrotas on 30/8/20.
//  Copyright © 2020 Leonidas Mavrotas. All rights reserved.
//

import UIKit

class CameraVC: UIViewController {
    
    // MARK: - UI IBOutlets
    
    @IBOutlet var cameraView: UIView!
    
    let shutterView: UIView = {
        let view = UIView()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    let captureButton: UIButton = {
        let btn = UIButton()
        
        btn.translatesAutoresizingMaskIntoConstraints = false
        
        return btn
    }()
    
    let imageView: UIImageView = {
        let image = UIImageView()
        
        image.translatesAutoresizingMaskIntoConstraints = false
        
        return image
    }()
    
    // MARK: - UI Configurations
    
    func configureShutterView() {
        self.cameraView.addSubview(shutterView)
        
        /// At first, shutter view is total trasparent ...
        self.shutterView.backgroundColor = UIColor(white: 1, alpha: 0)
        
        self.shutterView.leadingAnchor.constraint(equalTo: self.cameraView.leadingAnchor).isActive = true
        self.shutterView.topAnchor.constraint(equalTo: self.cameraView.topAnchor).isActive = true
        self.shutterView.trailingAnchor.constraint(equalTo: self.cameraView.leadingAnchor).isActive = true
        self.shutterView.bottomAnchor.constraint(equalTo: self.cameraView.bottomAnchor).isActive = true
        
        /// ... and also Hidden
        self.shutterView.isHidden = true
    }
    
    func configureImageView() {
        self.cameraView.addSubview(imageView)
        
        self.imageView.centerXAnchor.constraint(equalTo: self.cameraView.centerXAnchor).isActive = true
        self.imageView.centerYAnchor.constraint(equalTo: self.cameraView.centerYAnchor).isActive = true
        self.imageView.heightAnchor.constraint(equalTo: self.cameraView.heightAnchor, constant: -50).isActive = true
        self.imageView.widthAnchor.constraint(equalTo: self.cameraView.widthAnchor, constant: -30).isActive = true
        
        self.imageView.isHidden = true
    }
    
    func configureCaptureButton(height: Float) {
        let config = UIImage.SymbolConfiguration(pointSize: 30, weight: .light, scale: .large)
        
//        let image = UIImageView(image: UIImage(systemName: "plus", withConfiguration: config))
        let image = UIImage(systemName: "camera.viewfinder", withConfiguration: config)
        
        self.captureButton.setImage(image, for: .normal)
        
        let padding: CGFloat = 8.0
        self.captureButton.contentEdgeInsets = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
        
        self.captureButton.addTarget(self, action: #selector(captureSnapshot(sender:)), for: .touchUpInside)
        
        self.captureButton.layer.cornerRadius = 10
        //        self.addButton.imageView?.clipsToBounds = true
        
        self.captureButton.tintColor = UIColor.white
        self.captureButton.backgroundColor = UIColor(white: 0, alpha: 0.7)
        
        self.captureButton.heightAnchor.constraint(equalToConstant: CGFloat(height)).isActive = true
        
        self.captureButton.bottomAnchor.constraint(equalTo: self.shutterView.bottomAnchor, constant: -20).isActive = true
    }
    
    @objc
    func captureSnapshot(sender: UIButton) {
        
        self.shutterView.alpha = 1
        self.shutterView.isHidden = false
        UIView.animate(withDuration: 1.0, animations: {
            self.shutterView.alpha = 0
        }) { (finished) in
            self.shutterView.isHidden = true
            
//            let rect = CGRect(x: 0, y: 0, width: self.cameraView.bounds.width, height: self.cameraView.bounds.height - 30)
            let screenshot = self.cameraView.snapshot()
            UIImageWriteToSavedPhotosAlbum(screenshot, nil, nil, nil)
        }
    }
}

extension UIView {

    /// Create image snapshot of view.
    ///
    /// - Parameters:
    ///   - rect: The coordinates (in the view's own coordinate space) to be captured. If omitted, the entire `bounds` will be captured.
    ///   - afterScreenUpdates: A Boolean value that indicates whether the snapshot should be rendered after recent changes have been incorporated. Specify the value false if you want to render a snapshot in the view hierarchy’s current state, which might not include recent changes. Defaults to `true`.
    ///
    /// - Returns: The `UIImage` snapshot.

    func snapshot(of rect: CGRect? = nil, afterScreenUpdates: Bool = true) -> UIImage {
        return UIGraphicsImageRenderer(bounds: rect ?? bounds).image { _ in
            drawHierarchy(in: bounds, afterScreenUpdates: afterScreenUpdates)
        }
    }
}
