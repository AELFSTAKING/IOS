//
//  AddressManageVC.swift
//  AELFExchange
//
//  Created by tng on 2019/8/5.
//  Copyright © 2019 cex.io. All rights reserved.
//

import Foundation
import DZNEmptyDataSet
import MJRefresh

class AddressManageVC: BaseViewController {
    
    private lazy var tableView: UITableView = {
        let t = UITableView(frame: .zero, style: .plain)
        t.tableFooterView = UIView()
        t.separatorInset = UIEdgeInsets(top: 0, left: 20.0, bottom: 0, right: 20.0)
        t.separatorColor = kThemeColorSeparator
        t.delegate = self
        t.dataSource = self
        t.register(UINib(nibName: "BindAddressListCell", bundle: Bundle(identifier: "BindAddressListCell")), forCellReuseIdentifier: "cell")
        return t
    }()
    
    var chain: String?
    var currency: String?
    
    private var data = [BindAddressListDataItem]()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.uiSetup()
        self.signalSetup()
        self.loadData()
    }
    
    // MARK: - Custom Accessors
    
    // MARK: - IBActions
    @objc private func addPressed() {
        let bottomInfoText = "\(chain!)原链充值地址将与\(currency!)地址:\((AELFIdentity.wallet_eth?.address)!)进行绑定，在完成跨链充值交易确认后，\(currency!)余额增加。"
        let controller = FormInputVC(withMode: .bindCrossChainTopupAddress)
        controller.viewModel.chain = self.chain!
        controller.viewModel.currency = self.currency!
        let bottomInfo = NSAttributedString(
            string: bottomInfoText,
            attributes: [
                NSAttributedString.Key.foregroundColor: kThemeColorTextUnabled,
                NSAttributedString.Key.font:kThemeFontSmall
            ]
        )
        controller.viewModel.footerInfo = bottomInfo
        controller.viewModel.completedSignal.observeValues({ [weak self] (_) in
            // Succeed to bind the first address.
            self?.loadData()
        })
        self.push(to: controller, animated: true)
    }
    
    private func remove(withIndex index: Int) {
        SystemAlert(withStyle: .alert, title: LOCSTR(withKey: "确定删除该地址吗？"), actions: [LOCSTR(withKey: "确定"),LOCSTR(withKey: "取消")]) { [weak self] (i) in
            guard i == 0 else { return }
            self?.doRemove(withIndex: index)
        }
    }
    
    private func doRemove(withIndex index: Int) {
        guard index < self.data.count else { return }
        self.startLoadingHUD()
        let params = [
            "platformAddress": (AELFIdentity.wallet_eth?.address ?? ""),
            "unbindChain": self.chain ?? "",
            "unbindCurrency": (self.currency ?? "").removeTokenPrefix(),
            "unbindAddress": self.data[index].address ?? ""
        ]
        Network.post(withUrl: URLs.shared().genUrl(with: .removeBoundAddress), params: params, to: BaseAPIBusinessModel.self) { [weak self] (succeed, response) in
            self?.stopLoadingHUD()
            guard succeed == true, response.succeed == true else {
                InfoToast(withLocalizedTitle: response.msg)
                return
            }
            self?.loadData()
        }
    }
    
    // MARK: - Public
    
    // MARK: - Private
    private func uiSetup() -> Void {
        guard let _ = self.chain, let _ = self.currency else {
            InfoToast(withLocalizedTitle: "信息加载失败")
            self.pop()
            return
        }
        self.title = LOCSTR(withKey: "管理充值地址")
        
        let navBarItem = UIBarButtonItem(title: LOCSTR(withKey: "添加新地址"), style: .plain, target: self, action: #selector(self.addPressed))
        let attr = [NSAttributedString.Key.foregroundColor:kThemeColorTextNormal,NSAttributedString.Key.font:kThemeFontNormal]
        navBarItem.setTitleTextAttributes(attr, for: .normal)
        navBarItem.setTitleTextAttributes(attr, for: .highlighted)
        navBarItem.setTitlePositionAdjustment(UIOffset(horizontal: 8.0, vertical: 0.0), for: .default)
        self.navigationItem.rightBarButtonItems = [navBarItem]
        
        self.view.addSubview(self.tableView)
        self.tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 15.0, left: 0, bottom: 0, right: 0))
        }
    }
    
    private func signalSetup() -> Void {
        let refreshHeader = MJRefreshNormalHeader { [weak self] in
            self?.loadData()
        }
        self.tableView.bounces = true
        self.tableView.mj_header = refreshHeader
    }
    
    func loadData() {
        UserInfoManager.shared().boundAddressList(forChain: self.chain ?? "", currency: self.currency ?? "") { [weak self] (data) in
            self?.tableView.mj_header.endRefreshing()
            if let data = data {
                self?.data.removeAll()
                self?.data.append(contentsOf: data)
            }
            self?.tableView.reloadData()
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

extension AddressManageVC: UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        cell?.selectionStyle = .none
        if  indexPath.row < self.data.count,
            let cell = cell as? BindAddressListCell {
            cell.sync(withData: data[indexPath.row])
            cell.removeButton.tag = indexPath.row+1
            cell.removeButton.reactive.controlEvents(.touchUpInside).take(until: cell.reactive.prepareForReuse).observeValues { [weak self] (button) in
                self?.remove(withIndex: button.tag-1)
            }
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
