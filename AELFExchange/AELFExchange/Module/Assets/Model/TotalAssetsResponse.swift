//
//  TotalAssetsResponse.swift
//  AELFExchange
//
//  Created by tng on 2019/8/2.
//  Copyright © 2019 cex.io. All rights reserved.
//

import Foundation
import HandyJSON

class TotalAssetsDataItem: HandyJSON {
    
    var balance: String?
    
    var chain: String?
    
    var currency: String?
    
    var targetCurrency: String?
    
    var usdtAsset: Bool?
    
    var usdtPrice: String?
    
    required init() {}
    
}

class TotalAssetsData: HandyJSON {
    
    var currencyList: [TotalAssetsDataItem]?
    
    var totalUsdAsset: String?
    
    var totalUsdtAsset: String?
    
    required init() {}
    
}

class TotalAssetsResponse: BaseAPIBusinessModel {
    
    var data: TotalAssetsData?
    
}
