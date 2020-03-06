//
//  MQTTSymbolTrendingResponse.swift
//  AELFExchange
//
//  Created by tng on 2019/3/29.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import Foundation
import HandyJSON

class MQTTSymbolTrendingResponseData: HandyJSON {
    
    var hotSymbols: [SymbolsTrendingItem]?
    
    required init() {}
    
}

class MQTTSymbolTrendingResponse: BaseAPIBusinessModel {
    
    var data: MQTTSymbolTrendingResponseData?
    
}
