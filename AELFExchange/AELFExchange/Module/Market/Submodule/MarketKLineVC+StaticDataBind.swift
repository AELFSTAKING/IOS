//
//  MarketKLineVC+StaticDataBind.swift
//  AELFExchange
//
//  Created by tng on 2019/1/22.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import Foundation
import Kingfisher

extension MarketKLineVC {
    
    func staticDataBind(with data: SymbolsItem, symbol: String, exceptLatestPrice: Bool = false, fromPushData: Bool = false) -> Void {
        // Text.
        let directionColor = PriceColor(withDirection: data.theDirection)
        let directionSymbol = DirectionSymbol(withDirection: data.theDirection)
        
        self.symbolButton.setTitle(symbol, for: .normal)
        if let cIndex = symbol.index(of: "/"), cIndex > 0 {
            let currency = String(symbol[symbol.startIndex ..< symbol.index(symbol.startIndex, offsetBy: cIndex)])
            self.viewModel.currency = currency
        }
        
        if !exceptLatestPrice {
            self.priceLabel.text = data.price ?? data.lastPrice
            self.priceLabel.textColor = directionColor
            
//            let legalRate2Legal = NSDecimalNumber(string: CurrencyManager.shared().exchangeRate(forLegalCurrency: CurrencyManager.shared().legalCurrency).exchangeRate)
//            let legalAmt = NSDecimalNumber(string: data.usdPrice).multiplying(by: legalRate2Legal, withBehavior: kDecimalConfig).legalString()
//            self.priceLegalLabel.text = "\(CurrencyManager.shared().legalCurrencySymbol)\(legalAmt)"
            self.priceLegalLabel.text = "≈ \(data.lastUsdPrice ?? "--") USDT"
        }
        
        self.upRateLabel.text = "\(directionSymbol)\(data.wavePercent ?? "--")%"
        self.upRateLabel.textColor = directionColor
        
        self.lowestPricceLabel.text = data.lowestPrice ?? data.minPrice
        self.highestPriceLabel.text = data.highestPrice ?? data.maxPrice
        self.dealVolumeLabel.text = data.quantity
        
        if !fromPushData {
            self.updateCollectStatus(data.symbol)
        }
        
        self.updateIntroduction()
    }
    
    func updateIntroduction() {
        self.introductionView.currencyLabel.text = self.viewModel.currency
        CurrencyManager.shared().info(of: self.viewModel.currency ?? "", showIndicator: false) { [weak self] (data) in
            if let url = URL(string: data.currencyTwIntroduction ?? "") {
                self?.introductionView.ICON.kf.setImage(with: ImageResource(downloadURL: url))
            }
            self?.introductionView.detailLabel.text = data.currencyCnIntroduction
            self?.introductionView.value3.text = data.officialWebsite
            self?.introductionView.value2.text = data.circulateQuantity
            self?.introductionView.value1.text = data.issueQuantity
            if self?.isIntroductionMode == true {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.5, execute: {
                    self?.contentViewHeightOffset.constant = (self?.introductionView.detailLabel.frame.height ?? 0)*2.0
                })
            }
        }
    }
    
    func updateCollectStatus(_ symbol: String?) {
        DispatchQueue.main.async {
            self.collectButton.isSelected = DB.shared().isSymbolCollected(for: symbol)
        }
    }
    
    func updateMarketBaseInfoIfNeeded(withSymbols symbols: [SymbolsItem]) {
        for case let item in symbols where item.symbol == self.viewModel.symbol {
            guard self.priceLabel.text == "--" else { return }
            self.staticDataBind(with: item, symbol: self.viewModel.symbol)
            break
        }
    }
    
    func updateLatestPrice(with data: OrdersDelegateLatestDealItem) {
        DispatchQueue.main.async {
            let directionColor = PriceColor(withDirection: data.theDirection)
            self.priceLabel.text = data.price
            self.priceLabel.textColor = directionColor
            
//            let legalRate2Legal = NSDecimalNumber(string: CurrencyManager.shared().exchangeRate(forLegalCurrency: CurrencyManager.shared().legalCurrency).exchangeRate)
//            let legalAmt = NSDecimalNumber(string: data.usdPrice).multiplying(by: legalRate2Legal, withBehavior: kDecimalConfig).legalString()
//            self.priceLegalLabel.text = "\(CurrencyManager.shared().legalCurrencySymbol)\(legalAmt)"
            self.priceLegalLabel.text = "≈ \(data.usdPrice ?? "--") USDT"
        }
    }
    
    func resetToDefault() {
        self.priceLabel.text = "--"
        self.priceLegalLabel.text = "--"
        self.upRateLabel.text = "--"
        self.lowestPricceLabel.text = "--"
        self.highestPriceLabel.text = "--"
        self.dealVolumeLabel.text = "--"
        self.viewModel.delegateOrdersCount = 0
        self.viewModel.latestDealOrdersData.removeAllObjects()
        self.orderTableView.reloadData()
    }
    
    func updateTimeRemaining(withRound roundNo: Int, minute: Int64, second: Int64) {
        self.roundLabel.text = "第\(roundNo)轮倒计时:"
        self.roundTimeRemainingLabel.text = "\(minute)分\(second)秒"
    }
    
}
