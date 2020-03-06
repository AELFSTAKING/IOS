//
//  MarketListVC+Subscriber.swift
//  AELFExchange
//
//  Created by tng on 2019/6/20.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import Foundation
import UIKit

extension MarketListVC {
    
    func startReceivingMarketData() -> Void {
        self.startReceivingAreaListedMarketData()
        self.startReceivingAreaGroupedMarketData()
    }
    
    func startReceivingAreaListedMarketData() -> Void {
        MQTTManager.shared().sub(on: .mqtopicMarketGrouped, params: [], convertTo: MQTTGroupedMarketResponse.self) { [weak self] (response) in
//            guard self?.isAppeared == true else { return }
//            guard response.succeed == true, let data = response.data else { return }
//            self?.viewModel.handleGroupPushData(data)
        }
    }
    
    func startReceivingAreaGroupedMarketData() -> Void {
        MQTTManager.shared().sub(on: .mqtopicMarketGroupedFormated, params: [], convertTo: MarketSymbolGroupedAreaResponse.self) { [weak self] (response) in
//            guard self?.isAppeared == true else { return }
//            guard response.succeed == true, let _ = response.data else { return }
//            self?.viewModel.handleAreaPushData(response)
        }
    }
    
}
