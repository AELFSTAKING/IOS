//
//  WechatsResponse.swift
//  AELFExchange
//
//  Created by tng on 2019/1/19.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import Foundation
import HandyJSON

class WechatsResponseDataListItem: HandyJSON {
    
    var weixin: String?
    
    var imgUrl: String?
    
    required init() {}
    
}

class WechatsResponseData: HandyJSON {
    
    var list: [WechatsResponseDataListItem]?
    
    required init() {}
    
}

class WechatsResponse: BaseAPIBusinessModel {
    
    var data: WechatsResponseData?
    
}
