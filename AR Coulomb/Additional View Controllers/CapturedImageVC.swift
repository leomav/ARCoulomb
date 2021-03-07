//
//  CapturedImageVC.swift
//  AR Coulomb
//
//  Created by Leonidas Mavrotas on 30/8/20.
//  Copyright © 2020 Leonidas Mavrotas. All rights reserved.
//

import UIKit

class CapturedImageVC: UIViewController {
    
    @IBOutlet var capturedImageView: UIView!
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()
    
    let stackView: UIStackView = {
        let stack = UIStackView()
        
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        return stack
    }()
    
    let cancelButton: UIButton = {
        let btn = UIButton()
        
        btn.translatesAutoresizingMaskIntoConstraints = false
        
        btn.addTarget(self, action: #selector(cancelSaveTopology(sender:)), for: .touchUpInside)
        
        return btn
    }()
    
    @objc
    func cancelSaveTopology(sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    let saveButton: UIButton = {
        let btn = UIButton()
        
        btn.translatesAutoresizingMaskIntoConstraints = false
        
        btn.addTarget(self, action: #selector(saveTopology(sender:)), for: .touchUpInside)

        return btn
    }()
    
    @objc
    func saveTopology(sender: UIButton) {
        /// Save topo to Core Data
        //if let imageData = image!.pngData() {
        //    DataBaseHelper.shareInstance.saveTopologyToCoreData(topoDescription: "Some Description", imageData: imageData, topoName: "Some Name", completion: topoSavedFeedback)
        //}
        
        /// Handle
        self.dismiss(animated: true, completion: {
            /// Notify the observer (view controller) and pass the image binary data
            let notifName = Notification.Name(rawValue: photoTakenNotificationKey)
            let valueDict: [String: Data] = ["imageData": self.image!.pngData()!]
            NotificationCenter.default.post(name: notifName, object: nil, userInfo: valueDict)
        })
        
        /// Handle
        // topoSavedFeedback(valid: true, message: "")
        
        /// Save image to specific album
        //CustomPhotoAlbum.sharedInstance.saveImage(image: image!)
        /// Save image to photo album
        //UIImageWriteToSavedPhotosAlbum(image!, self, #selector(imageFeedback(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    // !!! NOT USED with core data -> replaced with a simple dismiss
    /// Completion method for after trying to save topology
    func topoSavedFeedback(valid: Bool, message: String)  {
        if valid == true {
            let ac = UIAlertController(title: "Saved!", message: "Your altered image has been saved to your photos.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default, handler: { (UIAlertAction) in
                self.dismiss(animated: true, completion: nil)
            }))
            present(ac, animated: true)
        } else {
            // we got back an error!
            let ac = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default, handler: { (UIAlertAction) in
                self.dismiss(animated: true, completion: nil)
            }))
            present(ac, animated: true)
        }
    }
    
    // !!! NOT USED with core data -> replaced with topoSavedFeedback
    /// Selector method used for completion after image save operation happens.
    @objc
    func imageFeedback(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            let ac = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default, handler: { (UIAlertAction) in
                self.dismiss(animated: true, completion: nil)
            }))
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "Saved!", message: "Your altered image has been saved to your photos.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default, handler: { (UIAlertAction) in
                self.dismiss(animated: true, completion: nil)
            }))
            present(ac, animated: true)
        }
        
    }
    
    // MARK: - UI Elements
    
    var image: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.configureImageView()
        
        self.configureStackView()
        
    }
    
    
    func configureImageView() {
        self.capturedImageView.addSubview(self.imageView)
        
        self.imageView.image = self.image
        
        self.imageView.leadingAnchor.constraint(equalTo: self.capturedImageView.leadingAnchor).isActive = true
        self.imageView.topAnchor.constraint(equalTo: self.capturedImageView.topAnchor).isActive = true
        self.imageView.trailingAnchor.constraint(equalTo: self.capturedImageView.trailingAnchor).isActive = true
        self.imageView.bottomAnchor.constraint(equalTo: self.capturedImageView.bottomAnchor).isActive = true
    }
    
    func configureStackView() {
        self.capturedImageView.addSubview(self.stackView)

        self.stackView.axis = .horizontal
        
        self.stackView.distribution = .fillEqually
        
        self.stackView.leadingAnchor.constraint(equalTo: self.capturedImageView.leadingAnchor).isActive = true
        self.stackView.topAnchor.constraint(equalTo: self.capturedImageView.bottomAnchor, constant: -150).isActive = true
        self.stackView.trailingAnchor.constraint(equalTo: self.capturedImageView.trailingAnchor).isActive = true
        self.stackView.bottomAnchor.constraint(equalTo: self.capturedImageView.bottomAnchor, constant: -50).isActive = true
        
        self.configureButton(for: self.cancelButton, title: "Cancel")
        self.configureButton(for: self.saveButton, title: "Save")

        self.stackView.addArrangedSubview(cancelButton)
        self.stackView.addArrangedSubview(saveButton)
    }
    func configureButton(for btn: UIButton, title: String) {
        
        let padding: CGFloat = 8.0
        btn.contentEdgeInsets = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
        
        btn.setTitle(title, for: .normal)
        btn.contentHorizontalAlignment = .center
        btn.tintColor = UIColor.white
        btn.backgroundColor = UIColor(white: 0, alpha: 0.7)
        btn.isHidden = false
        btn.isEnabled = true
        
    }
    
}
