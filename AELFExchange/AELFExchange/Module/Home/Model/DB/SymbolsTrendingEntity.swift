//
//  SymbolsTrendingEntity.swift
//  AELFExchange
//
//  Created by tng on 2019/1/23.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import Foundation
import RealmSwift

class SymbolsTrendingEntityKLineItem: Object {
    
    @objc dynamic var serialVersionUID: String?
    
    @objc dynamic var price: String?
    
    @objc dynamic var time: String?
    
}

class SymbolsTrendingEntityItem: Object {
    
    @objc dynamic var symbol: String?
    
    @objc dynamic var price: String?
    
    @objc dynamic var quantity: String?
    
    @objc dynamic var usdPrice: String?
    
    /// 涨跌价格.
    @objc dynamic var wavePrice: String?
    
    /// 涨跌百分比.
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
    
    @objc dynamic var klineList: String?
    var klineListArr: [SymbolsTrendingEntityKLineItem] {
        return [SymbolsTrendingEntityKLineItem]()
    }
    
    override static func primaryKey() -> String? {
        return "symbol"
    }
    
}
