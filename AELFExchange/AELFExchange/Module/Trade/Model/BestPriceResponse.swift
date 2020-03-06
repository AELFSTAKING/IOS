//
//  BestPriceResponse.swift
//  AELFExchange
//
//  Created by tng on 2019/1/24.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import Foundation
import HandyJSON

class BestPriceData: HandyJSON {
    
    var symbol: String?
    
    var action: String?
    
    var bestPrice: String?
    
    required init() {}
    
}

class BestPriceResponse: BaseAPIBusinessModel {
    
    var data: BestPriceData?
    
}
