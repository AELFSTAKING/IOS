//
//  WalletEnum.swift
//  AELFExchange
//
//  Created by tng on 2019/7/31.
//  Copyright © 2019 cex.io. All rights reserved.
//

import Foundation

public enum AELFWalletName: String {
    case Ethereum = "Ethereum"
    case Tron = "Tron"
    case Zilliqa = "Zilliqa"
    case HPB = "HPB"
    case BTC = "Bitcoin"
}

public enum AELFChainName: String {
    case KOFOPAIR = "KOFOPAIR"
    case Bitcoin = "BTC"
    case Ethereum = "ETH"
    case EOS = "EOS"
    case TRON = "TRX"
    case Zilliqa = "ZIL"
    case HPB = "HPB"
}

public enum AELFCurrencyName: String {
    case KOFOPAIR = "KOFOPAIR"
    case BTC = "BTC"
    case ETH = "ETH"
    case EOS = "EOS"
    case TRX = "TRX"
    case ZIL = "ZIL"
    case HPB = "HPB"
    case USDT_ETH = "USDT-ERC20"
    case USDT_BTC = "USDT-OMNI"
}
