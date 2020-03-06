//
//  AssetsViewModel.swift
//  AELFExchange
//
//  Created by tng on 2019/1/14.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import Foundation
import ReactiveSwift
import Result

@objc class AssetHomeViewModel: NSObject {
    
    let (dataLoadedSignal, dataLoadedObserver) = Signal<Bool, NoError>.pipe()
    
    @objc dynamic var hideAssetsNumber = false
    var assetData: TotalAssetsData?
    var rewardData: RewardSummaryData?
    
    func loadIfNeeded() {
        guard let address = AELFIdentity.wallet_eth?.address else {
            self.loadCurrencyListOnly()
            return
        }
        
        // Assets.
        Network.post(withUrl: URLs.shared().genUrl(with: .allAssets), params: ["address":address], withoutDataField: true, to: TotalAssetsResponse.self, useCache: true, cacheCallback: { [weak self] (succeed, response) in
            self?.handleAssetResponse(with: succeed, response: response)
        }) { [weak self] (succeed, response) in
            self?.handleAssetResponse(with: succeed, response: response)
        }
        
        // Rewards.
        Network.post(withUrl: URLs.shared().genUrl(with: .rewards), params: ["platformAddress":address], to: RewardSummaryResponse.self, useCache: true, cacheCallback: { [weak self] (succeed, response) in
            self?.handleRewardResponse(with: succeed, response: response)
        }) { [weak self] (succeed, response) in
            self?.handleRewardResponse(with: succeed, response: response)
        }
    }
    
    private func loadCurrencyListOnly() {
        Network.post(withUrl: URLs.shared().genUrl(with: .currencyList), params: ["_":""], to: CurrencyListResponse.self, useCache: true, cacheCallback: { [weak self] (succeed, response) in
            self?.handleCurrencyListResponse(with: succeed, response: response)
        }) { [weak self] (succeed, response) in
            self?.handleCurrencyListResponse(with: succeed, response: response)
        }
    }
    
    private func handleAssetResponse(with succeed: Bool, response: TotalAssetsResponse) {
        guard succeed == true, response.succeed == true, let data = response.data else {
            InfoToast(withLocalizedTitle: response.msg)
            return
        }
        self.assetData = data
        self.dataLoadedObserver.send(value: true)
    }
    
    private func handleRewardResponse(with succeed: Bool, response: RewardSummaryResponse) {
        guard succeed == true, response.succeed == true, let data = response.data else {
            InfoToast(withLocalizedTitle: response.msg)
            return
        }
        self.rewardData = data
        self.dataLoadedObserver.send(value: true)
    }
    
    private func handleCurrencyListResponse(with succeed: Bool, response: CurrencyListResponse) {
        guard succeed == true, response.succeed == true, let data = response.data?.list else {
            InfoToast(withLocalizedTitle: response.msg)
            return
        }
        
        let assetData = TotalAssetsData()
        assetData.totalUsdAsset = "--"
        assetData.totalUsdtAsset = "--"
        
        var list = [TotalAssetsDataItem]()
        for item in data {
            let d = TotalAssetsDataItem()
            d.currency = item.alias
            d.balance = "0"
            d.usdtPrice = "0"
            list.append(d)
        }
        assetData.currencyList = list
        self.assetData = assetData
        self.dataLoadedObserver.send(value: true)
    }
    
}
