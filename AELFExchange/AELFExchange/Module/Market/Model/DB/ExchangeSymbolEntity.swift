//
//  ExchangeSymbolEntity.swift
//  AELFExchange
//
//  Created by tng on 2019/1/21.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import Foundation
import RealmSwift

public enum ExchangeSymbolType {
    case collection
    case market
}

class ExchangeSymbolEntity: Object {
    
    /// 0: Collection, 1:Market.
    @objc dynamic var type: String?
    
    @objc dynamic var symbol: String?
    
    @objc dynamic var highestPrice: String?
    
    @objc dynamic var highestUsdPrice: String?
    
    @objc dynamic var lowestPrice: String?
    
    @objc dynamic var lowestUsdPrice: String?
    
    /// 最新价.
    @objc dynamic var price: String?
    
    /// 最新价折合美元.
    @objc dynamic var usdPrice: String?
    
    @objc dynamic var quantity: String?
    
    /// 涨跌价格.
    @objc dynamic var wavePrice: String?
    
    /// 涨跌幅.
    @objc dynamic var wavePercent: String?
    
    /// 价格涨跌：1涨、0平、-1跌.
    @objc dynamic var direction: String?
    var theDirection: PriceDirectionEnum {
        switch Int(direction ?? "0") ?? 0 {
        case  0: return .flat
        case  1: return .up
        case -1: return .down
        default: return .flat
        }
    }
    
    override static func primaryKey() -> String? {
        return "symbol"
    }
    
}
