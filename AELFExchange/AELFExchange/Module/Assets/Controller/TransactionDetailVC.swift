//
//  TransactionDetailVC.swift
//  AELFExchange
//
//  Created by tng on 2019/7/29.
//  Copyright © 2019 cex.io. All rights reserved.
//

import Foundation
import SafariServices

class TransactionDetailVC: BaseViewController {
    
    private lazy var tableView: UITableView = {
        let t = UITableView(frame: .zero, style: .plain)
        t.tableFooterView = UIView()
        t.separatorInset = UIEdgeInsets(top: 0, left: 25.0, bottom: 0, right: 0)
        t.separatorColor = kThemeColorSeparator
        t.bounces = false
        t.delegate = self
        t.dataSource = self
        t.register(UINib(nibName: "TransactionDetailItemCell", bundle: Bundle(identifier: "TransactionDetailItemCell")), forCellReuseIdentifier: "cell")
        return t
    }()
    
    private let header = Bundle.main.loadNibNamed("TransactionDetailHeaderView", owner: nil, options: nil)?.first as! TransactionDetailHeaderView
    
    let viewModel = TransactionDetailViewModel()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.uiSetup()
        self.signalSetup()
    }
    
    // MARK: - Custom Accessors
    
    // MARK: - IBActions
    
    // MARK: - Public
    
    // MARK: - Private
    private func uiSetup() -> Void {
        guard let data = self.viewModel.txData else {
            InfoToast(withLocalizedTitle: "信息错误")
            self.pop()
            return
        }
        
        self.viewModel.load()
        self.header.sync(withData: data)
        
        self.view.addSubview(self.tableView)
        self.tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    private func signalSetup() -> Void {
        self.viewModel.reactive.producer(forKeyPath: "data").startWithValues { [weak self] (_) in
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

extension TransactionDetailVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.data.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 68.0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 156.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return self.header
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        cell?.selectionStyle = .none
        if  indexPath.row < self.viewModel.data.count,
            let cell = cell as? TransactionDetailItemCell {
            cell.sync(withData: self.viewModel.data[indexPath.row] as! TransactionDetailItem)
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.row < self.viewModel.data.count,
            let data = self.viewModel.data[indexPath.row] as? TransactionDetailItem,
            data.title == LOCSTR(withKey: "交易ID"),
            let txid = data.value else {
                return
        }
        
        let urlStr = URLs.shared().genEthBlockExplorerUrl(with: txid)
        guard let url = URL(string: urlStr) else {
            InfoToast(withLocalizedTitle: "信息错误")
            return
        }
        self.present(SFSafariViewController(url: url), animated: true) {}
    }
    
}
