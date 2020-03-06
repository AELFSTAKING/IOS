//
//  TradeVC+DealLatest.swift
//  AELFExchange
//
//  Created by tng on 2019/1/22.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import Foundation
import UIKit
import Result
import ReactiveSwift
import DZNEmptyDataSet

extension TradeVC {
    
    private func updateContenHeight() {
        if self.viewModel.userOrdersData.count == 0 {
            self.contentViewHeightOffset.constant = self.userOrdersEmptyHeightMin
            return
        }
        self.contentViewHeightOffset.constant = CGFloat(self.viewModel.userOrdersData.count)*TradeVC.userOrdersCellHeight
    }
    
    func updateUserOrders() {
        let list = self.viewModel.userOrdersData
        self.userOrdersDatasource.userOrdersData.removeAll()
        if list.count > 0 {
            self.userOrdersDatasource.userOrdersData.append(contentsOf: list)
        }
        self.userOrdersTableView.reloadData()
        self.updateContenHeight()
    }
    
    func reloadUserOrders() {
        self.userOrdersDatasource.userOrdersData.removeAll()
        self.userOrdersTableView.reloadData()
        self.updateContenHeight()
        self.viewModel.loadUserOrders(withFirstPage: true)
    }
    
}

class TradeOrderBookDataSouce: NSObject, UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetSource {
    
    let (headerButtonPressedSignal, headerButtonPressedObserver) = Signal<OrderBookHeaderViewButtonType, NoError>.pipe()
    let (cancelButtonPressedSignal, cancelButtonPressedObserver) = Signal<UserOrdersListData, NoError>.pipe()
    let (itemPressedSignal, itemPressedObserver) = Signal<UserOrdersListData, NoError>.pipe()
    
    /// Injected from the outside instance that 'TradeVC'.
    var userOrdersType = UserOrderTypeEnum.current
    var userOrdersData = [UserOrdersListData]()
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.userOrdersData.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return TradeVC.userOrdersCellHeight
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 48.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = Bundle.main.loadNibNamed("OrderBookHeaderView", owner: nil, options: nil)?.first as! OrderBookHeaderView
        header.updateStatus(toCurrent: self.userOrdersType == .current)
        header.buttonPressedSignal.observeValues { [weak self] (buttonType) in
            self?.headerButtonPressedObserver.send(value: buttonType)
        }
        return header
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell-orderbook")
        cell?.selectionStyle = .none
        if  indexPath.row < self.userOrdersData.count,
            let cell = cell as? OrderBookCell {
            cell.cancelButton.tag = indexPath.row+1
            cell.cancelButton.reactive.controlEvents(.touchUpInside)
                .take(until: cell.reactive.prepareForReuse)
                .observeValues { [weak self] (button) in
                let index = button.tag-1
                guard index < (self?.userOrdersData.count ?? 0), let data = self?.userOrdersData[index] else { return }
                self?.cancelButtonPressedObserver.send(value: data)
            }
            cell.sync(
                withData: self.userOrdersData[indexPath.row],
                isDeal: self.userOrdersType == .history
            )
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard indexPath.row < self.userOrdersData.count else {
            return
        }
        self.itemPressedObserver.send(value: self.userOrdersData[indexPath.row])
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "icon-trade-emptyorder")!
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string: "暂无记录~", attributes: [
            NSAttributedString.Key.foregroundColor : kThemeColorTextUnabled,
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14.0, weight: .medium)
            ])
    }
    
}
