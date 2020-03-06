//
//  BannerAndNoticeResponse.swift
//  AELFExchange
//
//  Created by tng on 2019/1/15.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import Foundation
import HandyJSON

class BannerData: HandyJSON {
    
    var bizId: String?
    
    var imageUrl: String?
    
    var link: String?
    
    required init() {}
    
}

class NoticeData: HandyJSON {
    
    var bizId: String?
    
    var title: String?
    
    var publishTime: String?
    
    required init() {}
    
}

class BannerAndNoticeResponseData: HandyJSON {
    
    var bannerList: [BannerData]?
    
    var announcementList: [NoticeData]?
    
    required init() {}
    
}

class BannerAndNoticeResponse: BaseAPIBusinessModel {
    
    var data: BannerAndNoticeResponseData?
    
}
