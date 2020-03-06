//
//  WithdrawVC.swift
//  AELFExchange
//
//  Created by tng on 2019/1/29.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import Foundation
import UIKit
import ReactiveSwift
import Result
import PromiseKit

class WithdrawVC: BaseViewController {
    
    var transactionCreatedCallback: (() -> ())?
    
    @IBOutlet weak var contentViewHeight: NSLayoutConstraint!
    @IBOutlet weak var addressToTitleLabelTopOffset: NSLayoutConstraint! // Def 25.0
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var currencyLabel2: UIButton!
    @IBOutlet weak var quantityTextfield: TextField! {
        didSet {
            quantityTextfield.setPlaceholder(with: "请输入提币数量")
            quantityTextfield.delegate = self
        }
    }
    @IBOutlet weak var btcAddressTypeArrowButton: UIButton!
    @IBOutlet weak var availableBalnaceLegalLabel: UILabel!
    @IBOutlet weak var availableBalanceLabel: UILabel!
    @IBOutlet weak var addressToTypeTitleLabel: Label!
    @IBOutlet weak var addressToTypeView: UIView!
    @IBOutlet weak var addressToTypeValueLabel: Label!
    @IBOutlet weak var addrToTextfield: TextField! {didSet { addrToTextfield.setPlaceholder(with: "请输入或长按粘贴提币地址") }}
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var senderAddressLabel: Label!
    @IBOutlet weak var gasValueLabel: UILabel!
    @IBOutlet weak var gasSuggestLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var gasSlider: UISlider! {
        didSet {
            gasSlider.tintColor = kThemeColorTintPurple
            gasSlider.setThumbImage(UIImage(named: "icon-withdraw-slider"), for: .normal)
        }
    }
    
