//
//  TradeVC+OrderSubmit.swift
//  AELFExchange
//
//  Created by tng on 2019/1/23.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import Foundation
import PromiseKit

extension TradeVC {
    
    /// 下单入口.
    func submit() -> Void {
        if self.viewModel.orderType == TradeOrderTypeEnum.limit.rawValue {
            let quantityBuy = NSDecimalNumber(string: self.viewModel.digitalQuantity).multiplying(by: NSDecimalNumber(string: self.viewModel.digitalPrice), withBehavior: kDecimalConfig)
            let quantitySell = NSDecimalNumber(string: self.viewModel.digitalQuantity)
            let targetQuantity = self.viewModel.mode == TradeViewModeEnum.buy.rawValue ? quantityBuy : quantitySell
            let compare = NSDecimalNumber(string: self.viewModel.availableAsset).compare(targetQuantity)
            guard compare == .orderedDescending || compare == .orderedSame else {
                InfoToast(withLocalizedTitle: "可用余额不足")
                return
            }
        } else {
            let compare = NSDecimalNumber(string: self.viewModel.availableAsset).compare(NSDecimalNumber(string: self.viewModel.digitalQuantity))
            guard compare == .orderedDescending || compare == .orderedSame else {
                InfoToast(withLocalizedTitle: "可用余额不足")
                return
            }
        }
        
        if self.viewModel.orderType == TradeOrderTypeEnum.limit.rawValue {
            guard NSDecimalNumber(string: self.viewModel.digitalPrice).compare(0.0) == .orderedDescending else {
                InfoToast(withLocalizedTitle: "请输入价格")
                return
            }
        }
        
        guard NSDecimalNumber(string: self.viewModel.digitalQuantity).compare(0.0) == .orderedDescending else {
            InfoToast(withLocalizedTitle: "请输入数量")
            return
        }
        
        firstly {
            AELFIdentity.shared().auth()
            }.done { [weak self] (succeed, _) in
                guard succeed else {
                    InfoToast(withLocalizedTitle: "密码错误")
                    return
                }
                self?.startLoadingHUD(withMsg: Consts.kMsgInProcess)
                self?.viewModel
                    .createOrderSignal(withPassword: (AELFIdentity.shared().identity?.password)!)
                    .observeValues { (succeed) in
                        self?.stopLoadingHUD()
                        guard succeed == true else { return }
                        InfoToast(withLocalizedTitle: "订单生成成功", duration: 1.5)
                        self?.quantityTextfield.text = nil
                        self?.viewModel.digitalQuantity = "0"
                        self?.viewModel.loadAssets()
                        self?.viewModel.loadBestPrice()
                        self?.viewModel.loadUserOrders()
                }
            }.catch { (error) in
                AELFIdentity.errorToast(withError: error)
        }
    }
    
    /// 撤单入口.
    ///
    /// - Parameter data: order list data.
    func cancel(withData data: UserOrdersListData) {
        guard let orderNo = data.orderNo, let chain = data.counterChain else {
            InfoToast(withLocalizedTitle: "信息错误")
            return
        }
        
        firstly {
            AELFIdentity.shared().auth()
            }.done { [weak self] (succeed, _) in
                guard succeed else {
                    InfoToast(withLocalizedTitle: "密码错误")
                    return
                }
                self?.startLoadingHUD(withMsg: Consts.kMsgInProcess)
                self?.viewModel
                    .cancelOrderSignal(withPassword: (AELFIdentity.shared().identity?.password)!, orderNo: orderNo, chain: chain)
                    .observeValues { [weak self] (succeed) in
                        self?.stopLoadingHUD()
                        guard succeed == true else { return }
                        InfoToast(withLocalizedTitle: "撤销创建成功", duration: 1.5)
                        self?.viewModel.loadUserOrders()
                }
            }.catch { (error) in
                AELFIdentity.errorToast(withError: error)
        }
    }
    
}
