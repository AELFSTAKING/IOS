//
//  SymbolDecimalLenResponse.swift
//  AELFExchange
//
//  Created by tng on 2019/1/25.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import Foundation
import HandyJSON

class SymbolDecimalLenData: HandyJSON {
    
    var symbol: String?
    
    /// 交易币种价格精度（小数点后位数）.
    var productCoinScale: String?
    
    /// 计价币种价格精度（小数点后位数）.
    var currencyCoinScale: String?
    
    /// 成交量精度（小数点后位数）.
    var volumeScale: String?
    
    required init() {}
    
}

class SymbolDecimalLenResponse: BaseAPIBusinessModel {
    
    var data: SymbolDecimalLenData?
    
}
