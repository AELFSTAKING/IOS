//
//  AssetHomeVC.swift
//  AELFExchange
//
//  Created by tng on 2019/7/18.
//  Copyright © 2019 cex.io. All rights reserved.
//

import Foundation
import DZNEmptyDataSet
import PromiseKit
import MJRefresh

class AssetHomeVC: BaseViewController {
    
    @IBOutlet weak var topOffset: NSLayoutConstraint! // Def 42.0
    @IBOutlet weak var tableTopOffset: NSLayoutConstraint! // Def 32.0
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var settingButton: UIButton!
    @IBOutlet weak var quantityTitleLabel: UILabel!
    @IBOutlet weak var eyeButton: UIButton!
    @IBOutlet weak var quantityValueLabel: UILabel!
    @IBOutlet weak var lagalValueLabel: UILabel!
    
    @IBOutlet weak var rewardView: UIView!
    @IBOutlet weak var receivedValueLabel: UILabel!
    @IBOutlet weak var waittingForValueLabel: UILabel!
    @IBOutlet weak var rewardCurrencyLabel1: UILabel!
    @IBOutlet weak var rewardCurrencyLabel2: UILabel!
    
    @IBOutlet weak var topBarView: UIView!
    @IBOutlet weak var createWalletButton: UIButton!
    @IBOutlet weak var importWalletButton: UIButton!
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.isScrollEnabled = false
            tableView.backgroundColor = .clear
            tableView.tableFooterView = UIView()
            tableView.separatorColor = kThemeColorSeparator
            tableView.separatorInset = .zero
            tableView.delegate = self
            tableView.dataSource = self
            tableView.emptyDataSetSource = self
            tableView.register(UINib(nibName: "AssetHomeCurrencyListCell", bundle: Bundle(identifier: "AssetHomeCurrencyListCell")), forCellReuseIdentifier: "cell")
        }
    }
    
    let viewModel = AssetHomeViewModel()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        self.isTopLevel = true
        super.viewDidLoad()
        self.uiSetup()
        self.signalSetup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.staticsUpdate()
        self.viewModel.loadIfNeeded()
    }
    
    // MARK: - Custom Accessors
    
    // MARK: - IBActions
    @IBAction func settingPressed(_ sender: Any) {
        let actions = [
            FSActionSheetTitleItemMake(.normal, LOCSTR(withKey: "修改账户名称")),
            FSActionSheetTitleItemMake(.normal, LOCSTR(withKey: "重置密码")),
            FSActionSheetTitleItemMake(.normal, LOCSTR(withKey: "导出私钥"))
            ] as [FSActionSheetItem]
        let sheet = FSActionSheet(title: "", cancelTitle: LOCSTR(withKey: "取消"), items: actions)
        sheet?.show(selectedCompletion: { [weak self] (index) in
            switch index {
            case 0: self?.push(to: FormInputVC(withMode: .modifyAccountName), animated: true)
            case 1: self?.push(to: FormInputVC(withMode: .resetAccountPassword), animated: true)
            case 2:
                firstly {
                    AELFIdentity.shared().auth()
                    }.done { [weak self] (succeed, _) in
                        guard succeed else {
                            InfoToast(withLocalizedTitle: "密码错误")
                            self?.pop()
                            return
                        }
                        self?.push(to: UIStoryboard(name: "Assets", bundle: nil).instantiateViewController(withIdentifier: "exportPrivateKey"), animated: true)
                    }.catch { [weak self] (error) in
                        AELFIdentity.errorToast(withError: error)
                        self?.pop()
                }
            default:break
            }
        })
    }
    
    @IBAction func eyePressed(_ sender: Any) {
        self.viewModel.hideAssetsNumber.toggle()
    }
    
    @IBAction func createWalletPressed(_ sender: Any) {
        self.push(to: FormInputVC(withMode: .createETHWallet), animated: true)
    }
    
    @IBAction func importWalletPressed(_ sender: Any) {
        self.push(to: FormInputVC(withMode: .importETHWallet), animated: true)
    }
    
    @objc private func rewardViewPressed() {
        self.push(to: UIStoryboard(name: "Reward", bundle: nil).instantiateInitialViewController()!, animated: true)
    }
    
    // MARK: - Public
    
    // MARK: - Private
    private func uiSetup() -> Void {
        self.title = LOCSTR(withKey: "资产")
        self.topOffset.constant += CGFloat(kContentOffsetInfinityScreen)
    }
    
    private func signalSetup() -> Void {
        let refreshHeader = MJRefreshNormalHeader { [weak self] in
            self?.viewModel.loadIfNeeded()
        }
        self.tableView.bounces = true
        self.tableView.mj_header = refreshHeader
        
        self.viewModel.dataLoadedSignal.observeValues { [weak self] (_) in
            self?.tableView.mj_header.endRefreshing()
            self?.headerUpdate()
            self?.tableView.reloadData()
        }
        
        self.viewModel.reactive.producer(forKeyPath: "hideAssetsNumber").startWithValues { [weak self] (_) in
            self?.headerUpdate()
            self?.tableView.reloadData()
        }
        
        let ges = UITapGestureRecognizer(target: self, action: #selector(self.rewardViewPressed))
        self.rewardView.addGestureRecognizer(ges)
    }
    
    // MARK: - Signal
    
    // MARK: - Protocol conformance
    
    // MARK: - UITextFieldDelegate
    
    // MARK: - UITableViewDataSource
    
    // MARK: - UITableViewDelegate
    
    // MARK: - NSCopying
    
    // MARK: - NSObject
    
}

extension AssetHomeVC: UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.assetData?.currencyList?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        cell?.selectionStyle = .none
        if  let cell = cell as? AssetHomeCurrencyListCell,
            let data = self.viewModel.assetData?.currencyList,
            indexPath.row < data.count {
            cell.sync(withData: data[indexPath.row], hideAsset: self.viewModel.hideAssetsNumber)
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard AELFIdentity.hasIdentity() else {
            InfoToast(withLocalizedTitle: "请先创建/导入账户")
            return
        }
        
        guard let data = self.viewModel.assetData?.currencyList, indexPath.row < data.count else {
            InfoToast(withLocalizedTitle: "信息错误")
            return
        }
        
        let controller = UIStoryboard(name: "Assets", bundle: nil).instantiateViewController(withIdentifier: "assetDetail") as! AssetDetailVC
        controller.viewModel.currencyData = data[indexPath.row]
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
