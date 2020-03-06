//
//  MarketKLineFullscreenVC+PushData.swift
//  AELFExchange
//
//  Created by tng on 2019/2/13.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import Foundation

extension MarketKLineFullscreenVC {
    
    func startReceivingLatestPriceData() -> Void {
        MQTTManager.shared().sub(on: .mqtopicMarketDelegateOrders, params: [self.viewModel.symbol, Consts.kDepthDefault], convertTo: OrdersDelegateResponse.self) { [weak self] (response) in
            guard self?.isAppeared == true else { return }
            guard let data = response.data?.latestDeal else { return }
            DispatchQueue.main.async {
                let directionColor = PriceColor(withDirection: data.theDirection)
                self?.priceLabel.text = data.price
                self?.priceLabel.textColor = directionColor
                
                //let legalRate2Legal = NSDecimalNumber(string: CurrencyManager.shared().exchangeRate(forLegalCurrency: CurrencyManager.shared().legalCurrency).exchangeRate)
                let legalRate2Legal = NSDecimalNumber(string: "1.0")
                let legalAmt = NSDecimalNumber(string: data.usdPrice).multiplying(by: legalRate2Legal, withBehavior: kDecimalConfig).legalString()
                self?.legalPriceLabel.text = "\(CurrencyManager.shared().legalCurrencySymbol)\(legalAmt)"
            }
        }
        
        MQTTManager.shared().sub(on: .mqtopicMarketTodaySymbols, params: [self.viewModel.symbol], convertTo: MQTTRespTodayMarketModel.self) { [weak self] (response) in
            guard self?.isAppeared == true else { return }
            guard response.succeed == true, let data = response.data, data.symbol == self?.viewModel.symbol else { return }
            DispatchQueue.main.async {
                let directionColor = PriceColor(withDirection: data.theDirection)
                let directionSymbol = DirectionSymbol(withDirection: data.theDirection)
                self?.rateValueLabel.text = "\(directionSymbol)\(data.wavePrice ?? "--")"
                self?.rateValueLabel.textColor = directionColor
                self?.ratePercentLabel.text = "\(directionSymbol)\(data.wavePercent ?? "--")%"
                self?.ratePercentLabel.textColor = directionColor
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
    
}
