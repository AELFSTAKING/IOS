//
//  NoticeListVC.swift
//  AELFExchange
//
//  Created by tng on 2019/1/15.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import Foundation
import UIKit
import MJRefresh

class NoticeListVC: BaseViewController {
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
            tableView.separatorStyle = .none
            tableView.backgroundColor = .clear
            tableView.tableFooterView = UIView()
            tableView.register(UINib(nibName: "NoticeListCell", bundle: Bundle(identifier: "NoticeListCell")), forCellReuseIdentifier: "cell")
        }
    }
    
    private let viewModel = NoticeListViewModel()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.uiSetup()
        self.signalSetup()
        self.viewModel.load()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    // MARK: - Custom Accessors
    
    // MARK: - IBActions
    
    // MARK: - Public
    
    // MARK: - Private
    private func uiSetup() -> Void {
        self.title = LOCSTR(withKey: "公告")
    }
    
    private func signalSetup() -> Void {
        let refreshFooter = MJRefreshAutoNormalFooter { [weak self] in
            self?.viewModel.page += 1
            self?.viewModel.load()
        }
        refreshFooter?.setTitle(Consts.kMsgLoading, for: .refreshing)
        refreshFooter?.setTitle(Consts.kMsgNoMore, for: .noMoreData)
        refreshFooter?.setTitle(Consts.kMsgLoadMore, for: .idle)
        refreshFooter?.stateLabel.textColor = .clear
        self.tableView.mj_footer = refreshFooter
        
        self.viewModel.reactive.producer(forKeyPath: "noticeItems").take(during: self.reactive.lifetime).startWithValues { [weak self] (list) in
            self?.tableView.mj_footer.endRefreshing()
            self?.tableView.reloadData()
        }
        
        self.viewModel.didLoadSignal.observeValues { [weak self] (_) in
            (self?.tableView.mj_footer as! MJRefreshAutoNormalFooter).stateLabel.textColor = kThemeColorTextNormal
        }
        
        self.viewModel.nomoreDataSignal.observeValues { [weak self] (_) in
            self?.tableView.mj_footer.endRefreshingWithNoMoreData()
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

extension NoticeListVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.noticeItems.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        if  indexPath.row < self.viewModel.noticeItems.count,
            let item = self.viewModel.noticeItems[indexPath.row] as? NoticeListItem,
            let cell = cell as? NoticeListCell {
            cell.sync(with: item)
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if  indexPath.row < self.viewModel.noticeItems.count,
            let item = self.viewModel.noticeItems[indexPath.row] as? NoticeListItem,
            let bizid = item.bizId {
            
            self.startLoadingHUD(withMsg: Consts.kMsgLoading)
            let params = ["bizId":bizid]
            Network.post(withUrl: URLs.shared().genUrl(with: .noticeDetail), params: params, to: NoticeDetailResponse.self) { [weak self] (succeed, response) in
                self?.stopLoadingHUD()
                guard succeed == true, response.succeed == true else {
                    InfoToast(withLocalizedTitle: response.msg)
                    return
                }
                if let controller = self?.NoticeDetail(withTitle: response.data?.title, content: response.data?.content) {
                    self?.push(to: controller, animated: true)
                }
            }
            
        }
    }
    
}
