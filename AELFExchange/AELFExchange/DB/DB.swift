//
//  DB.swift
//  AELF
//
//  Created by tng on 2018/9/13.
//  Copyright © 2018年 AELF. All rights reserved.
//

import Foundation
import RealmSwift
import ReactiveSwift
import Result

class DB {
    
    fileprivate static let ___donotUseThisVariableOfDB = DB()
    
    @discardableResult
    static func shared() -> DB {
        return DB.___donotUseThisVariableOfDB
    }
    
    lazy var rm: Realm = {
        let config = Realm.Configuration.defaultConfiguration
        let rm = try! Realm(configuration: config)
        return rm
    }()
    
    func async(something: @escaping (Realm) -> ()) -> Void {
        autoreleasepool {
            if self.rm.isInWriteTransaction {
                something(self.rm)
            }
            else {
                do {
                    try self.rm.write({ [unowned self] in
                        something(self.rm)
                    })
                }
                catch {
                    logerror(content: "Failed to commit the transaction caused of error:\(error)")
                }
            }
        }
    }
    
    // Business.
    let (collectedSymbolsUpdatedSignal, collectedSymbolsUpdatedObserver) = Signal<Bool, NoError>.pipe()
    
}

// MARK: - Business.
extension DB {
    
    func sync2db4exchangeSymbols(with data: [SymbolsItem], for type: MarketTypeEnum?) -> Void {
        DB.shared().async { (rm) in
            guard let theType = type else { return }
            
            var objs = [ExchangeSymbolEntity]()
            for case let item in data where (item.isShow == true || Config.shared().showMarket == true) {
                let entity = ExchangeSymbolEntity()
                entity.type = "\(theType.rawValue)"
                entity.symbol = item.symbol
                entity.highestPrice = item.highestPrice
                entity.highestUsdPrice = item.highestUsdPrice
                entity.lowestPrice = item.lowestPrice
                entity.lowestUsdPrice = item.lowestUsdPrice
                entity.price = item.price
                entity.usdPrice = item.usdPrice
                entity.quantity = item.quantity
                entity.wavePrice = item.wavePrice
                entity.wavePercent = item.wavePercent
                entity.direction = "\(item.direction ?? 0)"
                objs.append(entity)
            }
            
            guard objs.count > 0 else { return }
            rm.add(objs, update: true)
        }
    }
    
    func sync2db4collectedExchangeSymbols(with data: [String], for type: MarketTypeEnum?) -> Void {
        DB.shared().async { (rm) in
            guard let theType = type else { return }
            
            var objs = [CollectedExchangeSymbolEntity]()
            for item in data {
                let entity = CollectedExchangeSymbolEntity()
                entity.type = "\(theType.rawValue)"
                entity.symbol = item
                objs.append(entity)
            }
            
            guard objs.count > 0 else { return }
            rm.add(objs, update: true)
        }
    }
    
    func sync2db4depthConfig(with data: [String], symbol: String) -> Void {
        DB.shared().async { (rm) in
            var objs = [DepthConfigEntity]()
            for item in data {
                let entity = DepthConfigEntity()
                entity.symbol = symbol
                entity.depth = item
                entity.prtKey = "\(symbol)+\(item)"
                objs.append(entity)
            }
            
            guard objs.count > 0 else { return }
            rm.delete(rm.objects(DepthConfigEntity.self).filter("symbol = '\(symbol)'"))
            rm.add(objs, update: true)
        }
    }
    
    func isSymbolCollected(for symbol: String?) -> Bool {
        guard let symbol = symbol else {
            return false
        }
        return DB.shared().rm.objects(CollectedExchangeSymbolEntity.self).filter("symbol='\(symbol)' and type='\(MarketTypeEnum.collection.rawValue)'").count > 0
    }
    
    func symbolCollect(forCollect collect: Bool, symbol: String) -> Void {
        DispatchQueue.main.async {
            DB.shared().async { [unowned self] (rm) in
                if collect {
                    let entity = CollectedExchangeSymbolEntity()
                    entity.type = "\(MarketTypeEnum.collection.rawValue)"
                    entity.symbol = symbol
                    rm.add(entity, update: true)
                    self.collectedSymbolsUpdatedObserver.send(value: true)
                } else {
                    guard let obj = rm.objects(CollectedExchangeSymbolEntity.self).filter("symbol='\(symbol)' and type='\(MarketTypeEnum.collection.rawValue)'").first else { return }
                    rm.delete(obj)
                    self.collectedSymbolsUpdatedObserver.send(value: false)
                }
            }
        }
    }
    
    func sync2db4tradeSymbolConfig(with data: TradeSymbolInfoData) -> Void {
        /*
        DB.shared().async { (rm) in
            let entity = TradeSymbolInfoEntity()
            entity.symbol = data.symbol
            entity.availableSell = data.availableSell
            entity.availableBuy = data.availableBuy
            entity.productCoinQuantityMin = data.productCoinQuantityMin
            entity.productCoinQuantityMax = data.productCoinQuantityMax
            entity.currencyCoinQuantityMin = data.currencyCoinQuantityMin
            entity.currencyCoinQuantityMax = data.currencyCoinQuantityMax
            entity.priceBestBuy = data.priceBestBuy
            entity.priceBestSell = data.priceBestSell
            entity.tradeStatus = data.tradeStatus
            entity.productCoinQuantityScale = data.productCoinQuantityScale
            entity.currencyCoinQuantityScale = data.currencyCoinQuantityScale
            entity.priceScale = data.priceScale
            entity.deviation = data.deviation
            entity.amountScale = data.amountScale
            entity.minAmount = data.minAmount
            entity.maxAmount = data.maxAmount
            rm.add(entity, update: true)
        }*/
    }
    
}
