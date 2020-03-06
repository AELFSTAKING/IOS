//
//  TradeVC+StaticDataBind.swift
//  AELFExchange
//
//  Created by tng on 2019/1/23.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import Foundation
import ReactiveSwift

extension TradeVC {
    
    func staticDataSetup(withSymbol symbol: String?) -> Void {
        // Switched the symbol.
        if let symbol = symbol {
            self.viewModel.symbol = symbol
            self.decimalLenSetup(withSymbol: symbol)
        }
            
        // The first time to enter.
        else {
            //self.startLoadingHUD(withMsg: nil, on: self.view, center: true)
            MarketManager.shared().defaultExchangeSymbol { [weak self] (symbolItem) in
                //self?.stopLoadingHUD()
                if self?.viewModel.symbol.count == 0 {
                    let symbol = symbolItem.symbol ?? "---"
                    self?.viewModel.symbol = symbol
                    self?.viewModel.symbolItem = symbolItem
                    self?.decimalLenSetup(withSymbol: symbol)
                }
            }
        }
    }
    
    private func decimalLenSetup(withSymbol symbol: String) -> Void {
        CurrencyManager.shared().decimalLen(of: symbol) { [weak self] (decimalLen) in
            if  let currentLen = self?.viewModel.depth.count(of: "0") {
                let currentLenValue = Int(currentLen)
                let targetLenValue = Int(decimalLen.currencyDicemalLen ?? "0") ?? 0
                if currentLenValue != targetLenValue && targetLenValue > 0 {
                    let targetDepth = "\([String].init(repeating: "0", count: targetLenValue).joined(separator: ""))1"
                    self?.viewModel.depth = targetDepth
                    self?.viewModel.depthForMenuDisplay = LOCSTR(withKey: "{}位小数").replacingOccurrences(of: "{}}", with: "\(targetLenValue)")
                }
            }
        }
    }
    
}
