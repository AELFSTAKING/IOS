//
//  TradeVC+Subscriber.swift
//  AELFExchange
//
//  Created by tng on 2019/1/26.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import Foundation

extension TradeVC {
    
    func startReceivingPushData() -> Void {
        guard self.viewModel.symbol.count > 0 else { return }
        self.startReceivingDelegateOrdersData()
        
        // Connnection Status Indicator.
        if self.isAppeared {
            MQTTManager.shared().statusCallback = { [weak self] (connected) in
                self?.ordersCurrentHeaderPrice.updateSignal(toOn: connected)
            }
        }
    }
    
    private func startReceivingDelegateOrdersData() -> Void {
        MQTTManager.shared().sub(on: .mqtopicMarketDelegateOrders, params: [self.viewModel.symbol, self.viewModel.depth], convertTo: OrdersDelegateResponse.self) { [weak self] (response) in
            guard self?.isAppeared == true else { return }
            guard response.succeed == true, let _ = response.data?.askList, let _ = response.data?.bidList, let data = response.data, data.symbol == self?.viewModel.symbol, data.step == self?.viewModel.depth else { return }
            self?.viewModel.gotDelegateOrder(with: response, succeed: true)
            if let direction = data.latestDeal?.theDirection {
                self?.gotLatestPrice(with: data.latestDeal?.price, latestDealPriceUSD: data.latestDeal?.usdPrice, direction: direction)
            }
        }
    }
    
}
