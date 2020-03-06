//
//  SecurityInfoResponse.swift
//  AELFExchange
//
//  Created by tng on 2019/3/4.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import Foundation
import HandyJSON

class SecurityInfoResponseData: HandyJSON {
    
    var userNo: String?
    
    var privateKey: String?
    
    required init() {}
    
}

class SecurityInfoResponse: BaseAPIBusinessModel {
    
    var data: SecurityInfoResponseData?
    
}
