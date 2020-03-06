//
//  OrderRecordsResponse.swift
//  AELFExchange
//
//  Created by tng on 2019/1/24.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import Foundation
import HandyJSON

public enum OrderActionEnum: Int {
    case buy = 2
    case sell = 1
}

class OrderRecordsDataItem: HandyJSON {
    
    var orderNo: String?
    
    var symbol: String?
    
    var action: String?
    var theAction: OrderActionEnum {
        return action == "BUY" ? .buy : .sell
    }
    
    /// 委托数量,如果是买入市价单，那么委托数量是0.
    var quantity: String?
    
    /// 成交数量.
    var quantityDeal: String?
    
    /// 订单剩余数量.
    var quantityRemain: String?
    
    /// 市价挂单总额.
    var amount: String?
    
    /// 市价挂单未成交计价币种金额.
    var amountRemain: String?
    
    var fee: String?
    
    var feeCurrency: String?
    
    /// 订单类型，市价单还是限价单 LMT\MKT.
    var orderType: String?
    
    /// 成交均价.
    var priceAverage: String?
    
    /// 限价单的限价，如果是市价单返回的是0，因为没有价格.
    var priceLimit: String?
    
    /// 订单状态，DEAL、CANCEL、OPEN.
    var status: String?
    
    /// 订单创建时间（委托时间）.
    var gmtCreate: String?
    
    required init() {}
    
}

class OrderRecordsData: HandyJSON {
    
    var list: [OrderRecordsDataItem]?
    
    var pagination: BaseAPIBusinessPagination?
    
    required init() {}
    
}

class OrderRecordsResponse: BaseAPIBusinessModel {
    
    var data: OrderRecordsData?
    
}
