//
//  ETHGassInfoResponse.swift
//  AELFExchange
//
//  Created by tng on 2019/8/5.
//  Copyright © 2019 cex.io. All rights reserved.
//

import Foundation
import HandyJSON

class ETHGassInfoData: HandyJSON {
    
    // 单位eth.
    var fee: String?
    
    // 单位wei.
    var gasLimit: String?
    var slowGasPrice: String?
    var normalGasPrice: String?
    var fastGasPrice: String?
    
    required init() {}
    
}

class ETHGassInfoResponse: BaseAPIBusinessModel {
    
    var data: ETHGassInfoData?
    
}
