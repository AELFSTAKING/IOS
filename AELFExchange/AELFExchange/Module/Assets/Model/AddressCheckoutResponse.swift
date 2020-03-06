//
//  AddressCheckoutResponse.swift
//  AELFExchange
//
//  Created by tng on 2019/1/29.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import Foundation
import HandyJSON

class AddressCheckoutData: HandyJSON {
    
    var isValid: Bool?
    
    required init() {}
    
}

class AddressCheckoutResponse: BaseAPIBusinessModel {
    
    var data: AddressCheckoutData?
    
}
