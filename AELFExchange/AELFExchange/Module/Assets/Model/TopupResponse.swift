//
//  TopupResponse.swift
//  AELFExchange
//
//  Created by tng on 2019/1/16.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import Foundation
import HandyJSON

class TopupData: HandyJSON {
    
    var currency: String?
    
    var rechargeAddress: String?
    
    /// 充币须知.
    var rechargeAttention: String?
    
    var isLabelCoin: Bool?
    
    var labelContent: String?
    
    required init() {}
    
}

class TopupResponse: BaseAPIBusinessModel {
    
    var data: TopupData?
    
}
