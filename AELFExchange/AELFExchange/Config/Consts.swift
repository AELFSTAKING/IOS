//
//  Consts.swift
//  AELF
//
//  Created by tng on 2018/9/12.
//  Copyright © 2018年 AELF. All rights reserved.
//

import Foundation

class Consts {
    
    public static let kBundleID = "com.aelf.exchange.store"
    public static let kBundleIDInHouse = "com.aelf.exchange.prod"
    public static let kOSIDCreationAccount = "kOSIDApplicationCreate"
 
    // Notificatoins.
    public static let kNotificationTabarIndexChanged = "kNotificationTabarIndexChanged"
    public static let kNotificationShowCollMKT = "kNotiShowCollectionMarket"
    public static let kNotificationShowTrade = "kNotificationShowTrade"
    public static let kNotificationRefreshAppAndGameWeb = "kNotificationRefreshAppAndGameWeb"
    
    // Constants.
    public static let kAppName = ""
    public static let kAppDownloadUrl = "http://....html"
    public static let kAppSource = "native"
    public static let kAppOS = 1
    public static let kAreaCodeDefault = "86"
    public static let kAreaCodeName = LOCSTR(withKey: "中国")
    public static let kAreaCountryId = "40"
    public static let kCountdownDefault = 60
    public static let kGeneralOprTimeout: Double = 60.0
    public static let kDepthDefault = "00001"
    public static let kDepthMenuDefault = "4\(LOCSTR(withKey: "位小数"))"
    public static let kKLineRangeDefault = "900000"
    public static func appChannel() -> String {
        if let info = Bundle.main.infoDictionary, let bid = info["CFBundleIdentifier"] as?String {
            return bid == Consts.kBundleIDInHouse ? "In House" : "App Store"
        }
        return "In House"
    }
    public static let kAESKey = "1c^gh_^ju_1&09.,"
    public static let kAESIV = "1f3-?bh.f,'1ju'u"
    
    // Security.
    public static let kDefaultToken = "HeyI05hM"
    public static let kDefaultAPPID = "ios"
    public static let kDefaultAESKey = "b0ae12a422d6338d4b2ff413g76vb2g8"
    public static let kDefaultAESIV = "b0ae22b12c36938d"
    
    // APP Key.
    public static let kBuglyAppID = ""//fixme:fill with your appid of bugly.
    public static let kUMengAppKey = ""
    public static let kJPushAppKey = ""
    public static let kTingYunAppKey = ""
    
}

// MARK: - Message.
extension Consts {
    
    public static let kMsgNetError = LOCSTR(withKey: "连接失败，请检查手机网络")
    public static let kMsgSubmit = LOCSTR(withKey: "提交中")
    public static let kMsgLoading = LOCSTR(withKey: "加载中")
    public static let kMsgInProcess = LOCSTR(withKey: "处理中")
    public static let kMsgNoMore = LOCSTR(withKey: "已经全部加载完毕")
    public static let kMsgLoadMore = LOCSTR(withKey: "上拉加载更多")
    public static let kMsgLoadMoreManually = LOCSTR(withKey: "点击加载更多")
    public static let kMsgLogin = LOCSTR(withKey: "登录中")
    
}

// MARK: - Regex.
extension Consts {
    
    public static let kRegexEmail = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
    public static let kRegexMobilePhone = "^1[3456789]\\d{9}$"
    public static let kRegexLoginPwd = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)[\\s\\S]{8,20}$"
    public static let kRegexNoSymbol = "^[A-Za-z0-9]{1,128}"
    public static let kRegexAccountName = "^[\\s\\S]{1,16}$"
    public static let kRegexIDCard = "^[1-9]\\d{5}(18|19|([23]\\d))\\d{2}((0[1-9])|(10|11|12))(([0-2][1-9])|10|20|30|31)\\d{3}[0-9Xx]$"
    
}

// MARK: - Business.
extension Consts {
    
    public static let kWeichatsUrl = ""//fixme:contacts list web link.
    public static let kOnlineServiceUrl = ""//fixme:online service web link.
    public static let kWithdrawInternalAddrInfo = "注意：此为?用户\"{user}\"的地址，为了加快到账速度，此单将为您安排内部通道。"
    public static let kTokenFlagAelfToken = "AELF-TOKEN"
    
}
