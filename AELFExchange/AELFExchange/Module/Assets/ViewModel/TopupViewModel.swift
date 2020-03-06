//
//  TopupViewModel.swift
//  AELFExchange
//
//  Created by tng on 2019/8/4.
//  Copyright © 2019 cex.io. All rights reserved.
//

import Foundation

enum TopupModeEnum {
    
    /// 跨链充值.
    case topup
    
    /// 收款.
    case receive
    
}

@objc class TopupViewModel: NSObject {
    
    var mode = TopupModeEnum.topup
    
    var chain: String?
    var currency: String?
    
    @objc dynamic var topupAddress = "..."
    
    @objc dynamic var boundAddressList = NSMutableArray()
    
    func load() {
        if self.mode == .topup {
            self.loadTopupAddress()
            self.loadBoundTopupAddresses()
        } else {
            self.topupAddress = AELFIdentity.wallet_eth?.address ?? "--"
        }
    }
    
    private func loadTopupAddress() {
        let params = [
            "currency":self.chain ?? "",
        ]
        Network.post(withUrl: URLs.shared().genUrl(with: .topupAddress), params: params, to: PlatformTopupAddrResponse.self) { [weak self] (succeed, response) in
            guard succeed == true, response.succeed == true, let address = response.data?.address else {
                InfoToast(withLocalizedTitle: response.msg)
                return
            }
            self?.topupAddress = address
        }
    }
    
    private func loadBoundTopupAddresses() {
        UserInfoManager.shared().boundAddressList(forChain: self.chain ?? "", currency: self.currency ?? "") { (data) in
            if let data = data {
                self.boundAddressList.removeAllObjects()
                self.mutableArrayValue(forKey: "boundAddressList").addObjects(from: data)
            }
        }
    }
    
}
