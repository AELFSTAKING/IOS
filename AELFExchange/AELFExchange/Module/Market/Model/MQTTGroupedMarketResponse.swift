//
//  MQTTGroupedMarketResponse.swift
//  AELFExchange
//
//  Created by tng on 2019/6/20.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import Foundation
import HandyJSON

class MQTTGroupedMarketDataBO: HandyJSON {
    
    var areaName: String?
    
    var areaNo: String?
    
    var group: String?
    
    var list: [SymbolsItem]?
    
    required init() {}
    
}

class MQTTGroupedMarketResponse: BaseAPIBusinessModel {
    
    var data: [MQTTGroupedMarketDataBO]?
    
}
