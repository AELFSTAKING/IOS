//
//  ExportPrivateKeyVC.swift
//  AELFExchange
//
//  Created by tng on 2019/7/26.
//  Copyright © 2019 cex.io. All rights reserved.
//

import Foundation

class ExportPrivateKeyVC: BaseViewController {
    
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var privateKeyLabel: UILabel!
    
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
    @IBAction func addressCopy(_ sender: Any) {
        guard let text = self.addressLabel.text else {
            InfoToast(withLocalizedTitle: "信息错误")
            return
        }
        UIPasteboard.general.string = text
        InfoToast(withLocalizedTitle: "复制成功")
    }
    
    @IBAction func privateKeyCopy(_ sender: Any) {
        guard let text = self.privateKeyLabel.text else {
            InfoToast(withLocalizedTitle: "信息错误")
            return
        }
        UIPasteboard.general.string = text
        InfoToast(withLocalizedTitle: "复制成功")
    }
    
    @IBAction func confirmPressed(_ sender: Any) {
        self.pop()
    }
    
    // MARK: - Public
    
    // MARK: - Private
    private func uiSetup() -> Void {
        self.title = LOCSTR(withKey: "导出ETH私钥")
        self.addressLabel.text = AELFIdentity.wallet_eth?.address
        self.privateKeyLabel.text = AELFIdentity.wallet_eth?.privateKey
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
