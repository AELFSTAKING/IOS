//
//  WithdrawAddressResponse.swift
//  AELFExchange
//
//  Created by tng on 2019/1/30.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import Foundation
import HandyJSON

class WithdrawAddressData: HandyJSON {
    
    var bizId: String?
    
    var chain: String?
    
    var addressRemark: String?
    
    var labelContent: String?
    
    var currencyAddress: String?
    
    var isLabel: Bool {
        return labelContent?.count ?? 0 > 0
    }
    
    required init() {}
    
}

class WithdrawAddressResponse: BaseAPIBusinessModel {
    
    var data: [WithdrawAddressData]?
    
}