    let viewModel = WithdrawViewModel()
    
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.35) {
            self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    // MARK: - Custom Accessors
    
    // MARK: - IBActions
    @IBAction func allPressed(_ sender: Any) {
        let amount = self.viewModel.availableAmount.string(withDecimalLen: Config.digitalDecimalLenMax, minLen: 0)
        self.quantityTextfield.text = amount
        self.viewModel.digitalQuantity = amount
        self.updateTargetAmount()
        self.updateGas()
    }
    
    @IBAction func btcAddressTypePressed(_ sender: Any) {
        /* 暂时不支持隔离见证.
        let actions = [
            FSActionSheetTitleItemMake(.normal, LOCSTR(withKey: "隔离见证")),
            FSActionSheetTitleItemMake(.normal, LOCSTR(withKey: "普通"))
            ] as [FSActionSheetItem]
        let sheet = FSActionSheet(title: "", cancelTitle: LOCSTR(withKey: "取消"), items: actions)
        sheet?.show(selectedCompletion: { [weak self] (index) in
            switch index {
            case 0: self?.viewModel.addressToBTCType = WithdrawBTCAddressType.segwit.rawValue
            case 1: self?.viewModel.addressToBTCType = WithdrawBTCAddressType.normal.rawValue
            default:break
            }
        })*/
    }
    
    @IBAction func scanPressed(_ sender: Any) {
        let scanner = GeneralQRScanVC()
        scanner.completion = { [weak self] (content) in
            self?.viewModel.addressTo = content
            self?.addrToTextfield.text = content
        }
        self.push(to: scanner, animated: true)
    }
    
    @IBAction func confirmPressed(_ sender: Any) {
        self.view.endEditing(true)
        guard self.viewModel.addressTo.count > 0 else {
            InfoToast(withTitle: "请输入提币地址")
            return
        }
        guard self.viewModel.digitalQuantity.count > 0 && NSDecimalNumber(string: self.viewModel.digitalQuantity).compare(0.0) == .orderedDescending else {
            InfoToast(withLocalizedTitle: "请输入提币金额")
            return
        }
        
        firstly {
            AELFIdentity.shared().auth()
            }.done { [weak self] (succeed, password) in
                guard succeed else {
                    InfoToast(withLocalizedTitle: "密码错误")
                    return
                }
                self?.startLoadingHUD(withMsg: Consts.kMsgSubmit)
                self?.viewModel.password = password
                if self?.viewModel.mode == .withdraw {
                    self?.viewModel.withdrawSignal().observeValues({ (doSucceed) in
                        self?.stopLoadingHUD()
                        guard doSucceed else { return }
                        self?.clearData()
                        self?.viewModel.loadBalance()
                        self?.transactionCreatedCallback?()
                        InfoToast(withLocalizedTitle: "\(self?.viewModel.mode.rawValue ?? "")提交成功")
                    })
                } else {
                    self?.viewModel.transferSignal().observeValues({ (doSucceed) in
                        self?.stopLoadingHUD()
                        guard doSucceed else { return }
                        self?.clearData()
                        self?.viewModel.loadBalance()
                        self?.transactionCreatedCallback?()
                        InfoToast(withLocalizedTitle: "\(self?.viewModel.mode.rawValue ?? "")提交成功")
                    })
                }
            }.catch { (error) in
                AELFIdentity.errorToast(withError: error)
        }
        self.startLoadingHUD(withMsg: Consts.kMsgLoading)
        self.stopLoadingHUD()
    }
    
    // MARK: - Public
    
    // MARK: - Private
    private func uiSetup() -> Void {
        guard let currency = self.viewModel.currency else {
            InfoToast(withLocalizedTitle: "信息加载失败")
            self.pop()
            return
        }
        
        self.title = LOCSTR(withKey: "\(currency)\(self.viewModel.mode.rawValue)")
        self.currencyLabel2.setTitle(currency, for: .normal)
        self.contentViewHeight.constant = 1000.0-kScreenSize.height
        
        if !(currency.contains("BTC") && self.viewModel.mode == .withdraw) {
            self.addressToTitleLabelTopOffset.constant = -77.0
            self.addressToTypeTitleLabel.isHidden = true
            self.addressToTypeView.isHidden = true
        }
        
        if currency.contains("BTC") && self.viewModel.mode == .withdraw {
            self.infoLabel.text =
            """
            1、请确保ETH账户中有至少有少量ETH作为矿工费，否则将导致交
            易失败！
            2、因BTC网络有链上矿工费消耗，实际到账小于提现金额。
            """
        }
    }
    
    private func signalSetup() -> Void {
        self.viewModel.reactive.producer(forKeyPath: "availableAmount").startWithValues { [weak self] (value) in
            if let value = value as? String {
                let val = value.string(withDecimalLen: Config.digitalDecimalLenMax, minLen: 0)
                self?.availableBalanceLabel.text = "\(LOCSTR(withKey: "当前余额: ")) \(val)"
            }
        }
        
        self.viewModel.reactive.producer(forKeyPath: "ethBalance").startWithValues { [weak self] (value) in
            if let value = value as? String {
                let val = value.string(withDecimalLen: Config.digitalDecimalLenMax, minLen: 0)
                self?.balanceLabel.text = "\(AELFChainName.Ethereum.rawValue)\(LOCSTR(withKey: "余额")): \(val)"
            }
        }
        
        self.viewModel.reactive.producer(forKeyPath: "addressFrom").startWithValues { [weak self] (value) in
            if let value = value as? String { self?.senderAddressLabel.text = value }
        }
        
        self.viewModel.gasInfoLoadedSignal.observeValues { [weak self] (_) in
            self?.updateGas()
        }
        self.gasSlider.reactive.controlEvents(.valueChanged).observeValues { [weak self] (_) in
            self?.updateGas()
        }
        
        self.quantityTextfield.reactive.continuousTextValues.observeValues { [weak self] (value) in
            if let value = value {
                self?.viewModel.digitalQuantity = value
                self?.updateTargetAmount()
            }
        }
        self.addrToTextfield.reactive.continuousTextValues.observeValues { [weak self] (value) in
            if let value = value { self?.viewModel.addressTo = value }
        }
        
        self.viewModel.reactive.producer(forKeyPath: "addressToBTCType").startWithValues { [weak self] (_) in
            self?.addressToTypeValueLabel.text = self?.viewModel.addressToBTCType
        }
        
        self.quantityTextfield.reactive.continuousTextValues
            .merge(with: self.addrToTextfield.reactive.continuousTextValues)
            .observeValues { [weak self] (_) in
                self?.confirmButton.isEnabled = (
                    self?.viewModel.digitalQuantity.count ?? 0 > 0 &&
                    self?.viewModel.addressTo.count ?? 0 > 0
                )
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
