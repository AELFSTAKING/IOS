//
//  RewardVC.swift
//  AELFExchange
//
//  Created by tng on 2019/8/8.
//  Copyright © 2019 cex.io. All rights reserved.
//

import Foundation
import DZNEmptyDataSet

class RewardVC: BaseViewController {
    
    @IBOutlet weak var topupButton: UIButton!
    @IBOutlet weak var miningButton: UIButton!
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.backgroundColor = .clear
            tableView.tableFooterView = UIView()
            tableView.separatorStyle = .none
            tableView.delegate = self
            tableView.dataSource = self
            tableView.emptyDataSetSource = self
            tableView.register(UINib(nibName: "RewardsCell", bundle: Bundle(identifier: "RewardsCell")), forCellReuseIdentifier: "cell")
        }
    }
    
    private var isTopup = true
    private var topupData = [RewardsOfTopupData]()
    private var miningData = [RewardsOfMiningData]()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.uiSetup()
        self.signalSetup()
        self.loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    // MARK: - Custom Accessors
    
    // MARK: - IBActions
    @IBAction func recordsPressed(_ sender: Any) {
    }
    
    @IBAction func topupPressed(_ sender: Any) {
        self.topupButton.isSelected = true
        self.miningButton.isSelected = false
        self.isTopup = true
        self.loadData()
    }
    
    @IBAction func miningPressed(_ sender: Any) {
        self.topupButton.isSelected = false
        self.miningButton.isSelected = true
        self.isTopup = false
        self.loadData()
    }
    
    @objc private func rulePressed() {
        self.push(to: UIStoryboard(name: "Reward", bundle: nil).instantiateViewController(withIdentifier: "rewardRule"), animated: true)
    }
    
    // MARK: - Public
    
    // MARK: - Private
    private func uiSetup() -> Void {
        self.title = LOCSTR(withKey: "奖励")
        self.view.backgroundColor = kThemeColorBackgroundGray
        
        let button = UIButton(type: .custom)
        button.imageView?.contentMode = .scaleAspectFit
        button.setImage(UIImage(named: "icon-reward-qst"), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12.0)
        button.setTitleColor(kThemeColorTintPurple, for: .normal)
        button.setTitle(LOCSTR(withKey: "规则"), for: .normal)
        button.addTarget(self, action: #selector(rulePressed), for: .touchUpInside)
        let barItem = UIBarButtonItem(customView: button)
        self.navigationItem.rightBarButtonItems = [barItem]
    }
    
    private func signalSetup() -> Void {
        
    }
    
    func loadData() {
        guard let address = AELFIdentity.wallet_eth?.address else {
            return
        }
        
        if self.isTopup {
            // Topup.
            Network.post(withUrl: URLs.shared().genUrl(with: .rewardsTopup), params: ["platformAddress":address], to: RewardsOfTopupResponse.self, useCache: true, cacheCallback: { [weak self] (succeed, response) in
                self?.handleTopupResponse(with: succeed, response: response)
            }) { [weak self] (succeed, response) in
                self?.handleTopupResponse(with: succeed, response: response)
            }
        } else {
            // Mining.
            Network.post(withUrl: URLs.shared().genUrl(with: .rewardsMining), params: ["platformAddress":address], to: RewardsOfMiningResponse.self, useCache: true, cacheCallback: { [weak self] (succeed, response) in
                self?.handleMiningResponse(with: succeed, response: response)
            }) { [weak self] (succeed, response) in
                self?.handleMiningResponse(with: succeed, response: response)
            }
        }
    }
    
    private func handleTopupResponse(with succeed: Bool, response: RewardsOfTopupResponse) {
        guard succeed == true, response.succeed == true, let data = response.data else {
            InfoToast(withLocalizedTitle: response.msg)
            self.tableView.reloadData()
            return
        }
        self.topupData = data
        self.tableView.reloadData()
    }
    
    private func handleMiningResponse(with succeed: Bool, response: RewardsOfMiningResponse) {
        guard succeed == true, response.succeed == true, let data = response.data else {
            InfoToast(withLocalizedTitle: response.msg)
            self.tableView.reloadData()
            return
        }
        self.miningData = data
        self.tableView.reloadData()
    }
    
    // MARK: - Signal
    
    // MARK: - Protocol conformance
    
    // MARK: - UITextFieldDelegate
    
    // MARK: - UITableViewDataSource
    
    // MARK: - UITableViewDelegate
    
    // MARK: - NSCopying
    
    // MARK: - NSObject
    
}

extension RewardVC: UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.isTopup ? self.topupData.count:self.miningData.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 197.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        cell?.selectionStyle = .none
        if let cell = cell as? RewardsCell {
            if self.isTopup {
                if indexPath.row < self.topupData.count {
                    cell.sync(with: self.topupData[indexPath.row])
                }
            } else {
                if indexPath.row < self.miningData.count {
                    cell.sync(with: self.miningData[indexPath.row])
                }
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
