//
//  AllCurrencyResponse.swift
//  AELFExchange
//
//  Created by tng on 2019/1/16.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import Foundation
import HandyJSON

class AllMarketSymbolData: HandyJSON {
    
    var isShow: Bool?
    
    var symbol: String?
    
    ///  * 24h最高价.
    var highestPrice: String?
    
    ///  * 最高价折合美元.
    var highestUsdPrice: String?
    
    ///  * 24h最低价.
    var lowestPrice: String?
    
    ///  * 最低价折合美元.
    var lowestUsdPrice: String?
    
    ///  * 最新价.
    //var price: String?
    var lastPrice: String?
    
    ///  * 最新价折合美元.
    //var usdPrice: String?
    var lastUsdPrice: String?
    
    ///  * 交易成交量.
    var quantity: String?
    
    ///  * 涨跌价格.
    var wavePrice: String?
    
    ///  * 涨跌百分比.
    var wavePercent: String?
    
    /// /**涨跌：1涨、0平、-1跌**/.
    var direction: String?
    
    required init() {}
    
}

class AllMarketSymbolResponse: BaseAPIBusinessModel {
    
    var data: [AllMarketSymbolData]?
    
}
