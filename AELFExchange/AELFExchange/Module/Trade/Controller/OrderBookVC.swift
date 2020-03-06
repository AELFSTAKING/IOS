//
//  OrderBookVC.swift
//  AELFExchange
//
//  Created by tng on 2019/7/18.
//  Copyright © 2019 cex.io. All rights reserved.
//

import Foundation
import DZNEmptyDataSet
import PromiseKit
import MJRefresh

class OrderBookVC: BaseViewController {
    
    lazy var tableView: UITableView = {
        let t = UITableView(frame: .zero, style: .plain)
        t.backgroundColor = .clear
        t.tableFooterView = UIView()
        t.separatorColor = kThemeColorSeparator
        t.separatorInset = UIEdgeInsets(top: 0, left: 15.0, bottom: 0, right: 0)
        t.delegate = self
        t.dataSource = self
        t.emptyDataSetSource = self
        t.register(UINib(nibName: "OrderBookCell", bundle: Bundle(identifier: "OrderBookCell")), forCellReuseIdentifier: "cell-orderbook")
        return t
    }()
    
    private let viewModel = TradeViewModel()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.uiSetup()
        self.signalSetup()
        self.viewModel.loadUserOrders()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    // MARK: - Custom Accessors
    
    // MARK: - IBActions
    private func cancelOrderPressed(withData data: UserOrdersListData) {
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
    
    // MARK: - Public
    
    // MARK: - Private
    private func uiSetup() -> Void {
        self.title = LOCSTR(withKey: "委托记录")
        self.view.addSubview(self.tableView)
        self.tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    private func signalSetup() -> Void {
        let refreshHeader = MJRefreshNormalHeader { [weak self] in
            self?.tableView.mj_footer.resetNoMoreData()
            self?.viewModel.userOrdersPage = Config.startIndexOfPage
            self?.viewModel.loadUserOrders()
        }
        self.tableView.bounces = true
        self.tableView.mj_header = refreshHeader
        
        let refreshFooter = MJRefreshAutoNormalFooter { [weak self] in
            self?.viewModel.userOrdersPage += 1
            self?.viewModel.loadUserOrders()
        }
        refreshFooter?.isAutomaticallyRefresh = false
        refreshFooter?.setTitle(Consts.kMsgLoading, for: .refreshing)
        refreshFooter?.setTitle(Consts.kMsgNoMore, for: .noMoreData)
        refreshFooter?.setTitle(Consts.kMsgLoadMore, for: .idle)
        refreshFooter?.stateLabel.textColor = kThemeColorTextUnabled
        self.tableView.mj_footer = refreshFooter
        
        self.viewModel.userOrdersLoadedSignal.observeValues { [weak self] (_) in
            self?.tableView.mj_header.endRefreshing()
            self?.tableView.mj_footer.endRefreshing()
            self?.tableView.reloadData()
        }
        
        self.viewModel.userOrdersNoMoreSignal.observeValues { [weak self] (_) in
            self?.tableView.mj_footer.endRefreshingWithNoMoreData()
            (self?.tableView.mj_footer as! MJRefreshAutoNormalFooter).stateLabel.textColor = (self?.viewModel.userOrdersData.count ?? 0 > 0 ? kThemeColorTextUnabled:.clear)
        }
        
        self.viewModel.reactive.producer(forKeyPath: "userOrdersType").startWithValues { [weak self] (value) in
            self?.viewModel.userOrdersData.removeAll()
            self?.tableView.reloadData()
            self?.viewModel.loadUserOrders(withFirstPage: true)
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

extension OrderBookVC: UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.userOrdersData.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return self.viewModel.userOrdersType == UserOrderTypeEnum.current.rawValue ? 98.0:150.0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 48.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = Bundle.main.loadNibNamed("OrderBookHeaderView", owner: nil, options: nil)?.first as! OrderBookHeaderView
        header.updateStatus(toCurrent: self.viewModel.userOrdersType == UserOrderTypeEnum.current.rawValue)
        header.allButton.isHidden = true
        header.buttonPressedSignal.observeValues { [weak self] (buttonType) in
            if buttonType == .current {
                self?.viewModel.userOrdersType = UserOrderTypeEnum.current.rawValue
            } else if buttonType == .history {
                self?.viewModel.userOrdersType = UserOrderTypeEnum.history.rawValue
            }
        }
        return header
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell-orderbook")
        cell?.selectionStyle = .none
        if  indexPath.row < self.viewModel.userOrdersData.count,
            let cell = cell as? OrderBookCell {
            cell.cancelButton.tag = indexPath.row+1
            cell.cancelButton.reactive.controlEvents(.touchUpInside)
                .take(until: cell.reactive.prepareForReuse)
                .observeValues { [weak self] (button) in
                let index = button.tag-1
                guard index < (self?.viewModel.userOrdersData.count ?? 0), let data = self?.viewModel.userOrdersData[index] else { return }
                self?.cancelOrderPressed(withData: data)
            }
            cell.sync(
                withData: self.viewModel.userOrdersData[indexPath.row],
                isDeal: self.viewModel.userOrdersType == UserOrderTypeEnum.history.rawValue
            )
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard indexPath.row < self.viewModel.userOrdersData.count else {
            return
        }
        let controller = UIStoryboard(name: "Trade", bundle: nil).instantiateViewController(withIdentifier: "orderDetail") as! OrderDetailVC
        controller.data = self.viewModel.userOrdersData[indexPath.row]
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
