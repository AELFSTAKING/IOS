//
//  CreateOrderResponse.swift
//  AELFExchange
//
//  Created by tng on 2019/8/3.
//  Copyright © 2019 cex.io. All rights reserved.
//

import Foundation
import HandyJSON

class CreateOrderInfoData: HandyJSON {
    
    var action: String?
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
    var orderType: String?
    var priceAverage: String?
    var priceLimit: String?
    var productCode: String?
    var quantity: String?
    var quantityRemaining: String?
    var state: String?
    var status: String?
    var symbol: String?
    var takerFeeRate: String?
    var txId: String?
    var utcCreate: String?
    var utcUpdate: String?
    
    required init() {}
    
}

class CreateOrderTxData: HandyJSON {
    
    var blockHeight: String?
    var gasLimit: String?
    var gasPrice: String?
    var nonce: String?
    var rawTransaction: String?
    
    required init() {}
    
}

class CreateOrderData: HandyJSON {
    
    var createOrderTxResp: CreateOrderTxData?
    
    var order: CreateOrderInfoData?
    
    required init() {}
    
}

class CreateOrderResponse: BaseAPIBusinessModel {
    
    var data: CreateOrderData?
    
}
