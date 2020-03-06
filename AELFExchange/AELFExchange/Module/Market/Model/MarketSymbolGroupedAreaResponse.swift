//
//  MarketSymbolGroupedAreaResponse.swift
//  AELFExchange
//
//  Created by tng on 2019/6/19.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import Foundation
import HandyJSON

class MarketSymbolGroupedAreaDataBO: HandyJSON {
    
    var areaName: String?
    
    var areaEnName: String?
    
    var areaNo: String?
    
    var list: [MarketSymbolGroupedDataBO]?
    
    required init() {}
    
}

class MarketSymbolGroupedAreaResponse: BaseAPIBusinessModel {
    
    var data: [MarketSymbolGroupedAreaDataBO]?
    
}
