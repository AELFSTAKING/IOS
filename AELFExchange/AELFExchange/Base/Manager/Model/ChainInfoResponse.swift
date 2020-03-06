//
//  ChainInfoResponse.swift
//  AELFExchange
//
//  Created by tng on 2019/1/17.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import Foundation
import HandyJSON

class ChainInfoData: HandyJSON {
    
    var currency: String?
    
    var chain: String?
    
    required init() {}
    
}

class ChainInfoResponse: BaseAPIBusinessModel {
    
    var data: [ChainInfoData]?
    
}
