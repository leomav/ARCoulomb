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
        UIImageWriteToSavedPhotosAlbum(image!, nil, nil, nil)
    }
    
    // MARK: - UI Elements
    
    var image: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.capturedImageView.addSubview(self.stackView)
        
        self.configureStackView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        /// Set background the captured image
        self.capturedImageView.backgroundColor = UIColor(patternImage: image!)
    }
    
    func configureStackView() {
        
        self.stackView.axis = .horizontal
        
        self.stackView.leadingAnchor.constraint(equalTo: self.capturedImageView.leadingAnchor).isActive = true
        self.stackView.topAnchor.constraint(equalTo: self.capturedImageView.topAnchor, constant: -150).isActive = true
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
        btn.isHidden = true
        
//        btn.widthAnchor.constraint(equalToConstant: CGFloat(150)).isActive = true
    }
    
}
