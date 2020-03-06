//
//  GT3API2Response.swift
//  AELFExchange
//
//  Created by tng on 2019/1/14.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import Foundation
import HandyJSON

class GT3API2ResponseData: HandyJSON {
    
    var captchaIdentifier: String?
    
    required init() {}
    
}

class GT3API2Response: BaseAPIBusinessModel {
    
    var data: GT3API2ResponseData?
    
}
