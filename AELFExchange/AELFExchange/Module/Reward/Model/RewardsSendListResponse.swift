//
//  RewardsSendListResponse.swift
//  AELFExchange
//
//  Created by tng on 2019/8/9.
//  Copyright © 2019 cex.io. All rights reserved.
//

import Foundation
import HandyJSON

class RewardsSendListDataItem: HandyJSON {
    
    var rewardAmount: String?
    var rewardCurrency: String?
    var tokenCurrency: String?
    
    required init() {}
    
}

class RewardsSendListData: HandyJSON {
    
    /// 奖励类型：1 充值；2 挖矿.
    var rewardType: Int?
    var rewardTypeDesc: String {
        return rewardType == 1 ? LOCSTR(withKey: "充值奖励"):LOCSTR(withKey: "挖矿奖励")
    }
    
    var sendList: [RewardsSendListDataItem]?
    var sendTime: String? // yyyy.MM.dd HH:mm
    
    required init() {}
    
}

class RewardsSendListResponse: BaseAPIBusinessModel {
    
    var data: [RewardsSendListData]?
    
}
