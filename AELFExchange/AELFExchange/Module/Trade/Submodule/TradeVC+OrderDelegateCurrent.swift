//
//  TradeVC+CurrentOrder.swift
//  AELFExchange
//
//  Created by tng on 2019/1/22.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import Foundation
import UIKit

extension TradeVC {
    
    func updateDynamicDataWithGotNewSymbol() -> Void {
        self.ordersCurrentTableView.reloadData()
    }
    
    /// Receive data from The Push !!!ONLY!!!.
    func gotLatestPrice(with latestDealPrice: String?, latestDealPriceUSD: String?, direction: PriceDirectionEnum) -> Void {
        guard let latestDealPrice = latestDealPrice else { return }
        //let legalRate2Legal = NSDecimalNumber(string: CurrencyManager.shared().exchangeRate(forLegalCurrency: CurrencyManager.shared().legalCurrency).exchangeRate)
        let legalRate2Legal = NSDecimalNumber(string: "1.0")
        let legalAmt = NSDecimalNumber(string: latestDealPriceUSD).multiplying(by: legalRate2Legal, withBehavior: kDecimalConfig)
        DispatchQueue.main.async {
            let str = "\(latestDealPrice) \(legalAmt.legalString())"
            let attr = NSMutableAttributedString(string: str)
            attr.addAttributes([
                NSAttributedString.Key.font : UIFont.systemFont(size: 12.0),
                NSAttributedString.Key.foregroundColor : kThemeColorTextNormal
            ], range: NSRange(location: 0, length: str.count))
            attr.addAttributes([
                NSAttributedString.Key.font : kThemeFontDINBold(19.0),
                NSAttributedString.Key.foregroundColor : PriceColor(withDirection: direction)
                ], range: (str as NSString).range(of: latestDealPrice))
            self.ordersCurrentHeaderPrice.priceLabel.attributedText = attr
        }
    }
    
}

extension TradeVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.viewModel.ordersDelegateMode == TradeViewOrderCurrentModeEnum.normal.rawValue ? 2 : 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.cellCount()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let isNormal = self.viewModel.ordersDelegateMode == TradeViewOrderCurrentModeEnum.normal.rawValue
        let cellCountTotal = isNormal ? self.cellCount()*2 : self.cellCount()
        let headerHeight = isNormal ? self.ordersCurrentTableViewHeaderHeight*2.0 : 1.0
        return (tableView.frame.height-headerHeight)/CGFloat(cellCountTotal)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return self.ordersCurrentTableViewHeaderHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return section == 0 ? self.ordersCurrentHeaderTitle : self.ordersCurrentHeaderPrice
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell-delegate")
        cell?.selectionStyle = .none
        if let cell = cell as? TradeOrderCurrentCell {
            if self.viewModel.ordersDelegateMode == TradeViewOrderCurrentModeEnum.normal.rawValue {
                let isBuy = indexPath.section == 1
                if  let list = isBuy ? self.viewModel.delegateOrdersData?.bidList : self.viewModel.delegateOrdersData?.askList,
                    indexPath.row < list.count {
                    self.updateCell(for: cell, indexPath: indexPath, list: list, isBuy: isBuy)
                } else {
                    self.updateNoneCell(for: cell, isBuy: isBuy)
                }
            } else if self.viewModel.ordersDelegateMode == TradeViewOrderCurrentModeEnum.buy.rawValue {
                if let list = self.viewModel.delegateOrdersData?.bidList {
                    self.updateCell(for: cell, indexPath: indexPath, list: list, isBuy: true)
                }
            } else if self.viewModel.ordersDelegateMode == TradeViewOrderCurrentModeEnum.sell.rawValue {
                if let list = self.viewModel.delegateOrdersData?.askList {
                    self.updateCell(for: cell, indexPath: indexPath, list: list, isBuy: false)
                }
            }
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if self.viewModel.ordersDelegateMode == TradeViewOrderCurrentModeEnum.normal.rawValue {
            if  let list = (indexPath.section == 1) ? self.viewModel.delegateOrdersData?.bidList : self.viewModel.delegateOrdersData?.askList,
                indexPath.row < list.count {
                self.fillPriceWithSelectedDelegateOrder(with: list[indexPath.row])
            }
        } else if self.viewModel.ordersDelegateMode == TradeViewOrderCurrentModeEnum.buy.rawValue {
            if  let list = self.viewModel.delegateOrdersData?.bidList,
                indexPath.row < list.count {
                self.fillPriceWithSelectedDelegateOrder(with: list[indexPath.row])
            }
        } else if self.viewModel.ordersDelegateMode == TradeViewOrderCurrentModeEnum.sell.rawValue {
            if  let list = self.viewModel.delegateOrdersData?.askList,
                indexPath.row < list.count {
                self.fillPriceWithSelectedDelegateOrder(with: list[indexPath.row])
            }
        }
    }
    
    func fillPriceWithSelectedDelegateOrder(with data: OrdersDelegateOrderItem?) -> Void {
        guard let price = data?.limitPrice else { return }
        self.priceTextfield.text = price
        self.priceForTextfieldUpdated(with: price)
    }
    
    private func updateCell(for cell: TradeOrderCurrentCell, indexPath: IndexPath, list: [OrdersDelegateOrderItem], isBuy: Bool) -> Void {
        if indexPath.row < list.count {
            let data = list[indexPath.row]
            let totalQuantity = isBuy ? self.viewModel.delegateOrdersTotalQuantityBuy : self.viewModel.delegateOrdersTotalQuantitySell
            let qPercent = (Float(data.quantity ?? "0") ?? 0)/totalQuantity
            cell.sync(with: data, forBuy: isBuy, quantityPercent: qPercent)
        } else {
            self.updateNoneCell(for: cell, isBuy: isBuy)
        }
    }
    
    private func updateNoneCell(for cell: TradeOrderCurrentCell, isBuy: Bool) -> Void {
        let data = OrdersDelegateOrderItem()
        data.quantity = "--"
        data.limitPrice = "--"
        cell.sync(with: data, forBuy: isBuy, quantityPercent: 0)
    }
    
    private func cellCount() -> Int {
        let c = self.viewModel.ordersCurrentTableViewCellCountSingle
        return self.viewModel.ordersDelegateMode == TradeViewOrderCurrentModeEnum.normal.rawValue ? c : c*2+1
    }
    
}
