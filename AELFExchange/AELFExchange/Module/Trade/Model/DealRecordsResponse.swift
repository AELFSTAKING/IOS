//
//  DealRecordsResponse.swift
//  AELFExchange
//
//  Created by tng on 2019/1/25.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import Foundation
import HandyJSON

class DealRecordsData: HandyJSON {
    
    var dealNo: String?
    
    var symbol: String?
    
    var action: String?
    var theAction: OrderActionEnum {
        return action == "BUY" ? .buy : .sell
    }
    
    var price: String?
    
    var quantity: String?
    
    var gmtDealTime: String?
    
    required init() {}
    
}

class DealRecordsResponse: BaseAPIBusinessModel {
    
    var data: [DealRecordsData]?
    
}
