//
//  AllCurrencyResponse.swift
//  AELFExchange
//
//  Created by tng on 2019/1/16.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import Foundation
import HandyJSON

class AllCurrencyData: HandyJSON {
    
    var bizId: String?
    
    var currency: String?
    
    var rechargeAble: Bool?
    
    var withdrawAble: Bool?
    
    var rechargeAttention: String?
    
    var withdrawAttention: String?
    
    var isLabelCoin: Bool?
    
    var logoUrl: String?
    
    required init() {}
    
}

class AllCurrencyResponse: BaseAPIBusinessModel {
    
    var data: [AllCurrencyData]?
    
}
