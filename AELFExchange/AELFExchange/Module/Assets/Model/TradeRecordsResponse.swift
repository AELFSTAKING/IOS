//
//  TradeRecordsResponse.swift
//  AELFExchange
//
//  Created by tng on 2019/1/16.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import Foundation
import HandyJSON

class TradeRecordsItem: HandyJSON {
    
    var isTopup = false
    
    var billNo: String?
    
    var currency: String?
    
    var currencyCode: String?
    
    var createTime: String?
    
    var amount: String?
    
    var walletAddress: String?
    
    var walletAddressLabel: String?
    
    var txId: String?
    
    /// 划转类型.
    var type: String?
    var typeDesc: String {
        if bizType == 3 { return LOCSTR(withKey: "内部转账") }
        if isTopup { return LOCSTR(withKey: "充币") }
        if let d = type {
            if LanguageManager.shared().currentLanguage() != .ZH_HANS {
                return d
            }
            return "\(d) \(LOCSTR(withKey: transferDirection == 1 ? "转入记录" : "转出记录"))"
        }
        return LOCSTR(withKey: "提币")
    }
    
    /// 3:内部转账.
    var bizType: Int?
    var isInternalTx: Bool {
        return bizType == 3
    }
    
    /// 划转方向 IN(1, "转入"), OUT(2, "转出").
    var transferDirection: Int?
    
    var transferStatus: Int?
    private var transferStatusDesc: String {
        switch transferStatus {
        case 1: return LOCSTR(withKey: "成功")
        case 2: return LOCSTR(withKey: "失败")
        default: return LOCSTR(withKey: "未知状态")
        }
    }
    
    /**
     状态
     INPROGRESS(0),
     SUCCESS(1),
     REFUSED(2),
     FAILED(3),
     CANCEL(4),
     PENDING_APPROVAL(5);
     **/
    var status: Int = 0
    var statusDesc: String {
        guard self.isTopup == false else {
            return LOCSTR(withKey: "成功")
        }
        if let _ = type {
            return self.transferStatusDesc
        }
        switch status {
        case 0: return LOCSTR(withKey: "处理中")
        case 1: return LOCSTR(withKey: "成功")
        case 2: return LOCSTR(withKey: "未通过")
        case 3: return LOCSTR(withKey: "失败")
        case 4: return LOCSTR(withKey: "已取消")
        case 5: return LOCSTR(withKey: "审核中")
        default: return LOCSTR(withKey: "未知状态")
        }
    }
    var failedStatusDesc: String? {
        if self.status == 2 {
            return "未通过, 原因:\(auditReason ?? "--")"
        }
        return nil
    }
    var statusColor: UIColor {
        guard self.isTopup == false else {
            return kThemeColorGreen
        }
        if let _ = type {
            return transferStatus == 1 ? kThemeColorGreen : .red
        }
        switch status {
        case 0: return .white
        case 1: return kThemeColorGreen
        case 2: return .red
        case 3: return .red
        case 4: return kThemeColorTextNormal
        case 5: return .white
        default: return kThemeColorTextNormal
        }
    }
    
    var blockchainExplorerUrl: String?
    
    var feeAmount: String?
    
    /// 提币审核原因.
    var auditReason: String?
    
    required init() {}
    
}

class TradeRecordsData: HandyJSON {
    
    var list: [TradeRecordsItem]?
    
    var pagination: BaseAPIBusinessPagination?
    
    required init() {}
    
}

class TradeRecordsResponse: BaseAPIBusinessModel {
    
    var data: TradeRecordsData?
    
}
