//
//  TradeVC+UIUpdater.swift
//  AELFExchange
//
//  Created by tng on 2019/1/22.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import Foundation
import UIKit

extension TradeVC {
    
    func updateMode(with mode: TradeViewModeEnum) -> Void {
        switch mode {
        case .buy:
            self.buyModeButton.setTitleColor(.white, for: .normal)
            self.buyModeButton.backgroundColor = kThemeColorGreen
            self.sellModeButton.setTitleColor(kThemeColorButtonUnableGary, for: .normal)
            self.sellModeButton.backgroundColor = kThemeColorButtonUnable
            self.quantitySlider.setupForModeBuy()
        case .sell:
            self.buyModeButton.setTitleColor(kThemeColorButtonUnableGary, for: .normal)
            self.buyModeButton.backgroundColor = kThemeColorButtonUnable
            self.sellModeButton.setTitleColor(.white, for: .normal)
            self.submitButton.backgroundColor = kThemeColorRed
            self.quantitySlider.setupForModeSell()
        }
        self.updateBuySellButton(with: mode)
        self.viewModel.loadAssets()
        self.viewModel.loadBestPrice()
        self.clearQuantity()
        self.updateDealCurrencyIfNeeded()
    }
    
    func updateBuySellButton(with mode: TradeViewModeEnum) {
        switch mode {
        case .buy:
            self.submitButton.setTitle("\(LOCSTR(withKey: "买入")) \(self.viewModel.currency)", for: .normal)
            self.submitButton.backgroundColor = kThemeColorGreen
        case .sell:
            self.submitButton.setTitle("\(LOCSTR(withKey: "卖出")) \(self.viewModel.currency)", for: .normal)
            self.sellModeButton.backgroundColor = kThemeColorRed
        }
    }
    
    func clearQuantity() -> Void {
        self.viewModel.digitalQuantity = "0.00"
        self.quantityTextfield.text = "0.00"
    }
    
    func updateOrderTypeEvent() -> Void {
        self.orderTypeIconButton.setImage(UIImage(named: "icon-mk-arrow-small-up"), for: .normal)
        let actions = [
            FSActionSheetTitleItemMake(.normal, LOCSTR(withKey: "限价单")),
            FSActionSheetTitleItemMake(.normal, LOCSTR(withKey: "市价单"))
        ] as [FSActionSheetItem]
        let sheet = FSActionSheet(title: "", cancelTitle: LOCSTR(withKey: "取消"), items: actions)
        sheet?.show(selectedCompletion: { [weak self] (index) in
            self?.orderTypeIconButton.setImage(UIImage(named: "icon-mk-arrow-small-down"), for: .normal)
            switch index {
            case 0: self?.viewModel.orderType = TradeOrderTypeEnum.limit.rawValue
            case 1: self?.viewModel.orderType = TradeOrderTypeEnum.market.rawValue
            default:break
            }
            self?.updateCurrencyOfAvailableCurrency()
            self?.updateDealCurrencyIfNeeded()
        })
    }
    
    func updateCurrencyOfAvailableCurrency() -> Void {
        if self.viewModel.mode == TradeViewModeEnum.sell.rawValue {
            self.availableQuantityCurrencyLabel.text = self.viewModel.currency
            self.quantityTextfield.quantityModeLeft.setTitle(LOCSTR(withKey: "数量"), for: .normal)
        }
        else if self.viewModel.mode == TradeViewModeEnum.buy.rawValue {
            self.availableQuantityCurrencyLabel.text = self.viewModel.baseCurrency
            if self.viewModel.orderType == TradeOrderTypeEnum.market.rawValue {
                self.quantityTextfield.quantityModeLeft.setTitle(LOCSTR(withKey: "成交额"), for: .normal)
            } else {
                self.quantityTextfield.quantityModeLeft.setTitle(LOCSTR(withKey: "数量"), for: .normal)
            }
        }
    }
    
    // Price Calculate.
    func priceOfTextfieldIncrease() -> Void {
        guard let priceStr = self.priceTextfield.text else {
            return
        }
        let decimalLen = self.priceDecimalLen() ?? 1
        let addPrice = NSDecimalNumber(decimal: 1.0/pow(10, decimalLen))
        let currentPrice = NSDecimalNumber(string: priceStr)
        let retPrice = currentPrice.adding(addPrice, withBehavior: kDecimalConfig).string(withDecimalLen: decimalLen)
        self.priceTextfield.text = retPrice
        self.priceForTextfieldUpdated(with: retPrice)
    }
    
    func priceOfTextfieldReduce() -> Void {
        guard let priceStr = self.priceTextfield.text else {
            return
        }
        let decimalLen = self.priceDecimalLen() ?? 1
        let reducePrice = NSDecimalNumber(decimal: 1.0/pow(10, decimalLen))
        let currentPrice = NSDecimalNumber(string: priceStr)
        let retPrice = currentPrice.subtracting(reducePrice, withBehavior: kDecimalConfig).string(withDecimalLen: decimalLen)
        self.priceTextfield.text = retPrice
        self.priceForTextfieldUpdated(with: retPrice)
    }
    
