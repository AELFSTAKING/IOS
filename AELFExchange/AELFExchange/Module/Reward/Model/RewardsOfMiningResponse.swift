//
//  RewardsOfMiningResponse.swift
//  AELFExchange
//
//  Created by tng on 2019/8/8.
//  Copyright © 2019 cex.io. All rights reserved.
//

import Foundation
import HandyJSON

class RewardsOfMiningData: HandyJSON {
    
    var balance: String? // 余额.
    var currency: String? // 币种.
    var power: String? // 挖矿算力.
    var rewardCurrency: String? // 奖励币种.
    var sendedReward: String? // 已发放.
    var unsendReward: String? // 未发放.
    
    required init() {}
    
}

class RewardsOfMiningResponse: BaseAPIBusinessModel {
    
    var data: [RewardsOfMiningData]?
    
}
