//
//  OrderDealDetailResponse.swift
//  AELFExchange
//
//  Created by tng on 2019/8/6.
//  Copyright © 2019 cex.io. All rights reserved.
//

import Foundation
import HandyJSON

class OrderDealDetailDealItem: HandyJSON {
    
    var date: String?
    var price: String?
    var quantity: String?
    var txId: String?
    var url: String?
    
    required init() {}
    
}

class OrderDealDetailData: HandyJSON {
    
    var action: Int?
    var theAction: OrderActionEnum {
        return OrderActionEnum(rawValue: action ?? 2)!
    }
    var actionDescription: String {
        return orderTypeDescription + (theAction == .buy ? LOCSTR(withKey: "买入"):LOCSTR(withKey: "卖出"))
    }
    
    var address: String?
    var amount: String?
    var amountRemaining: String?
    var chain: String?
    var counterChain: String?
    var counterChainAddress: String?
    var counterCurrency: String?
    var currency: String?
    var fee: String?
    var feeCurrency: String?
    var fromClientType: String?
    var groupCode: String?
    var level: String?
    var makerFeeRate: String?
    var orderNo: String?
    
    var orderType: String? // 1 限价；2市价.
    var orderTypeDescription: String {
        return orderType == "1" ? "限价":"市价"
    }
    
    var priceAverage: String?
    var priceLimit: String?
    var productCode: String?
    var quantity: String?
    var quantityRemaining: String?
    var state: String? // 0 刚创建，1 未撮合成功，2 部分撮合，3 撮合完成.
    var status: String? // 订单状态：3 待签名（挂单阶段）4 待确认 0 正常 1 取消 2 处理中.
    var statusDesc: String {
        switch status {
        case "4":return LOCSTR(withKey: "待确认")
        case "0":return LOCSTR(withKey: "正常")
        case "1":return LOCSTR(withKey: "已取消")
        case "3":return LOCSTR(withKey: "已完成")
        default:return LOCSTR(withKey: "未知")
        }
    }
    var statusDescOfDealList: String {
        switch status {
        case "4":return LOCSTR(withKey: "待确认")
        case "0","3":return LOCSTR(withKey: "已完成")
        case "1":return LOCSTR(withKey: "已取消")
        default:return LOCSTR(withKey: "未知")
        }
    }
    
    var symbol: String?
    var takerFeeRate: String?
    var txId: String?
    var url: String?
    var utcCreate: String?
    var utcUpdate: String?
    var tradeDeals: [OrderDealDetailDealItem]?
    
    required init() {}
    
}

class OrderDealDetailResponse: BaseAPIBusinessModel {
    
    var data: OrderDealDetailData?
    
}
