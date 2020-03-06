//
//  OrdersDelegateResponse.swift
//  AELFExchange
//
//  Created by tng on 2019/1/21.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import Foundation
import HandyJSON

class OrdersDelegateLatestDealItem: HandyJSON {
    
    var price: String?
    
    var usdPrice: String?
    
    var direction: String?
    var theDirection: PriceDirectionEnum {
        switch Int(direction ?? "0") ?? 0 {
        case  0: return .flat
        case  1: return .up
        case -1: return .down
        default: return .flat
        }
    }
    
    required init() {}
    
}

class OrdersDelegateOrderItem: HandyJSON {
    
    var isEmptyCell = false
    
    var amount: String?
    
    var amountAccuracy: String?
    
    var limitPrice: String?
    
    var quantity: String?
    
    required init() {}
    
}

class OrdersDelegateData: HandyJSON {
    
    var symbol: String?
    
    var limitSize: Int?
    
    /// 卖单，这个表示喊价格，那么就是询价，所以为ask.
    var askList: [OrdersDelegateOrderItem]?
    
    /// 买单，这个表示用一个价格去竞争，所以为bid.
    var bidList: [OrdersDelegateOrderItem]?
    
    var step: String?
    
    /// 卖单进度条对标数量.
    var askQuantity: String?
    
    /// 买单进度条对标数量.
    var bidQuantity: String?
    
    /// 最新成交数据.
    var latestDeal: OrdersDelegateLatestDealItem?
    
    /// From MQTT.
    var mqttTimestamp: String?
    
    required init() {}
    
    func mapping(mapper: HelpingMapper) {
        mapper <<< self.mqttTimestamp <-- "timestamp"
    }
    
}

class OrdersDelegateResponse: BaseAPIBusinessModel {
    
    var data: OrdersDelegateData?
    
}
