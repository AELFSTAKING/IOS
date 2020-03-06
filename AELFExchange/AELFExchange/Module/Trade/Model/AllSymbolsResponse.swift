//
//  AllSymbolsResponse.swift
//  AELFExchange
//
//  Created by tng on 2019/4/10.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import Foundation
import HandyJSON

class AllSymbolsData: HandyJSON {
    
    var symbol: String?
    
    var tradeStatus: String?
    
    var usdConvertedAmount: String?
    
    required init() {}
    
}

class AllSymbolsResponse: BaseAPIBusinessModel {
    
    var data: [AllSymbolsData]?
    
}
