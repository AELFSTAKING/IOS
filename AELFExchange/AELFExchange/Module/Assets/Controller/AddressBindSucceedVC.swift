//
//  AddressBindSucceedVC.swift
//  AELFExchange
//
//  Created by tng on 2019/7/29.
//  Copyright © 2019 cex.io. All rights reserved.
//

import Foundation

class AddressBindSucceedVC: BaseViewController {
    
    var chain: String?
    var currency: String?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.uiSetup()
        self.signalSetup()
    }
    
    // MARK: - Custom Accessors
    
    // MARK: - IBActions
    @IBAction func goTopupPressed(_ sender: Any) {
        guard let chain = self.chain, let currency = self.currency else {
            InfoToast(withLocalizedTitle: "信息错误")
            self.pop()
            return
        }
        let controller = UIStoryboard(name: "Assets", bundle: nil).instantiateViewController(withIdentifier: "topup") as! TopupVC
        controller.viewModel.mode = .topup
        controller.viewModel.chain = chain
        controller.viewModel.currency = currency
        self.push(to: controller, animated: true)
    }
    
    // MARK: - Public
    
    // MARK: - Private
    private func uiSetup() -> Void {
        self.title = LOCSTR(withKey: "绑定成功")
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
