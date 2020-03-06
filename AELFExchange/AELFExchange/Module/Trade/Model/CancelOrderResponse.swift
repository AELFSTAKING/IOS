//
//  CancelOrderResponse.swift
//  AELFExchange
//
//  Created by tng on 2019/8/3.
//  Copyright © 2019 cex.io. All rights reserved.
//

import Foundation
import HandyJSON

class CancelOrderMessageData: HandyJSON {
    
    var gmtCreate: String?
    var gmtModified: String?
    var orderNo: String?
    var status: Int?
    var symbol: String?
    var txId: String?
    
    required init() {}
    
}

class CancelOrderData: HandyJSON {
    
    var createStackingTxResp: CreateOrderTxData?
    
    var orderCancelMessage: CancelOrderMessageData?
    
    required init() {}
    
}

class CancelOrderResponse: BaseAPIBusinessModel {
    
    var data: CancelOrderData?
    
}
