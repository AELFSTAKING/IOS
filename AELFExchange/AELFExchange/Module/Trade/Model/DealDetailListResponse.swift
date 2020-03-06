//
//  DealDetailListResponse.swift
//  AELFExchange
//
//  Created by tng on 2019/1/27.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import Foundation
import HandyJSON

class DealDetailListData: HandyJSON {
    
    var dealTime: String?
    
    var dealPrice: String?
    
    var dealQuantity: String?
    
    required init() {}
    
}

class DealDetailListResponse: BaseAPIBusinessModel {
    
    var data: [DealDetailListData]?
    
}
