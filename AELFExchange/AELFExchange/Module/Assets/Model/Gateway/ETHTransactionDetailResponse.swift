//
//  ETHTransactionDetailResponse.swift
//  AELFExchange
//
//  Created by tng on 2019/8/6.
//  Copyright © 2019 cex.io. All rights reserved.
//

import Foundation
import HandyJSON

class ETHTransactionDetailData: HandyJSON {
    
    var blockHash: String?
    var blockNumber: String?
    var creates: String?
    var fee: String?
    var from: String?
    var gasPrice: String?
    var gasUsed: String?
    var hash: String?
    var input: String?
    var nonce: String?
    var publicKey: String?
    var r: String?
    var raw: String?
    var s: String?
    var to: String?
    var transactionIndex: String?
    var v: String?
    var value: String?
    
    required init() {}
    
}

class ETHTransactionDetailResponse: BaseAPIBusinessModel {
    
    var data: ETHTransactionDetailData?
    
}
