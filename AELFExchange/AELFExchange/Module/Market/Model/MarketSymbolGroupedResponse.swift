//
//  MarketSymbolGroupedResponse.swift
//  AELFExchange
//
//  Created by tng on 2019/5/16.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import Foundation
import HandyJSON

class MarketSymbolGroupedDataBO: HandyJSON {
    
    var group: String?
    
    var list: [SymbolsItem]?
    
    required init() {}
    
}

class MarketSymbolGroupedResponse: BaseAPIBusinessModel {
    
    var data: [MarketSymbolGroupedDataBO]?
    
}
