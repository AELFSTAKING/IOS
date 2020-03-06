//
//  AddressTypeResponse.swift
//  AELFExchange
//
//  Created by tng on 2019/4/29.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import Foundation
import HandyJSON

class AddressTypeData: HandyJSON {
    
    /// 是否是内部地址.
    var isInternal: Bool?
    
    /// 如果是内部地址，返回这个地址的归属人，如果是绑定了手机返回手机号（已隐藏处理），如果是只有邮箱返回邮箱（已隐藏处理）.
    var owner: String?
    
    required init() {}
    
}

class AddressTypeResponse: BaseAPIBusinessModel {
    
    var data: AddressTypeData?
    
}
