//
//  AssetDetailVC.swift
//  AELFExchange
//
//  Created by tng on 2019/7/18.
//  Copyright © 2019 cex.io. All rights reserved.
//

import Foundation
import DZNEmptyDataSet
import MJRefresh

class AssetDetailVC: BaseViewController {
    
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var legalLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var copyButton: UIButton!
    @IBOutlet weak var qrButton: UIButton!
    @IBOutlet weak var topupButton: UIButton!
    @IBOutlet weak var withdrawButton: UIButton!
    @IBOutlet weak var transferButton: UIButton!
    @IBOutlet weak var sep1: UIView!
    @IBOutlet weak var sep2: UIView!
    @IBOutlet weak var barView1: UIView!
    @IBOutlet weak var barView2: UIView!
    @IBOutlet weak var barView3: UIView!
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.isScrollEnabled = false
            tableView.backgroundColor = .clear
            tableView.tableFooterView = UIView()
            tableView.separatorColor = kThemeColorSeparator
            tableView.separatorInset = UIEdgeInsets(top: 0, left: 20.0, bottom: 0, right: 0)
            tableView.delegate = self
            tableView.dataSource = self
            tableView.emptyDataSetSource = self
            tableView.register(UINib(nibName: "AssetTradeRecordListCell", bundle: Bundle(identifier: "AssetTradeRecordListCell")), forCellReuseIdentifier: "cell")
        }
    }
    
    let viewModel = AssetDetailViewModel()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.uiSetup()
        self.signalSetup()
        self.viewModel.loadTxRecords()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    // MARK: - Custom Accessors
    
    // MARK: - IBActions
    @IBAction func qrPressed(_ sender: Any) {
        let currency = (self.viewModel.currencyData?.currency ?? "--")
        let chain = currency.removeTokenPrefix()
        let controller = UIStoryboard(name: "Assets", bundle: nil).instantiateViewController(withIdentifier: "topup") as! TopupVC
        controller.viewModel.mode = .receive
        controller.viewModel.chain = chain
        controller.viewModel.currency = currency
        self.push(to: controller, animated: true)
    }
    
    @IBAction func copyPressed(_ sender: Any) {
        guard let text = self.addressLabel.text else {
            InfoToast(withLocalizedTitle: "信息错误")
            return
        }
        UIPasteboard.general.string = text
        InfoToast(withLocalizedTitle: "复制成功")
    }
    
    @IBAction func topupPressed(_ sender: Any) {
        guard AELFIdentity.hasIdentity() else {
            InfoToast(withLocalizedTitle: "未查询到账户，请导入或创建")
            return
        }
        
        let currency = (self.viewModel.currencyData?.currency ?? "--").uppercased()
        var chain = (self.viewModel.currencyData?.chain ?? "--").uppercased()
        if currency.contains(AELFCurrencyName.BTC.rawValue) {
            chain = AELFChainName.Bitcoin.rawValue
        }
        
        if currency.uppercased() == "PLANET" {
            self.qrPressed(self.qrButton as Any)
            return
        }
        
        self.startLoadingHUD()
        UserInfoManager.shared().boundAddressList(
            forChain: chain,
            currency: currency
        ) { [weak self] (address) in
            self?.stopLoadingHUD()
            if address?.count ?? 0 == 0 {
                
                /// No any address bound.
                SystemAlert(withStyle: .alert, title: LOCSTR(withKey: "充值先绑定\(currency)账户"), actions: [LOCSTR(withKey: "绑定"),LOCSTR(withKey: "取消")]) { (i) in
                    guard i == 0 else { return }
                    let bottomInfoText = "\(chain)原链充值地址将与\(currency)地址:\((AELFIdentity.wallet_eth?.address)!)进行绑定，在完成跨链充值交易确认后，\(currency)余额增加。"
                    let controller = FormInputVC(withMode: .bindCrossChainTopupAddress)
                    controller.viewModel.chain = chain
                    controller.viewModel.currency = currency
                    let bottomInfo = NSAttributedString(
                        string: bottomInfoText,
                        attributes: [
                            NSAttributedString.Key.foregroundColor: kThemeColorTextUnabled,
                            NSAttributedString.Key.font:kThemeFontSmall
                        ]
                    )
                    controller.viewModel.footerInfo = bottomInfo
                    controller.viewModel.completedSignal.observeValues({ (_) in
                        // Succeed to bind the first address.
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.2, execute: {
                            let succeedController = UIStoryboard(name: "Assets", bundle: nil)
                                .instantiateViewController(withIdentifier: "addressBindSucceed") as! AddressBindSucceedVC
                            succeedController.chain = chain
                            succeedController.currency = currency
                            self?.push(to: succeedController, animated: true)
                        })
                    })
                    self?.push(to: controller, animated: true)
                }
                
            } else {
                /// Has a list of address.
                let controller = UIStoryboard(name: "Assets", bundle: nil).instantiateViewController(withIdentifier: "topup") as! TopupVC
                controller.viewModel.mode = .topup
                controller.viewModel.chain = chain
                controller.viewModel.currency = currency
                self?.push(to: controller, animated: true)
            }
        }
    }
    
    @IBAction func withdrawPressed(_ sender: Any) {
        ShowWithdraw(withCurrency: self.viewModel.currencyData?.currency ?? "", mode: .withdraw) { [weak self] in
            self?.viewModel.loadTxRecords()
        }
    }
    
    @IBAction func transferPressed(_ sender: Any) {
        ShowWithdraw(withCurrency: self.viewModel.currencyData?.currency ?? "", mode: .transfer) { [weak self] in
            self?.viewModel.loadTxRecords()
        }
    }
    
    // MARK: - Public
    
    // MARK: - Private
    private func uiSetup() -> Void {
        guard let currency = self.viewModel.currencyData?.currency?.uppercased() else {
            self.pop()
            InfoToast(withLocalizedTitle: "信息错误")
            return
        }
        
        self.title = currency
        self.quantityLabel.text = self.viewModel.currencyData?.balance?.digitalString()
        self.addressLabel.text = AELFIdentity.wallet_eth?.address
        
        let usdtVal = NSDecimalNumber(string: self.viewModel.currencyData?.usdtPrice)
            .multiplying(by: NSDecimalNumber(string: self.viewModel.currencyData?.balance), withBehavior: kDecimalConfig)
            .usdtString()
        self.legalLabel.text = "≈ \(usdtVal)"
        
        if currency.uppercased() == "PLANET" {
            self.barView2.isHidden = true
            self.topupButton.setTitle(LOCSTR(withKey: "收款"), for: .normal)
        }
    }
    
    private func signalSetup() -> Void {
        let refreshHeader = MJRefreshNormalHeader { [weak self] in
            self?.tableView.mj_footer.resetNoMoreData()
            self?.viewModel.page = Config.startIndexOfPage
            self?.viewModel.loadTxRecords()
        }
        self.tableView.mj_header = refreshHeader
        
        let refreshFooter = MJRefreshAutoNormalFooter { [weak self] in
            self?.viewModel.page += 1
            self?.viewModel.loadTxRecords()
        }
        refreshFooter?.isAutomaticallyRefresh = false
        refreshFooter?.setTitle(Consts.kMsgLoading, for: .refreshing)
        refreshFooter?.setTitle(Consts.kMsgNoMore, for: .noMoreData)
        refreshFooter?.setTitle(Consts.kMsgLoadMore, for: .idle)
        refreshFooter?.stateLabel.textColor = kThemeColorTextUnabled
        self.tableView.mj_footer = refreshFooter
        
        self.viewModel.reactive.producer(forKeyPath: "txRecords").startWithValues { [weak self] (value) in
            self?.tableView.mj_header.endRefreshing()
            self?.tableView.mj_footer.endRefreshing()
            self?.tableView.reloadData()
        }
        
        self.viewModel.txRecordsNoMoreSignal.observeValues { [weak self] (_) in
            self?.tableView.mj_footer.endRefreshingWithNoMoreData()
            (self?.tableView.mj_footer as! MJRefreshAutoNormalFooter).stateLabel.textColor = (self?.viewModel.txRecords.count ?? 0 > 0 ? kThemeColorTextUnabled:.clear)
        }
    }
    
    // MARK: - Signal
    
    // MARK: - Protocol conformance
    
    // MARK: - UITextFieldDelegate
    
    // MARK: - UITableViewDataSource
    
    // MARK: - UITableViewDelegate
    
    // MARK: - NSCopying
    
    // MARK: - NSObject
    
}

extension AssetDetailVC: UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.txRecords.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        cell?.selectionStyle = .none
        if  indexPath.row < self.viewModel.txRecords.count,
            let data = self.viewModel.txRecords[indexPath.row] as? TransactionRecordsDataItem,
            let cell = cell as? AssetTradeRecordListCell {
            cell.sync(withData: data)
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard indexPath.row < self.viewModel.txRecords.count,
            let data = self.viewModel.txRecords[indexPath.row] as? TransactionRecordsDataItem else {
                InfoToast(withLocalizedTitle: "信息错误")
                return
        }
        let controller = TransactionDetailVC()
        controller.viewModel.txData = data
        self.push(to: controller, animated: true)
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
