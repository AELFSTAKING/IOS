//
//  JockeyWebController+Browser.swift
//  AELFExchange
//
//  Created by tng on 2019/3/21.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import Foundation
import UIKit

class JockeyWebController_Browser: JockeyWebController {
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.uiSetup()
        self.signalSetup()
    }
    
    // MARK: - Custom Accessors
    
    // MARK: - IBActions
    @objc private func backPressed() {
        if self.webView.canGoBack {
            self.webView.goBack()
        } else {
            self.closePressed()
        }
    }
    
    @objc private func closePressed() {
        self.pop()
    }
    
    // MARK: - Public
    
    // MARK: - Private
    private func uiSetup() -> Void {
        let backItem = UIBarButtonItem(
            image: UIImage(named: "icon-backarrow"),
            style: .plain,
            target: self,
            action: #selector(self.backPressed)
        )
        backItem.imageInsets = UIEdgeInsets(top: 0, left: -6.5, bottom: 0, right: 6.5)
        let closeItem = UIBarButtonItem(
            title: LOCSTR(withKey: "关闭"),
            style: .plain,
            target: self,
            action: #selector(self.closePressed)
        )
        closeItem.setTitleTextAttributes([NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15.0)], for: .normal)
        self.navigationItem.leftBarButtonItems = [backItem, closeItem]
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