    private func priceDecimalLen() -> Int? {
        guard let priceStr = self.priceTextfield.text,
            let pointIndex = priceStr.index(of: "."),
            pointIndex < priceStr.count-1 else {
                return nil
        }
        let decimalStr = String(priceStr[priceStr.index(priceStr.startIndex, offsetBy: pointIndex+1) ..< priceStr.endIndex])
        return decimalStr.count
    }
    
    func fillQuantity(withPercent percent: Float) -> Void {
        let totalAsset = NSDecimalNumber(string: self.viewModel.availableAsset)
        guard totalAsset.compare(0.0) != .orderedSame else { return }
        var ret = totalAsset.multiplying(by: NSDecimalNumber(value: percent), withBehavior: kDecimalConfig)
        
        if  self.viewModel.mode == TradeViewModeEnum.buy.rawValue &&
            self.viewModel.orderType != TradeOrderTypeEnum.market.rawValue {
            let price = NSDecimalNumber(string: self.viewModel.digitalPrice)
            ret = ret.dividing(by: price, withBehavior: kDecimalConfig)
        }
        
        var dlen = self.viewModel.currencyDecimalLenMax
        if self.viewModel.mode == TradeViewModeEnum.buy.rawValue && self.viewModel.orderType == TradeOrderTypeEnum.market.rawValue {
            dlen = self.viewModel.baseCurrencyDecimalLenMax
        }
        let retStr = ret.string(withDecimalLen: dlen, minLen: 0)
        self.viewModel.digitalQuantity = retStr
        self.quantityTextfield.text = retStr == "0" ? "0.00":retStr
    }
    
    func priceForTextfieldUpdated(with value: String?) -> Void {
        self.viewModel.digitalPrice = value == "" ? "0" : (value ?? "0")
    }
    
    func dealAmountForTextfieldUpdated() {
        let value = self.viewModel.digitalQuantity
        guard value.count > 0 else {
            self.dealAmountTextfield.text = "0.0"
            return
        }
        
        let quantity = NSDecimalNumber(string: value)
        let price = NSDecimalNumber(string: self.viewModel.digitalPrice)
        let dealAmt = quantity.multiplying(by: price, withBehavior: kDecimalConfig)
        let dealAmtStr = dealAmt.compare(0.0) == .orderedSame ? "0.0" : dealAmt.string(withDecimalLen: self.viewModel.baseCurrencyDecimalLenMax)
        self.dealAmountTextfield.text = dealAmtStr
        
        var percent: Float = 0.0
        if self.viewModel.orderType == TradeOrderTypeEnum.limit.rawValue && self.viewModel.mode == TradeViewModeEnum.buy.rawValue {
            let q = NSDecimalNumber(string: self.viewModel.digitalQuantity)
                .multiplying(by: NSDecimalNumber(string: self.viewModel.digitalPrice), withBehavior: kDecimalConfig)
            percent = q
                .dividing(by: NSDecimalNumber(string: self.viewModel.availableAsset), withBehavior: kDecimalConfig)
                .floatValue
        } else {
            percent = quantity
                .dividing(by: NSDecimalNumber(string: self.viewModel.availableAsset), withBehavior: kDecimalConfig)
                .floatValue
        }
        if percent > 1.0 { percent = 1.0 }
        if percent < 0 { percent = 0 }
        self.quantitySlider.sliderValueChanged(with: percent, withoutCallback: true, delay: percent == 0 ? 0.3:0.0)
    }
    
    func calculateLegalAmount(with digitalPrice: String) -> Void {
        //let legalRate2Legal = NSDecimalNumber(string: CurrencyManager.shared().exchangeRate(forLegalCurrency: CurrencyManager.shared().legalCurrency).exchangeRate)
        let legalRate2Legal = NSDecimalNumber(string: "1.0")
        let legalAmt = NSDecimalNumber(string: digitalPrice).multiplying(by: legalRate2Legal, withBehavior: kDecimalConfig).legalString()
        self.viewModel.legalAmount = legalAmt
    }
    
    func updateLegalAmount() -> Void {
        guard self.viewModel.orderType == TradeOrderTypeEnum.limit.rawValue else { return }
        self.legalPriceLabel.text = "≈ \(CurrencyManager.shared().legalCurrencySymbol)\(self.viewModel.legalAmount)"
    }
    
    func updateDealCurrencyIfNeeded() {
        self.dealQuantityTitleLabel.text = LOCSTR(withKey: "成交额")
        self.dealCurrencyLabel.text = self.viewModel.baseCurrency
        if self.viewModel.orderType == TradeOrderTypeEnum.market.rawValue && self.viewModel.mode == TradeViewModeEnum.buy.rawValue {
            self.quantityTextfield.quantityModeRight.setTitle(self.viewModel.baseCurrency, for: .normal)
        } else {
            self.quantityTextfield.quantityModeRight.setTitle(self.viewModel.currency, for: .normal)
        }
    }
    
}
