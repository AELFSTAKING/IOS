//
//  FinancialListResponse.swift
//  AELFExchange
//
//  Created by tng on 2019/4/10.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import Foundation
import HandyJSON

class FinancialListData: HandyJSON {
    
    /// 周期.
    var cycleTime: String?
    
    /// 付息模式.
    var interestMode: String?
    
    var productName: String?
    
    /// 地址链接.
    var productUrl: String?
    
    /// 收益率.
    var profitScale: String?
    
    required init() {}
    
}

class FinancialListResponse: BaseAPIBusinessModel {
    
    var data: [FinancialListData]?
    
}
