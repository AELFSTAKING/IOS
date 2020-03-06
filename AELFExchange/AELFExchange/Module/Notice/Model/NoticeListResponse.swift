//
//  NoticeListResponse.swift
//  AELFExchange
//
//  Created by tng on 2019/1/15.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import Foundation
import HandyJSON

class NoticeListItem: HandyJSON {
    
    var bizId: String?
    
    var title: String?
    
    var summary: String?
    
    var publishTime: String?
    
    required init() {}
    
}

class NoticeListData: HandyJSON {
    
    var list: [NoticeListItem]?
    
    var pagination: BaseAPIBusinessPagination?
    
    required init() {}
    
}

class NoticeListResponse: BaseAPIBusinessModel {
    
    var data: NoticeListData?
    
}
