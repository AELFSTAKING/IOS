//
//  SendOrderTxResponse.swift
//  AELFExchange
//
//  Created by tng on 2019/8/3.
//  Copyright © 2019 cex.io. All rights reserved.
//

import Foundation
import HandyJSON

class SendOrderTxData: HandyJSON {
    
    var txHash: String?
    
    required init() {}
    
}

class SendOrderTxResponse: BaseAPIBusinessModel {
    
    var data: SendOrderTxData?
    
}
