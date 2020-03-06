//
//  SupportsVC.swift
//  AELFExchange
//
//  Created by tng on 2019/1/16.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import Foundation
import UIKit
import MJRefresh

class SupportsVC: BaseViewController {
    
    private var data = [SupportsListItem]()
    
    lazy var tableView: UITableView = {
        let t = UITableView(frame: .zero, style: .plain)
        t.separatorColor = kThemeColorForeground
        t.tableFooterView = UIView()
        t.separatorInset = .zero
        t.delegate = self
        t.dataSource = self
        t.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return t
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.uiSetup()
        self.signalSetup()
        self.load()
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
        self.title = LOCSTR(withKey: "操作指南")
        self.view.addSubview(self.tableView)
        self.tableView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
    }
    
    private func signalSetup() -> Void {
        let refreshFooter = MJRefreshAutoNormalFooter { [weak self] in
            self?.page += 1
            self?.load()
        }
        refreshFooter?.setTitle(Consts.kMsgLoading, for: .refreshing)
        refreshFooter?.setTitle(Consts.kMsgNoMore, for: .noMoreData)
        refreshFooter?.setTitle(Consts.kMsgLoadMore, for: .idle)
        refreshFooter?.stateLabel.textColor = .clear
        self.tableView.mj_footer = refreshFooter
    }
    
    private func load() -> Void {
        let params = [
            "pageRows":Config.generalListCountOfSinglePage,
            "currPage":self.page
        ]
        Network.post(withUrl: URLs.shared().genUrl(with: .supportsList), params: params, to: SupportsListResponse.self, useCache: true, cacheCallback: { [weak self] (succeed, response) in
            self?.gotData(response, succeed: succeed)
        }) { [weak self] (succeed, response) in
            (self?.tableView.mj_footer as! MJRefreshAutoNormalFooter).stateLabel.textColor = kThemeColorTextUnabled
            self?.gotData(response, succeed: succeed)
        }
    }
    
    private func gotData(_ response: SupportsListResponse, succeed: Bool) -> Void {
        self.tableView.mj_footer.endRefreshing()
        guard succeed == true, response.succeed == true, let data = response.data?.list else {
            InfoToast(withLocalizedTitle: response.msg)
            return
        }
        if data.count > 0 {
            if self.page == Config.startIndexOfPage {
                self.data.removeAll()
            }
            self.data.append(contentsOf: data)
            self.tableView.reloadData()
        }
        if data.count < Config.generalListCountOfSinglePage {
            self.tableView.mj_footer.endRefreshingWithNoMoreData()
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

extension SupportsVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        cell?.selectionStyle = .none
        cell?.imageView?.image = UIImage(named: "icon-aws-list")
        cell?.textLabel?.font = kThemeFontNormal
        cell?.textLabel?.textColor = .white
        cell?.backgroundColor = .clear
        if indexPath.row < self.data.count {
            cell?.textLabel?.text = self.data[indexPath.row].title
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard indexPath.row < self.data.count else {
            return
        }
        if  let bizid = self.data[indexPath.row].bizId {
            self.startLoadingHUD(withMsg: Consts.kMsgLoading)
            let params = ["bizId":bizid]
            Network.post(withUrl: URLs.shared().genUrl(with: .noticeDetail), params: params, to: NoticeDetailResponse.self) { [weak self] (succeed, response) in
                self?.stopLoadingHUD()
                guard succeed == true, response.succeed == true else {
                    InfoToast(withLocalizedTitle: response.msg)
                    return
                }
                if let data = response.data {
                    let controller = UIStoryboard(name: "HelpCenter", bundle: nil).instantiateViewController(withIdentifier: "supportsDetail") as! SupportsDetailVC
                    controller.data = data
                    self?.push(to: controller, animated: true)
                }
            }
        }
    }
    
}
