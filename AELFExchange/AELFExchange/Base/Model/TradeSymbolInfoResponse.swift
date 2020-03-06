//
//  TradeSymbolInfoResponse.swift
//  AELFExchange
//
//  Created by tng on 2019/1/27.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import Foundation
import HandyJSON

class TradeSymbolInfoData: HandyJSON {
    
    var symbol: String?
    
    /// 用户可买的数量，针对计价币种而言.
    var availableSell: String?
    
    /// 用户可卖的数量，针对交易币种而言.
    var availableBuy: String?
    
    /// 交易对针对市价卖（总共要卖出多少交易币种）、限价买（需要以限定价格买入多少交易币种）、限价卖（以限定价格卖出多少交易币种） 设置交易币种的数量最小值.
    var quantityMin: String?
    
    /// 交易对针对市价卖（总共要卖出多少交易币种）、限价买（需要以限定价格买入多少交易币种）、限价卖（以限定价格卖出多少交易币种） 设置交易币种的数量最大值.
    var quantityMax: String?
    
    /// 最佳买价.
    var priceBestBuy: String?
    
    /// 最佳卖价.
    var priceBestSell: String?
    
    /// 最新成交价格.
    var latestPrice: String?
    
    /// 是否可交易，0不可交易，1可交易.
    var tradeStatus: Int?
    
    /// 数量小数位数.
    var quantityScale: String?
    
    /// 价格精度.
    var priceScale: String?
    
    /// 限价单-挂单价格偏差范围，判断不能让价格偏差过大.
    var deviation: String?
    
    /// 交易对设置amount时候的最小值，这个是针对市价买的时候需要设置出的计价币种总数（最少需要出多少amount进行市价买）.
    var amountMin: String?
    
    /// 交易对设置amount时候的最大值，这个是针对市价买的时候需要设置出的计价币种总数（最多出多少amount进行市价买）.
    var amountMax: String?
    
    required init() {}
    
}

class TradeSymbolInfoResponse: BaseAPIBusinessModel {
    
    var data: TradeSymbolInfoData?
    
}
