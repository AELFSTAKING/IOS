//
//  MarketKLineVC-Subscriber.swift
//  AELFExchange
//
//  Created by tng on 2019/1/28.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import Foundation

extension MarketKLineVC {
    
    func startReceivingLatestPriceData() -> Void {
        MQTTManager.shared().sub(on: .mqtopicMarketTodaySymbols, params: [self.viewModel.symbol], convertTo: MQTTRespTodayMarketModel.self) { [weak self] (response) in
            guard self?.isAppeared == true else { return }
            guard response.succeed == true, let data = response.data, data.symbol == self?.viewModel.symbol else { return }
            DispatchQueue.main.async {
                if let symbol = self?.viewModel.symbol {
                    self?.staticDataBind(with: data, symbol: symbol, exceptLatestPrice: true, fromPushData: true)
                }
            }
        }
    }
    
    func startReceivingKLineData() -> Void {
        MQTTManager.shared().sub(on: .mqtopicMarketKLine, params: [self.viewModel.symbol, self.viewModel.klineRange], convertTo: MQTTKLineModel.self) { [weak self] (response) in
            guard self?.isAppeared == true else { return }
            guard response.succeed == true, let data = response.data, data.symbol == self?.viewModel.symbol else { return }
            self?.viewModel.appendKline(with: data)
        }
    }
    
    func startReceivingDepthData() -> Void {
        MQTTManager.shared().sub(on: .mqtopicMarketDepth, params: [self.viewModel.symbol], convertTo: DepthDataResponse.self) { [weak self] (response) in
            guard self?.isAppeared == true else { return }
            guard response.succeed == true, let data = response.data, data.symbol == self?.viewModel.symbol else { return }
            response.samesAs(target: self?.viewModel.depthDataResponse, completion: { (same) in
                guard same == false else { return }
                self?.viewModel.gotDepthData(with: response, succeed: true)
            })
        }
    }
    
    func startReceivingDelegateOrdersData() -> Void {
        MQTTManager.shared().sub(on: .mqtopicMarketDelegateOrders, params: [self.viewModel.symbol, self.viewModel.depth], convertTo: OrdersDelegateResponse.self) { [weak self] (response) in
            guard self?.isAppeared == true else { return }
            if let latestDealData = response.data?.latestDeal {
                guard response.data?.symbol == self?.viewModel.symbol else { return }
                self?.updateLatestPrice(with: latestDealData)
            }
            guard response.succeed == true, let list1 = response.data?.askList, let list2 = response.data?.bidList, list1.count > 0 || list2.count > 0 else { return }
            guard let data = response.data, data.symbol == self?.viewModel.symbol, data.step == self?.viewModel.depth else { return }
            self?.viewModel.gotDelegateOrder(with: response, succeed: true)
        }
    }
    
    func stopReceivingDelegateOrdersData() -> Void {
        //MQTTManager.shared().unsub(on: .mqtopicMarketDelegateOrders, params: [self.viewModel.symbol, self.viewModel.depth]) // 暂时不退订/暂停.
    }
    
    func startReceivingLatestDealOrdersData() -> Void {
        MQTTManager.shared().sub(on: .mqtopicMarketLatestDealOrders, params: [self.viewModel.symbol], convertTo: OrdersLatestdealResponse.self) { [weak self] (response) in
            guard self?.isAppeared == true else { return }
            guard response.succeed == true, let _ = response.data else { return }
            if let data = response.data?.first, data.symbol != self?.viewModel.symbol {
                return
            }
            self?.viewModel.gotLatestDealOrder(with: response, succeed: true)
        }
    }
    
    func stopReceivingLatestDealOrdersData() -> Void {
        //MQTTManager.shared().unsub(on: .mqtopicMarketLatestDealOrders, params: [self.viewModel.symbol]) // 暂时不退订/暂停.
    }
    
}
