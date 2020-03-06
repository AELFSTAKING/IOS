//
//  TopupVC.swift
//  AELFExchange
//
//  Created by tng on 2019/1/16.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import Foundation
import UIKit
import ReactiveSwift
import Kingfisher
import DZNEmptyDataSet

class TopupVC: BaseViewController {
    
    private let addressHeaderHeight: CGFloat = 60.0
    private let addressListHeightEmpty: CGFloat = 165.0
    
    @IBOutlet weak var contentViewHeightOffset: NSLayoutConstraint!
    @IBOutlet weak var addressContentViewHeight: NSLayoutConstraint!
    @IBOutlet weak var footerInfoLabelHeight: NSLayoutConstraint! // Def 60.0
    @IBOutlet weak var qrCodeImageView: UIImageView!
    @IBOutlet weak var addrValueLabel: UILabel!
    @IBOutlet weak var infoTextView: UITextView! // Def H 142.5
    @IBOutlet weak var footerInfoLabel: UILabel! {didSet { footerInfoLabel.isHidden = true }}
    @IBOutlet weak var addressListTableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var addressListTableView: UITableView! {
        didSet {
            addressListTableView.alpha = 1.0
            addressListTableView.isHidden = true
            addressListTableView.isScrollEnabled = false
            addressListTableView.backgroundColor = .white
            addressListTableView.tableFooterView = UIView()
            addressListTableView.separatorColor = kThemeColorSeparator
            addressListTableView.separatorInset = UIEdgeInsets(top: 0, left: 15.0, bottom: 0, right: 15.0)
            addressListTableView.delegate = self
            addressListTableView.dataSource = self
            addressListTableView.emptyDataSetSource = self
            addressListTableView.addCorner(withRadius: 10.0)
        }
    }
    
    let viewModel = TopupViewModel()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.uiSetup()
        self.signalSetup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        if !self.isFirstTimeToShow {
            self.viewModel.load()
        }
    }
    
    // MARK: - Custom Accessors
    
    // MARK: - IBActions
    @IBAction func copyAddrPressed(_ sender: Any) {
        guard let addr = self.addrValueLabel.text else {
            InfoToast(withLocalizedTitle: "加载失败")
            return
        }
        UIPasteboard.general.string = addr
        InfoToast(withLocalizedTitle: "复制成功")
    }
    
    // MARK: - Public
    
    // MARK: - Private
    private func uiSetup() -> Void {
        guard let chain = self.viewModel.chain, let currency = self.viewModel.currency else {
            InfoToast(withLocalizedTitle: "信息加载失败")
            self.pop()
            return
        }
        
        self.title = LOCSTR(withKey: "\(currency)\(self.viewModel.mode == .topup ? "跨链充值":"收款")")
        self.infoTextView.text = self.infoTextView.text.replacingOccurrences(of: "{chain}", with: currency.removeTokenPrefix())
        self.viewModel.load()
        
        if self.viewModel.mode == .receive {
            if IsScreen40 || IsScreen35 {
                self.contentViewHeightOffset.constant = 100.0
            }
            
            let isPlanet = (self.viewModel.currency?.uppercased() == "PLANET")
            self.addressContentViewHeight.constant -= (IsScreen40 || IsScreen35 ? 102.0:82.0)
            self.infoTextView.text = "提示：该地址只支持\(currency)收款！\(isPlanet ? "":"请不要向本地址直接发起\(chain)转账！")"
            self.footerInfoLabel.isHidden = isPlanet
        } else {
            if self.viewModel.currency?.uppercased() == "S-BTC" {
                self.infoTextView.text =
                """

                   提示：
                   
                   1、该地址只支持{chain}跨链充值，请不要使用没有绑定的{chain}地址进行充值。
                   2、\(AELFChainName.Bitcoin.rawValue)跨链充值只允许使用绑定地址的UTXO进行充值，否则充值将无法正常入账。
                   3、该地址不支持通过交易所账户以提币的方式进行充值。
                   """.replacingOccurrences(of: "{chain}", with: currency.removeTokenPrefix())
            }
        }
    }
    
    private func signalSetup() -> Void {
        // 跨链充值地址.
        self.viewModel.reactive.producer(forKeyPath: "topupAddress").startWithValues { [weak self] (value) in
            guard let address = value as? String else { return }
            self?.addrValueLabel.text = address
            if let imgSize = self?.qrCodeImageView.frame.size {
                DispatchQueue.global().async {
                    let qrImg = QRCodeGenerator().createImage(value: address, size: imgSize)
                    DispatchQueue.main.async {
                        self?.qrCodeImageView.image = qrImg
                    }
                }
            }
        }
        
        // 跨链充值绑定的地址列表.
        self.viewModel.reactive.producer(forKeyPath: "boundAddressList").startWithValues { [weak self] (value) in
            guard self?.viewModel.mode == .topup else { return }
            if let data = value as? [BindAddressListDataItem] {
                let tableH = (data.count > 0 ? CGFloat(51.0*Double(data.count)):(self?.addressListHeightEmpty ?? 0)) + (self?.addressHeaderHeight ?? 0)
                self?.addressListTableViewHeight.constant = tableH
                self?.contentViewHeightOffset.constant = tableH+50.0
            } else {
                let tableH = self?.addressListHeightEmpty ?? 0 + (self?.addressHeaderHeight ?? 0)
                self?.contentViewHeightOffset.constant = tableH
                self?.contentViewHeightOffset.constant = tableH+50.0
            }
            self?.addressListTableView.isHidden = false
            self?.addressListTableView.reloadData()
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

extension TopupVC: UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.boundAddressList.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return self.addressHeaderHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView()
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14.0, weight: .medium)
        label.textColor = kThemeColorTextNormal
        label.text = LOCSTR(withKey: "已绑定充值地址")
        header.addSubview(label)
        label.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(15.0)
        }
        
        let button = UIButton(type: .system)
        button.titleLabel?.font = UIFont.systemFont(size: 12.0)
        button.setTitleColor(kThemeColorTextNormal, for: .normal)
        button.setTitle(LOCSTR(withKey: "管理"), for: .normal)
        button.reactive.controlEvents(.touchUpInside).observeValues { [weak self] (_) in
            let controller = AddressManageVC()
            controller.chain = self?.viewModel.chain
            controller.currency = self?.viewModel.currency
            self?.push(to: controller, animated: true)
        }
        header.addSubview(button)
        button.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-15.0)
        }
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 51.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.cellForRow(at: indexPath) ?? UITableViewCell(style: .value1, reuseIdentifier: "cell")
        cell.selectionStyle = .none
        cell.textLabel?.font = UIFont.systemFont(size: 13.0)
        cell.textLabel?.textColor = kThemeColorTextUnabled
        cell.detailTextLabel?.font = UIFont.systemFont(size: 12.0)
        cell.detailTextLabel?.textColor = kThemeColorTextUnabled
        cell.detailTextLabel?.textAlignment = .left
        if  let data = self.viewModel.boundAddressList as? [BindAddressListDataItem],
            indexPath.row < data.count {
            cell.textLabel?.text = data[indexPath.row].name
            cell.detailTextLabel?.text = data[indexPath.row].address
        }
        return cell
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
