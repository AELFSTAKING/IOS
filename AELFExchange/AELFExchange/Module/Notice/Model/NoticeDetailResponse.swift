//
//  NoticeDetailResponse.swift
//  AELFExchange
//
//  Created by tng on 2019/1/15.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import Foundation
import HandyJSON

class NoticeDetailResponseData: HandyJSON {
    
    var bizId: String?
    
    var title: String?
    
    var summary: String?
    
    var content: String?
    
    var publishTime: String?
    
    required init() {}
    
}

class NoticeDetailResponse: BaseAPIBusinessModel {
    
    var data: NoticeDetailResponseData?
    
}
