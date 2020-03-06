//
//  ETHBalanceResponse.swift
//  AELFExchange
//
//  Created by tng on 2019/8/14.
//  Copyright © 2019 cex.io. All rights reserved.
//

import Foundation
import HandyJSON

class ETHBalanceData: HandyJSON {
    
    var amount: String?
    
    required init() {}
    
}

class ETHBalanceResponse: BaseAPIBusinessModel {
    
    var data: ETHBalanceData?
    
}
