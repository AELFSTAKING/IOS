//
//  SymbolsTrendingResponse.swift
//  AELFExchange
//
//  Created by tng on 2019/1/20.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import Foundation
import HandyJSON

public enum PriceDirectionEnum: Int {
    case up
    case down
    case flat
}

class SymbolsTrendingKLineItem: HandyJSON {
    
    var serialVersionUID: Int64?
    
    var price: String?
    
    var time: String?
    
    required init() {}
    
}

class SymbolsTrendingItem: HandyJSON {
    
    var isShow: Bool?
    
    var symbol: String?
    
    var price: String?
    
    var quantity: String?
    
    var usdPrice: String?
    
    /// 涨跌价格.
    var wavePrice: String?
    
    /// 涨跌百分比.
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
    
    var klineList: [SymbolsTrendingKLineItem]?
    
    required init() {}
    
}

class SymbolsTrendingData: HandyJSON {
    
    var recommendSymbolList: [SymbolsTrendingItem]?
    
    required init() {}
    
}

class SymbolsTrendingResponse: BaseAPIBusinessModel {
    
    var data: SymbolsTrendingData?
    
}
