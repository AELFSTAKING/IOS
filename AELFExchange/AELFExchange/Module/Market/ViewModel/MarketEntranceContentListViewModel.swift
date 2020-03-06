//
//  MarketEntranceContentListViewModel.swift
//  AELFExchange
//
//  Created by tng on 2019/7/16.
//  Copyright © 2019 cex.io. All rights reserved.
//

import Foundation
import ReactiveSwift
import Result

@objc class MarketEntranceContentListViewModel: NSObject {
    
    var mode = MarketTypeEnum.market
    var doNotShowAddButton = true
    
    let (loadedSignal, loadedObserver) = Signal<Bool, NoError>.pipe()
    @objc dynamic var data = NSMutableArray() // AllMarketSymbolData.
    
    func load() {
        MarketManager.shared().allExchangeSymbolLatest(withCache: true) { [weak self] (allData) in
            self?.gotMarketSymbols(withData: allData, fromPush: false)
        }
    }
    
    func gotMarketSymbols(withData data: [AllMarketSymbolData], fromPush: Bool) {
        if self.mode == .collection {
            let collectedSymbols = DB.shared().rm.objects(CollectedExchangeSymbolEntity.self).filter("type='\(MarketTypeEnum.collection.rawValue)'")
            self.data.removeAllObjects()
            for symbol in data {
                if collectedSymbols.contains(where: { (entity) -> Bool in
                    return entity.symbol == symbol.symbol
                }) && symbol.isShow == true || Config.shared().showMarket == true {
                    let item = SymbolsItem()
                    item.symbol = symbol.symbol
                    item.highestPrice = symbol.highestPrice
                    item.highestUsdPrice = symbol.highestUsdPrice
                    item.lowestPrice = symbol.lowestPrice
                    item.lowestUsdPrice = symbol.lowestUsdPrice
                    item.lastPrice = symbol.lastPrice
                    item.lastUsdPrice = symbol.lastUsdPrice
                    item.quantity = symbol.quantity
                    item.wavePrice = symbol.wavePrice
                    item.wavePercent = symbol.wavePercent
                    item.direction = Int(symbol.direction ?? "0") ?? 0
                    self.data.add(item)
                }
            }
            self.loadedObserver.send(value: true)
        } else {
            self.data.removeAllObjects()
            var tmpArr = [SymbolsItem]()
            for symbol in data {
                guard symbol.isShow == true || Config.shared().showMarket == true else { continue}
                let item = SymbolsItem()
                item.symbol = symbol.symbol
                item.highestPrice = symbol.highestPrice
                item.highestUsdPrice = symbol.highestUsdPrice
                item.lowestPrice = symbol.lowestPrice
                item.lowestUsdPrice = symbol.lowestUsdPrice
                item.lastPrice = symbol.lastPrice
                item.lastUsdPrice = symbol.lastUsdPrice
                item.quantity = symbol.quantity
                item.wavePrice = symbol.wavePrice
                item.wavePercent = symbol.wavePercent
                item.direction = Int(symbol.direction ?? "0") ?? 0
                tmpArr.append(item)
            }
            self.data.addObjects(from: tmpArr)
            self.loadedObserver.send(value: true)
        }
    }
    
}
