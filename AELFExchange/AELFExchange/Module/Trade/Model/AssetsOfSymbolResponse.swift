//
//  AssetsOfSymbolResponse.swift
//  AELFExchange
//
//  Created by tng on 2019/1/23.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import Foundation
import HandyJSON

class AssetsOfSymbolData: HandyJSON {
    
    var currency: String?
    
    var availableAmount: String?
    
    var usdConvertedAmount: String?
    
    required init() {}
    
}

class AssetsOfSymbolResponse: BaseAPIBusinessModel {
    
    var data: [AssetsOfSymbolData]?
    
}
