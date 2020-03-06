//
//  MarketKLineVC+Orders.swift
//  AELFExchange
//
//  Created by tng on 2019/1/21.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import Foundation
import UIKit

extension MarketKLineVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.viewModel.orderType == MarketDetailOrderTypeEnum.depthAndDelegateOrder.rawValue {
            return self.viewModel.delegateOrdersCount
        }
        return self.viewModel.latestDealOrdersData.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return orderCellHeight
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return orderCellHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if self.viewModel.orderType == MarketDetailOrderTypeEnum.depthAndDelegateOrder.rawValue {
            self.headerDelegate.sync(
                with: self.viewModel.currency ?? "--",
                baseCurrency: self.viewModel.symbol.baseCurrencyFromSymbol() ?? "--"
            )
            return self.headerDelegate
        } else {
            return self.headerLatestDeal
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let flag = self.viewModel.orderType == MarketDetailOrderTypeEnum.depthAndDelegateOrder.rawValue ? "cell-delegate" : "cell-dealist"
        let cell = tableView.dequeueReusableCell(withIdentifier: flag)
        cell?.selectionStyle = .none
        
        // Delegate Order.
        if self.viewModel.orderType == MarketDetailOrderTypeEnum.depthAndDelegateOrder.rawValue {
            if let cell = cell as? MarketDelegateOrderCell {
                // Buy.
                if  let list = self.viewModel.delegateOrdersData?.bidList,
                    indexPath.row < list.count {
                    let data = list[indexPath.row]
                    let qPercent = (Float(data.quantity ?? "0") ?? 0)/self.viewModel.delegateOrdersTotalQuantityBuy
                    cell.sync(with: data, forBuy: true, quantityPercent: qPercent)
                }
                
                // Sell.
                if  let list = self.viewModel.delegateOrdersData?.askList,
                    indexPath.row < list.count {
                    let data = list[indexPath.row]
                    let qPercent = (Float(data.quantity ?? "0") ?? 0)/self.viewModel.delegateOrdersTotalQuantitySell
                    cell.sync(with: data, forBuy: false, quantityPercent: qPercent)
                }
            }
            
        // Latest Deal.
        } else {
            if  indexPath.row < self.viewModel.latestDealOrdersData.count,
                let data = self.viewModel.latestDealOrdersData[indexPath.row] as? OrdersLatestdealData,
                let cell = cell as? MarketDealListCell {
                cell.sync(with: data)
            }
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
