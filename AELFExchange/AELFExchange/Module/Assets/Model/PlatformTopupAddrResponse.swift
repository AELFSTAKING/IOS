//
//  PlatformTopupAddrResponse.swift
//  AELFExchange
//
//  Created by tng on 2019/8/4.
//  Copyright © 2019 cex.io. All rights reserved.
//

import Foundation
import HandyJSON

class PlatformTopupAddrData: HandyJSON {
    
    var address: String?
    
    required init() {}
    
}

class PlatformTopupAddrResponse: BaseAPIBusinessModel {
    
    var data: PlatformTopupAddrData?
    
}
