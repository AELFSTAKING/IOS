//
//  OrdersLatestdealResponse.swift
//  AELFExchange
//
//  Created by tng on 2019/1/21.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import Foundation
import HandyJSON

class OrdersLatestdealData: HandyJSON {

    var dealNo: String?
    
    var symbol: String?
    
    var price: String?
    
    var quantity: String?
    
    var action: String?
    var theDirection: PriceDirectionEnum {
        if action == "BUY" {
            return .up
        } else if action == "SELL" {
            return .down
        }
        return .flat
    }
    
    var utcDeal: String?
    
    required init() {}

}

class OrdersLatestdealResponse: BaseAPIBusinessModel {
    
    var data: [OrdersLatestdealData]?
    
}
