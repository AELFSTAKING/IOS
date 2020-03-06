//
//  TradeSymbolInfoEntity.swift
//  AELFExchange
//
//  Created by tng on 2019/1/27.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import Foundation
import RealmSwift

class TradeSymbolInfoEntity: Object {
    
    @objc dynamic var symbol: String?
    
    /// 用户可买的数量，针对计价币种而言.
    @objc dynamic var availableSell: String?
    
    /// 用户可卖的数量，针对交易币种而言.
    @objc dynamic var availableBuy: String?
    
    /// 交易币种的最小挂单量.
    @objc dynamic var productCoinQuantityMin: String?
    
    /// 交易币种的最大挂单量.
    @objc dynamic var productCoinQuantityMax: String?
    
    /// 计价币种最小挂单量.
    @objc dynamic var currencyCoinQuantityMin: String?
    
    /// 计价币种最大挂单量.
    @objc dynamic var currencyCoinQuantityMax: String?
    
    /// 最佳买价.
    @objc dynamic var priceBestBuy: String?
    
    /// 最佳卖价.
    @objc dynamic var priceBestSell: String?
    
    /// 是否可交易，0不可交易，1可交易.
    @objc dynamic var tradeStatus: String?
    
    /// 交易币种挂单支持的小数位数，比如8表示支持的是小数点后8位.
    @objc dynamic var productCoinQuantityScale: String?
    
    /// 计价币种挂单支持的小数位数.
    @objc dynamic var currencyCoinQuantityScale: String?
    
    /// 显示价格时候的价格精度.
    @objc dynamic var priceScale: String?
    
    /// 限价单-挂单价格偏差范围，判断不能让价格偏差过大.
    @objc dynamic var deviation: String?
    
    /// 总计价格的精度，比如8表示在总计价格的时候是小数点后8位.
    @objc dynamic var amountScale: String?
    
    /// 买卖折合的最小价格，即折合之后的最小价格总计不能小于这个值.
    @objc dynamic var minAmount: String?
    
    /// 买卖折合的最大价格，即折合之后的最大价格总计不能大于这个值.
    @objc dynamic var maxAmount: String?
    
    override static func primaryKey() -> String? {
        return "symbol"
    }
    
}
