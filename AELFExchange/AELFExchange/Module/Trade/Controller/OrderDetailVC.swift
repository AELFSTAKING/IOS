//
//  OrderDetailVC.swift
//  CEXExchange
//
//  Created by tng on 2019/1/24.
//  Copyright © 2019 cex.io. All rights reserved.
//

import Foundation
import UIKit
import SafariServices
import DZNEmptyDataSet

class OrderDetailVC: BaseViewController {
    
    @IBOutlet weak var currencyLabel: Label!
    @IBOutlet weak var baseCurrencyLabel: Label!
    @IBOutlet weak var actionLabel: UILabel! {
        didSet {
            actionLabel.addBorder(withWitdh: 0.8, color: kThemeColorRed)
        }
    }
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var dealPercentLabel: Label!
    @IBOutlet weak var orderTypeLabel: Label!
    @IBOutlet weak var dealAmtLabel: Label!
    @IBOutlet weak var avgPriceLabel: Label!
    @IBOutlet weak var feeLabel: Label!
    @IBOutlet weak var dealAmountLabel: Label!
    @IBOutlet weak var txidLabel: Label!
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.backgroundColor = .clear
            tableView.separatorColor = kThemeColorSeparator
            tableView.separatorInset = UIEdgeInsets(top: 0, left: 15.0, bottom: 0, right: 15.0)
            tableView.tableFooterView = UIView()
            tableView.delegate = self
            tableView.dataSource = self
            tableView.emptyDataSetSource = self
            tableView.register(UINib(nibName: "DealListCell", bundle: Bundle(identifier: "DealListCell")), forCellReuseIdentifier: "cell")
        }
    }
    
    var data: UserOrdersListData?
    private var txUrlMain: String?
    private var dealRecords = [OrderDealDetailDealItem]()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.uiSetup()
        self.signalSetup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    // MARK: - Custom Accessors
    
    // MARK: - IBActions
    
    // MARK: - Public
    @objc private func mainTxPressed() {
        guard let urlStr = self.txUrlMain, let url = URL(string: urlStr) else { return }
        self.present(SFSafariViewController(url: url), animated: true) {}
    }
    
    // MARK: - Private
    private func uiSetup() -> Void {
        self.title = LOCSTR(withKey: "交易详情")
        guard let data = self.data, let orderNo = data.orderNo else {
            InfoToast(withLocalizedTitle: "信息加载失败")
            self.pop()
            return
        }
        self.loadDealRecords(with: orderNo)
    }
    
    private func signalSetup() -> Void {
        let ges = UITapGestureRecognizer(target: self, action: #selector(self.mainTxPressed))
        self.txidLabel.addGestureRecognizer(ges)
    }
    
    private func loadDealRecords(with orderNo: String) -> Void {
        let params = [
            "address":AELFIdentity.wallet_eth?.address ?? "",
            "orderNo":orderNo
        ]
        self.startLoadingHUD()
        Network.post(withUrl: URLs.shared().genUrl(with: .orderDealDetail), params: params, to: OrderDealDetailResponse.self, useCache: true, cacheCallback: { [weak self] (succeed, response) in
            self?.stopLoadingHUD()
            self?.gotDealRecords(with: response, succeed: succeed)
        }) { [weak self] (succeed, response) in
            self?.stopLoadingHUD()
            self?.gotDealRecords(with: response, succeed: succeed)
        }
    }
    
    private func gotDealRecords(with data: OrderDealDetailResponse, succeed: Bool) -> Void {
        guard succeed == true, data.succeed == true, let data = data.data else { return }
        self.txUrlMain = data.url
        self.update(withData: data)
        if let list = data.tradeDeals {
            self.dealRecords.removeAll()
            self.dealRecords.append(contentsOf: list)
            self.tableView.reloadData()
        }
    }
    
    private func update(withData data: OrderDealDetailData) {
        let isLimit = data.orderType == "1"
        var baseCurrency = "--"
        let color = OrderActionColor(withAction: data.theAction)
        self.actionLabel.text = data.actionDescription
        self.actionLabel.textColor = color
        self.actionLabel.layer.borderColor = color.cgColor
        self.timeLabel.text = data.utcCreate?.timestamp2date(withFormat: "HH:mm yyyy/MM/dd")
        let quantityDeal = NSDecimalNumber(string: data.quantity)
            .subtracting(NSDecimalNumber(string: data.quantityRemaining), withBehavior: kDecimalConfig)
            .string(withDecimalLen: Config.digitalDecimalLenMax, minLen: 0)
        if let symbol = data.symbol {
            self.currencyLabel.text = symbol.currencyFromSymbol()
            baseCurrency = symbol.baseCurrencyFromSymbol() ?? "--"
            self.baseCurrencyLabel.text = "/\(baseCurrency)"
        }
        
        self.dealPercentLabel.text = data.statusDescOfDealList
        self.orderTypeLabel.text = LOCSTR(withKey: isLimit ? "限价" : "市价")
        self.dealAmtLabel.text = "\(quantityDeal)/\(data.quantity ?? "--")"
        
        self.avgPriceLabel.text = isLimit ? "\(data.priceAverage ?? "--")/\(data.priceLimit ?? "--")":LOCSTR(withKey: "市价")
        self.feeLabel.text = "\(data.fee ?? "--") \(data.feeCurrency ?? "--")"
        
        let dealAmount = NSDecimalNumber(string: data.amount)
            .subtracting(NSDecimalNumber(string: data.amountRemaining), withBehavior: kDecimalConfig)
            .string(withDecimalLen: Config.digitalDecimalLenMax, minLen: 0)
        self.dealAmountLabel.text = "\(dealAmount) \(baseCurrency)"
        self.txidLabel.text = data.txId
    }
    
    // MARK: - Signal
    
    // MARK: - Protocol conformance
    
    // MARK: - UITextFieldDelegate
    
    // MARK: - UITableViewDataSource
    
    // MARK: - UITableViewDelegate
    
    // MARK: - NSCopying
    
    // MARK: - NSObject
    
}

extension OrderDetailVC: UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dealRecords.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 147.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        cell?.selectionStyle = .gray
        if  indexPath.row < self.dealRecords.count,
            let cell = cell as? DealListCell {
            cell.sync(with: self.dealRecords[indexPath.row])
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard indexPath.row < self.dealRecords.count,
            let urlStr = self.dealRecords[indexPath.row].url,
            let url = URL(string: urlStr) else {
                return
        }
        self.present(SFSafariViewController(url: url), animated: true) {}
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "icon-trade-emptyorder")!
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string: "暂无交易明细", attributes: [
            NSAttributedString.Key.foregroundColor : kThemeColorTextUnabled,
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14.0, weight: .medium)
            ])
    }
    
}
