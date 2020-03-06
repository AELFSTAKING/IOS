//
//  HomeVC+Subscriber.swift
//  AELFExchange
//
//  Created by tng on 2019/3/29.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import Foundation

//extension HomeVC_Deprecated {
//
//    func startReceivingPushData() {
//        MQTTManager.shared().sub(on: .mqtopicHotSymbols, params: [], convertTo: MQTTSymbolTrendingResponse.self) { [weak self] (response) in
//            guard response.succeed == true, let data = response.data, let list = data.hotSymbols else { return }
//            DispatchQueue.main.async {
//                self?.viewModel.gotTrendingSymbols(list)
//            }
//        }
//
//        MQTTManager.shared().sub(on: .mqtopicUpSymbols, params: [], convertTo: MQTTSymbolResponse.self) { [weak self] (response) in
//            guard response.succeed == true, let data = response.data, let list = data.upList else { return }
//            DispatchQueue.main.async {
//                self?.viewModel.gotMarketSymbols(list)
//            }
//        }
//    }
//
//}

extension HomeVC {
    
    func startReceivingPushData() {
//        MQTTManager.shared().sub(on: .mqtopicHotSymbols, params: [], convertTo: MQTTSymbolTrendingResponse.self) { [weak self] (response) in
//            guard self?.isAppeared == true else { return }
//            guard response.succeed == true, let data = response.data, let list = data.hotSymbols else { return }
//            DispatchQueue.main.async {
//                self?.viewModel.gotTrendingSymbols(list)
//            }
//        }
        
        MQTTManager.shared().sub(on: .mqtopicUpSymbols, params: [], convertTo: MQTTSymbolResponse.self) { [weak self] (response) in
            guard self?.isAppeared == true else { return }
            guard response.succeed == true, let data = response.data, let list = data.upList else { return }
            DispatchQueue.main.async {
                self?.viewModel.gotMarketSymbols(list)
            }
        }
    }
    
}
