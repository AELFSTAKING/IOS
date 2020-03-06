//
//  CurrencyInfoResponse.swift
//  AELFExchange
//
//  Created by tng on 2019/1/16.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import Foundation
import HandyJSON

class CurrencyInfoData: HandyJSON {
    
    var currencyCode: String?
    
    /// 发行日期.
    var issueDate: String?
    
    /// 发行总量.
    var issueQuantity: String?
    
    /// 流通总量.
    var circulateQuantity: String?
    
    /// 众筹价格.
    var issuePrice: String?
    
    /// 白皮书.
    var whitePaper: String?
    
    /// 官网链接.
    var officialWebsite: String?
    
    /// 区块链浏览器.
    var blockChainAddressSearch: String?
    
    /// 图片文件ID.
    var imageFileId: String?
    
    /// 图片文件URL.
    var imageFileUrl: String?
    var currencyTwIntroduction: String?
    
    /// 币种名称.
    var currencyFullName: String?
    
    /// 币种简介.
    var currencyCnIntroduction: String?
    var currencyEnIntroduction: String?
    
    required init() {}
    
}

class CurrencyInfoResponse: BaseAPIBusinessModel {
    
    var data: CurrencyInfoData?
    
}
