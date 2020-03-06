//
//  WithdrawInfoResponse.swift
//  AELFExchange
//
//  Created by tng on 2019/1/29.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import Foundation
import HandyJSON

class WithdrawInfoData: HandyJSON {
    
    /// 当日可提现总次数.
    var totalOpTimes: Int?
    
    /// 当日剩余可提现总次数.
    var availableOpTimes: Int?
    
    /// 当日可提现总金额.
    var totalAmount: String?
    
    /// 当日剩余可提现总金额.
    var availableTotalAmount: String?
    
    /// 当前可用余额.
    var availableAmount: String?
    
    /// 单次最小提币金额.
    var minAmount: String?
    
    /// 单次最大提币金额.
    var maxAmount: String?
    
    /// 本次最大提币额度.
    var availableCurrMaxAmount: String?
    
    var fee: String?
    
    /// 提币精度.
    var scale: Int?
    
    /// 提币须知.
    var withdrawAttention: String?
    
    /// 最高手续费限制.
    var maxLimitFeeAmount: String?
    
    /// 最低手续费限制.
    var minLimitFeeAmount: String?
    
    /// 是否标签币 0否 1是.
    var labelFlag: Bool?
    
    required init() {}
    
}

class WithdrawInfoResponse: BaseAPIBusinessModel {
    
    var data: WithdrawInfoData?
    
}
