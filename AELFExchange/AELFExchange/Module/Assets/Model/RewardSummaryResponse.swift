//
//  RewardSummaryResponse.swift
//  AELFExchange
//
//  Created by tng on 2019/8/7.
//  Copyright © 2019 cex.io. All rights reserved.
//

import Foundation
import HandyJSON

class RewardSummaryData: HandyJSON {
    
    var sendedReward: String? // 已发放.
    var sendedRewardFormatted: String {
        return NSDecimalNumber(string: sendedReward).string(withDecimalLen: 2, minLen: 2)
    }
    
    var unsendReward: String? // 未发放.
    var unsendRewardFormatted: String {
        return NSDecimalNumber(string: unsendReward).string(withDecimalLen: 2, minLen: 2)
    }
    
    var rewardCurrency: String? // 奖励币种.
    
    required init() {}
    
}

class RewardSummaryResponse: BaseAPIBusinessModel {
    
    var data: RewardSummaryData?
    
}
