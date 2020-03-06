//
//  KLineResponse.swift
//  AELFExchange
//
//  Created by tng on 2019/1/21.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import Foundation
import HandyJSON

class KLineItem: HandyJSON {
    
    var first: String?
    
    var last: String?
    
    var max: String?
    
    var min: String?
    
    var quantity: String?
    
    var time: String?
    
    var applies: String?
    
    var dealAmount: String?
    
    var minuteAvg: String?
    
    var symbol: String?
    
    var range: String?
    
    required init() {}
    
}

class KLineData: HandyJSON {
    
    var quotationHistory: [KLineItem]?
    
    required init() {}
    
}

class KLineResponse: BaseAPIBusinessModel {
    
    var data: KLineData?
    
}
