//
//  UserInfoManager.swift
//  AELFExchange
//
//  Created by tng on 2019/1/15.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import Foundation
import UIKit

class UserInfoManager {
    
    fileprivate static let ___donotUseThisVariableOfUserInfoManager = UserInfoManager()
    
    @discardableResult
    static func shared() -> UserInfoManager {
        return UserInfoManager.___donotUseThisVariableOfUserInfoManager
    }
    
}

// MARK: - Asset and Wallet.
extension UserInfoManager {
    
    /// 资产详情.
    ///
    /// - Parameters:
    ///   - currency: .
    ///   - completion: assets detail info of given currency.
    func asset(forCurrency currency: String, completion: @escaping ((TotalAssetsDataItem?) -> ())) {
        guard let address = AELFIdentity.wallet_eth?.address, currency.count > 0 else {
            completion(nil)
            return
        }
        Network.post(withUrl: URLs.shared().genUrl(with: .allAssets), params: ["address":address], withoutDataField: true, to: TotalAssetsResponse.self) { (succeed, response) in
            guard let list = response.data?.currencyList else {
                completion(nil)
                return
            }
            for case let item in list where item.currency?.uppercased().removeTokenPrefix() == currency {
                completion(item)
                break
            }
        }
    }
    
    /// 已绑定的跨链充值地址列表.
    ///
    /// - Parameters:
    ///   - chain: .
    ///   - currency: .
    ///   - completion: [...]
    func boundAddressList(forChain chain: String, currency: String, completion: @escaping (([BindAddressListDataItem]?) -> ())) {
        guard let address = AELFIdentity.wallet_eth?.address, chain.count > 0, currency.count > 0 else {
            completion(nil)
            return
        }
        let params = [
            "platformAddress":address,
            "bindChain":currency.uppercased().contains(AELFCurrencyName.BTC.rawValue) ? AELFChainName.Bitcoin.rawValue:chain,
            "bindCurrency":currency.uppercased().removeTokenPrefix()
        ]
        Network.post(withUrl: URLs.shared().genUrl(with: .bindAddressList), params: params, to: BindAddressListResponse.self) { (succeed, response) in
            guard let list = response.data?.addressList else {
                completion(nil)
                return
            }
            completion(list)
        }
    }
    
}
