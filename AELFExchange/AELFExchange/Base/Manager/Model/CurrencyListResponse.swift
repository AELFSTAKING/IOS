//
//  CurrencyListResponse.swift
//  AELFExchange
//
//  Created by tng on 2019/8/2.
//  Copyright © 2019 cex.io. All rights reserved.
//

import Foundation
import HandyJSON

class CurrencyListDataItem: HandyJSON {
    
    var alias: String?
    var chain: String?
    var convertRate: String?
    var currency: String?
    var icon128: String?
    var icon32: String?
    var maxAmount: String?
    var minAmount: String?
    var scale: Int?
    var status: Int?
    var tokenChain: String?
    var tokenCurrency: String?
    var utcCreate: String?
    var utcUpdate: String?
    
    required init() {}
    
}

class CurrencyListData: HandyJSON {
    
    var list: [CurrencyListDataItem]?
    
    required init() {}
    
}

class CurrencyListResponse: BaseAPIBusinessModel {
    
    var data: CurrencyListData?
    
}
