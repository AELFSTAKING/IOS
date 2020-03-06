//
//  RewardSendRecordsVC.swift
//  AELFExchange
//
//  Created by tng on 2019/8/8.
//  Copyright © 2019 cex.io. All rights reserved.
//

import Foundation
import MJRefresh
import DZNEmptyDataSet

class RewardSendRecordsVC: BaseViewController {
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.backgroundColor = kThemeColorBackgroundGray
            tableView.tableFooterView = UIView()
            tableView.separatorStyle = .none
            tableView.delegate = self
            tableView.dataSource = self
            tableView.emptyDataSetSource = self
            tableView.register(UINib(nibName: "RewardSendListCell", bundle: Bundle(identifier: "RewardSendListCell")), forCellReuseIdentifier: "cell")
        }
    }
    
    private var data = [RewardsSendListData]()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.uiSetup()
        self.signalSetup()
        self.loadData()
    }
    
    // MARK: - Custom Accessors
    
    // MARK: - IBActions
    
    // MARK: - Public
    
    // MARK: - Private
    private func uiSetup() -> Void {
        self.title = LOCSTR(withKey: "奖励发放记录")
    }
    
    private func signalSetup() -> Void {
        let refreshHeader = MJRefreshNormalHeader { [weak self] in
            self?.tableView.mj_footer.resetNoMoreData()
            self?.page = Config.startIndexOfPage
            self?.loadData()
        }
        self.tableView.mj_header = refreshHeader
        
        let refreshFooter = MJRefreshAutoNormalFooter { [weak self] in
            self?.page += 1
            self?.loadData()
        }
        refreshFooter?.isAutomaticallyRefresh = false
        refreshFooter?.setTitle(Consts.kMsgLoading, for: .refreshing)
        refreshFooter?.setTitle(Consts.kMsgNoMore, for: .noMoreData)
        refreshFooter?.setTitle(Consts.kMsgLoadMore, for: .idle)
        refreshFooter?.stateLabel.textColor = kThemeColorTextUnabled
        self.tableView.mj_footer = refreshFooter
    }
    
    func loadData() {
        guard let address = AELFIdentity.wallet_eth?.address else {
            return
        }
        
        let params = [
            "platformAddress":address,
            "pageIndex":self.page,
            "pageSize":Config.generalListCountOfSinglePage
            ] as [String : Any]
        Network.post(withUrl: URLs.shared().genUrl(with: .rewardsSendList), params: params, to: RewardsSendListResponse.self, useCache: true, cacheCallback: { [weak self] (succeed, response) in
            self?.handleResponse(with: succeed, response: response)
        }) { [weak self] (succeed, response) in
            self?.handleResponse(with: succeed, response: response)
        }
    }
    
    private func handleResponse(with succeed: Bool, response: RewardsSendListResponse) {
        guard succeed == true, response.succeed == true, let data = response.data else {
            InfoToast(withLocalizedTitle: response.msg)
            return
        }
        if self.page == Config.startIndexOfPage {
            self.data.removeAll()
        }
        self.data.append(contentsOf: data)
        self.tableView.reloadData()
        self.tableView.mj_header.endRefreshing()
        self.tableView.mj_footer.endRefreshing()
        if data.count < Config.generalListCountOfSinglePage {
            self.tableView.mj_footer.endRefreshingWithNoMoreData()
            (self.tableView.mj_footer as! MJRefreshAutoNormalFooter).stateLabel.textColor = (self.data.count > 0 ? kThemeColorTextUnabled:.clear)
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

extension RewardSendRecordsVC: UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row < self.data.count, self.data[indexPath.row].sendList?.count ?? 0 > 3 {
            return 190.0
        }
        return 170.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        cell?.selectionStyle = .none
        if  let cell = cell as? RewardSendListCell,
            indexPath.row < self.data.count {
            cell.sync(withData: self.data[indexPath.row])
        }
        return cell!
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
