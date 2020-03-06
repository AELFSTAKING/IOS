//
//  SymbolDecimalLenEntity.swift
//  AELFExchange
//
//  Created by tng on 2019/1/25.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import Foundation
import RealmSwift

class SymbolDecimalLenEntity: Object {
    
    @objc dynamic var symbol: String?
    
    /// 交易币种小数精度.
    @objc dynamic var currencyDicemalLen: String?
    
    /// 计价换算币种小数精度.
    @objc dynamic var baseCurrencyDicemalLen: String?
    
    /// 成交量小数精度.
    @objc dynamic var dealDicemalLen: String?
    
    override static func primaryKey() -> String? {
        return "symbol"
    }
    
}
