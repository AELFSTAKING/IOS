//
//  LanguageSettingVC.swift
//  AELFExchange
//
//  Created by tng on 2019/7/5.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import Foundation
import UIKit

class LanguageSettingVC: BaseViewController {
    
    @IBOutlet weak var chStatusButton: UIButton!
    @IBOutlet weak var enStatusButton: UIButton!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.uiSetup()
        self.signalSetup()
    }
    
    // MARK: - Custom Accessors
    
    // MARK: - IBActions
    @IBAction func chPressed(_ sender: Any) {
        guard (sender as! UIButton).isSelected == false else { return }
        LanguageManager.shared().setLanguage(with: .ZH_HANS)
        self.loadLanguage()
    }
    
    @IBAction func enPressed(_ sender: Any) {
        guard (sender as! UIButton).isSelected == false else { return }
        LanguageManager.shared().setLanguage(with: .EN)
        self.loadLanguage()
    }
    
    // MARK: - Public
    
    // MARK: - Private
    private func uiSetup() -> Void {
        self.title = LOCSTR(withKey: "语言")
        self.loadLanguage()
    }
    
    private func signalSetup() -> Void {
        
    }
    
    private func loadLanguage() {
        self.chStatusButton.isSelected = false
        self.enStatusButton.isSelected = false
        if LanguageManager.shared().currentLanguage() == .ZH_HANS {
            self.chStatusButton.isSelected = true
        } else if LanguageManager.shared().currentLanguage() == .EN {
            self.enStatusButton.isSelected = true
        }
        self.title = LOCSTR(withKey: "语言")
    }
    
    // MARK: - Signal
    
    // MARK: - Protocol conformance
    
    // MARK: - UITextFieldDelegate
    
    // MARK: - UITableViewDataSource
    
    // MARK: - UITableViewDelegate
    
    // MARK: - NSCopying
    
    // MARK: - NSObject
    
}
