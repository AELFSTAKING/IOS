//
//  MarketEntranceVC+Subscriber.swift
//  AELFExchange
//
//  Created by tng on 2019/8/6.
//  Copyright © 2019 cex.io. All rights reserved.
//

import Foundation

extension MarketEntranceContentListVC {
    
    func startReceivingPushData() {
        MQTTManager.shared().sub(on: .mqtopicUpSymbols, params: [], convertTo: MQTTSymbolResponse.self) { [weak self] (response) in
            guard self?.isAppeared == true else { return }
            guard response.succeed == true, let data = response.data, let list = data.upList else { return }
            var tmpArr = [AllMarketSymbolData]()
            for symbol in list {
                guard symbol.isShow == true || Config.shared().showMarket == true else { continue}
                let item = AllMarketSymbolData()
                item.isShow = symbol.isShow
                item.symbol = symbol.symbol
                item.highestPrice = symbol.highestPrice
                item.highestUsdPrice = symbol.highestUsdPrice
                item.lowestPrice = symbol.lowestPrice
                item.lowestUsdPrice = symbol.lowestUsdPrice
                item.lastPrice = symbol.price
                item.lastUsdPrice = symbol.usdPrice
                item.quantity = symbol.quantity
                item.wavePrice = symbol.wavePrice
                item.wavePercent = symbol.wavePercent
                item.direction = "\(symbol.direction ?? 0)"
                tmpArr.append(item)
            }
            DispatchQueue.main.async {
                self?.viewModel.gotMarketSymbols(withData: tmpArr, fromPush: true)
            }
        }
    }
    
}
