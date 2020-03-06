//
//  SupportsListResponse.swift
//  AELFExchange
//
//  Created by tng on 2019/1/16.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import Foundation
import HandyJSON

class SupportsListItem: HandyJSON {
    
    var bizId: String?
    
    var title: String?
    
    var summary: String?
    
    var publishTime: String?
    
    required init() {}
    
}

class SupportsListData: HandyJSON {
    
    var list: [SupportsListItem]?
    
    var pagination: BaseAPIBusinessPagination?
    
    required init() {}
    
}

class SupportsListResponse: BaseAPIBusinessModel {
    
    var data: SupportsListData?
    
}
