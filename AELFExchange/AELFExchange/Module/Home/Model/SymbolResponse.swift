//
//  SymbolResponse.swift
//  AELFExchange
//
//  Created by tng on 2019/1/20.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import Foundation
import HandyJSON

class SymbolsItem: HandyJSON {
    
    var isShow: Bool?
    
    var symbol: String?
    
    var highestPrice: String?
    var maxPrice: String?
    
    var highestUsdPrice: String?
    
    var lowestPrice: String?
    var minPrice: String?
    
    var lowestUsdPrice: String?
    
    /// 最新价.
    var price: String?
    var lastPrice: String?
    
    /// 最新价折合美元.
    var usdPrice: String?
    var lastUsdPrice: String?
    
    var quantity: String?
    
    /// 涨跌价格.
    var wavePrice: String?
    
    /// 涨跌幅.
    var wavePercent: String?
    
    /// 价格涨跌：1涨、0平、-1跌.
    var direction: Int?
    var theDirection: PriceDirectionEnum {
        switch direction ?? 0 {
        case  0: return .flat
        case  1: return .up
        case -1: return .down
        default: return .flat
        }
    }
    
    required init() {}
    
}

class SymbolResponse: BaseAPIBusinessModel {
    
    var data: [SymbolsItem]?
    
}
