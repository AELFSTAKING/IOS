//
//  RewardsOfTopupResponse.swift
//  AELFExchange
//
//  Created by tng on 2019/8/8.
//  Copyright © 2019 cex.io. All rights reserved.
//

import Foundation
import HandyJSON

class RewardsOfTopupData: HandyJSON {
    
    var depositTotal: String? // 总充值数量.
    var currency: String? // 充值币种.
    var balance: String? // 余额.
    var rewardCurrency: String? // 奖励币种.
    var sendedReward: String? // 已发放.
    var unsendReward: String? // 未发放.
    
    required init() {}
    
}

class RewardsOfTopupResponse: BaseAPIBusinessModel {
    
    var data: [RewardsOfTopupData]?
    
}
