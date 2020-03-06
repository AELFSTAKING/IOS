//
//  MQTTSymbolResponse.swift
//  AELFExchange
//
//  Created by tng on 2019/3/29.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import Foundation
import HandyJSON

class MQTTSymbolResponseData: HandyJSON {
    
    var upList: [SymbolsItem]?
    
    required init() {}
    
}

class MQTTSymbolResponse: BaseAPIBusinessModel {
    
    var data: MQTTSymbolResponseData?
    
}
