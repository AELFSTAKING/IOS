//
//  NotificationObjTrade.swift
//  AELFExchange
//
//  Created by tng on 2019/1/25.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import Foundation

public enum NotificationObjTradeAction: Int {
    case buy
    case sell
}

public class NotificationObjTrade {
    
    var symbol = ""
    
    var action = NotificationObjTradeAction.buy
    
    convenience init(with action: NotificationObjTradeAction, symbol: String) {
        self.init()
        self.action = action
        self.symbol = symbol
    }
    
}
