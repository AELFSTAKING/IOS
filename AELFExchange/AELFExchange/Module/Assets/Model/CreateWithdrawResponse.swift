//
//  CreateWithdrawResponse.swift
//  AELFExchange
//
//  Created by tng on 2019/8/6.
//  Copyright © 2019 cex.io. All rights reserved.
//

import Foundation
import HandyJSON

class CreateWithdrawData: HandyJSON {
    
    var withdrawNo: String?
    var takerChain: String?
    var takerCurrency: String?
    var takerKofoId: String?
    var takerAddress: String?
    var takerCounterAddress: String?
    var takerAmount: String?
    var takerFee: String?
    var takerSignature: String?
    var makerChain: String?
    var makerCurrency: String?
    var makerAmount: String?
    var makerFee: String?
    var settlementId: String?
    var settlementResponse: String?
    
    required init() {}
    
}

class CreateWithdrawResponse: BaseAPIBusinessModel {
    
    var data: CreateWithdrawData?
    
}
