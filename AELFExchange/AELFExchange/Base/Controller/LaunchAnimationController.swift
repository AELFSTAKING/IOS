//
//  LaunchAnimationController.swift
//  AELFExchange
//
//  Created by tng on 2019/4/8.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher

class LaunchAnimationController: UIViewController {
    
    var completion: (() -> ())?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.uiSetup()
        self.signalSetup()
    }
    
    deinit {
        print("✅\(self) has been destroyed.")
    }
    
    // MARK: - Custom Accessors
    
    // MARK: - IBActions
    
    // MARK: - Public
    
    // MARK: - Private
    private func uiSetup() -> Void {
        self.view.backgroundColor = ColorRGBA(r: 17.0, g: 19.0, b: 42.0, a: 1.0)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        if IsDebug {
            if let callback = self.completion {
                callback()
            }
            return
        }
        
        let imageView = AnimatedImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.repeatCount = .once
        imageView.needsPrescaling = false
        imageView.delegate = self
        imageView.kf.setImage(with: ImageResource(downloadURL: URL(fileURLWithPath: Bundle.main.path(forResource: "launch", ofType: "gif")!)))
        self.view.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    private func signalSetup() -> Void {
        
    }
    
    // MARK: - Signal
    
    // MARK: - Protocol conformance
    
    // MARK: - UITextFieldDelegate
    
    // MARK: - UITableViewDataSource
    
    // MARK: - UITableViewDelegate
    
    // MARK: - NSCopying
    
    // MARK: - NSObject
    
}

extension LaunchAnimationController: AnimatedImageViewDelegate {
    
    func animatedImageViewDidFinishAnimating(_ imageView: AnimatedImageView) {
        if let callback = self.completion {
            callback()
        }
    }
    
}
