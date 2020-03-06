//
//  AboutVC.swift
//  AELFExchange
//
//  Created by tng on 2019/1/18.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import Foundation
import UIKit

class AboutVC: BaseViewController {
    
    @IBOutlet weak var bgView1: View!
    @IBOutlet weak var bgView2: View!
    @IBOutlet weak var versionNumberLabel: Label!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.uiSetup()
        self.signalSetup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    // MARK: - Custom Accessors
    
    // MARK: - IBActions
    @IBAction func privacyPressed(_ sender: Any) {
        let web = WebPage(fileName: LanguageManager.shared().currentLanguage() == .ZH_HANS ? "privacy":"privacy-en", as: LOCSTR(withKey: "隐私政策"))
        web.customBackgroundColor = .white
        self.push(to: web, animated: true)
    }
    
    @IBAction func termsPressed(_ sender: Any) {
        let web = WebPage(fileName: LanguageManager.shared().currentLanguage() == .ZH_HANS ? "terms":"terms-en", as: LOCSTR(withKey: "服务协议"))
        web.customBackgroundColor = .white
        self.push(to: web, animated: true)
    }
    
    // MARK: - Public
    
    // MARK: - Private
    private func uiSetup() -> Void {
        self.title = LOCSTR(withKey: "关于我们")
        self.bgView1.backgroundColor = kThemeColorBackgroundCellItem
        self.bgView2.backgroundColor = self.bgView1.backgroundColor
        if let version = Bundle.main.versionNumber {
            self.versionNumberLabel.text = "V \(version)"
        } else {
            self.versionNumberLabel.text = nil
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
