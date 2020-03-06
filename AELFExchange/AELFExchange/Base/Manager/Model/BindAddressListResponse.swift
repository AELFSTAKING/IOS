//
//  BindAddressListResponse.swift
//  AELFExchange
//
//  Created by tng on 2019/8/4.
//  Copyright © 2019 cex.io. All rights reserved.
//

import Foundation
import HandyJSON

class BindAddressListDataItem: HandyJSON {
    
    var address: String?
    var chain: String?
    var currency: String?
    var gmtCreate: String?
    var gmtModified: String?
    var platformAddress: String?
    var platformChain: String?
    var name: String?
    var status: String?
    
    required init() {}
    
}

class BindAddressListData: HandyJSON {
    
    var addressList: [BindAddressListDataItem]?
    var platformAddress: String?
    
    required init() {}
    
}

class BindAddressListResponse: BaseAPIBusinessModel {
    
    var data: BindAddressListData?
    
}
