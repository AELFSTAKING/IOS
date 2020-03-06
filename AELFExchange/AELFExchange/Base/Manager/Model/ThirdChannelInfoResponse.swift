//
//  ThirdChannelInfoResponse.swift
//  AELFExchange
//
//  Created by tng on 2019/3/11.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import Foundation
import HandyJSON

class ThirdChannelInfoData: HandyJSON {
    
    /// 渠道号.
    var channelNo: String?
    
    /// 用户在渠道对应的临时令牌.
    var channelToken: String?
    
    required init() {}
    
}

class ThirdChannelInfoResponse: BaseAPIBusinessModel {
    
    var data: [ThirdChannelInfoData]?
    
}
