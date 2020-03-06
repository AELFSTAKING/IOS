//
//  TransactionRecordsResponse.swift
//  AELFExchange
//
//  Created by tng on 2019/8/5.
//  Copyright © 2019 cex.io. All rights reserved.
//

import Foundation
import HandyJSON

class TransactionRecordsDataItem: HandyJSON {
    
    var blockHash: String?
    var blockHeight: String?
    var currency: String?
    var hash: String?
    var receiver: String? // 授权交易中的合约地址.
    var withdrawReceiver: String? // 提现接受地址（用户前端填写的地址）
    var sendTimestamp: String?
    var sender: String?
    var status: Int? // 1成功；0失败；-1待确认.
    var statusDesc: String {
        switch status {
        case 0: return LOCSTR(withKey: "失败")
        case 1: return LOCSTR(withKey: "成功")
        case -1: return LOCSTR(withKey: "待确认")
        default:return "未知"
        }
    }
    
    var tag: String?
    var timestamp: String?
    var txType: String? // DEPOSIT 充值；WITHDRAW 提现；TRANSFER 转账；RECEIPT 收款.
    var txTypeDesc: String {
        switch txType {
        case "DEPOSIT": return LOCSTR(withKey: "充值")
        case "WITHDRAW": return LOCSTR(withKey: "提现")
        case "TRANSFER": return LOCSTR(withKey: "转账")
        case "RECEIPT": return LOCSTR(withKey: "收款")
        default:return "未知"
        }
    }
    var symbol: String {
        return (txType == "DEPOSIT" || txType == "RECEIPT") ? "+":"-"
    }
    
    var value: String?
    
    required init() {}
    
}

class TransactionRecordsData: HandyJSON {
    
    var transactions: [TransactionRecordsDataItem]?
    
    required init() {}
    
}

class TransactionRecordsResponse: BaseAPIBusinessModel {
    
    var data: TransactionRecordsData?
    
}
