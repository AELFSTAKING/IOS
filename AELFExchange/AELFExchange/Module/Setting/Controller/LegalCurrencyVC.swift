//
//  LegalCurrencyVC.swift
//  AELFExchange
//
//  Created by tng on 2019/1/17.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import Foundation
import UIKit

class LegalCurrencyVC: BaseViewController {
    
    @IBOutlet weak var usdLabel: Label!
    @IBOutlet weak var cnyLabel: Label!
    @IBOutlet weak var kroLabel: Label!
    @IBOutlet weak var japLabel: Label!
    @IBOutlet weak var usdButton: UIButton!
    @IBOutlet weak var cnyButton: UIButton!
    @IBOutlet weak var krwButton: UIButton!
    @IBOutlet weak var jpyButton: UIButton!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.uiSetup()
        self.signalSetup()
        
        if CurrencyManager.shared().legalCurrency == "USD" {
            self.usdPressed(self.usdButton as Any)
        } else if CurrencyManager.shared().legalCurrency == "CNY" {
            self.cnyPressed(self.cnyButton as Any)
        } else if CurrencyManager.shared().legalCurrency == "KRW" {
            self.krwPressed(self.krwButton as Any)
        } else if CurrencyManager.shared().legalCurrency == "JPY" {
            self.jpyPressed(self.jpyButton as Any)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    // MARK: - Custom Accessors
    
    // MARK: - IBActions
    @IBAction func usdPressed(_ sender: Any) {
        self.usdButton.isSelected = true
        self.cnyButton.isSelected = false
        self.krwButton.isSelected = false
        self.jpyButton.isSelected = false
        CurrencyManager.shared().legalCurrency = "USD"
        CurrencyManager.shared().legalCurrencySymbol = "$"
    }
    
    @IBAction func usdGesPressed(_ sender: Any) {
        self.usdPressed(self.usdButton as Any)
    }
    
    @IBAction func cnyPressed(_ sender: Any) {
        self.usdButton.isSelected = false
        self.cnyButton.isSelected = true
        self.krwButton.isSelected = false
        self.jpyButton.isSelected = false
        CurrencyManager.shared().legalCurrency = "CNY"
        CurrencyManager.shared().legalCurrencySymbol = "￥"
    }
    
    @IBAction func cnyGesPressed(_ sender: Any) {
        self.cnyPressed(self.cnyButton as Any)
    }
    
    @IBAction func krwPressed(_ sender: Any) {
        self.usdButton.isSelected = false
        self.cnyButton.isSelected = false
        self.krwButton.isSelected = true
        self.jpyButton.isSelected = false
        CurrencyManager.shared().legalCurrency = "KRW"
        CurrencyManager.shared().legalCurrencySymbol = "₩"
    }
    
    @IBAction func krwGesPressed(_ sender: Any) {
        self.krwPressed(self.krwButton as Any)
    }
    
    @IBAction func jpyPressed(_ sender: Any) {
        self.usdButton.isSelected = false
        self.cnyButton.isSelected = false
        self.krwButton.isSelected = false
        self.jpyButton.isSelected = true
        CurrencyManager.shared().legalCurrency = "JPY"
        CurrencyManager.shared().legalCurrencySymbol = "¥"
    }
    
    @IBAction func jpyGesPresseed(_ sender: Any) {
        self.jpyPressed(self.jpyButton as Any)
    }
    
    // MARK: - Public
    
    // MARK: - Private
    private func uiSetup() -> Void {
        self.title = LOCSTR(withKey: "汇率")
        self.usdLabel.text = "$ \(LOCSTR(withKey: "美元"))(USD)";
        self.cnyLabel.text = "¥ \(LOCSTR(withKey: "人民币"))(CNY)";
        self.kroLabel.text = "₩ \(LOCSTR(withKey: "韩元"))(KRW)";
        self.japLabel.text = "¥ \(LOCSTR(withKey: "日元"))(JPY)";
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
