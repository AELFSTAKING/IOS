//
//  TradeVC.swift
//  AELFExchange
//
//  Created by tng on 2019/1/7.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import Foundation
import UIKit
import ReactiveSwift
import MJRefresh

class TradeVC: BaseViewController {
    
    @IBOutlet weak var navigationBgView: View! {didSet { navigationBgView.backgroundColor = kThemeColorNavigationBar }}
    @IBOutlet weak var navigationView: UIView! {didSet { navigationView.backgroundColor = .clear }}
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var marketButton: UIButton!
    @IBOutlet weak var symbolTitleButton: UIButton! {didSet { symbolTitleButton.setTitleColor(kThemeColorTextNormal, for: .normal) }}
    
    @IBOutlet weak var contentViewHeightOffset: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            if #available(iOS 11.0, *) {
                self.scrollView.contentInsetAdjustmentBehavior = .never
            }
        }
    }
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var buyModeButton: Button! {didSet { buyModeButton.titleLabel?.font = .systemFont(ofSize: 14.0, weight: .medium) }}
    @IBOutlet weak var sellModeButton: Button! {didSet { sellModeButton.titleLabel?.font = .systemFont(ofSize: 14.0, weight: .medium) }}
    
    @IBOutlet weak var orderTypeButton: Button!
    @IBOutlet weak var orderTypeIconButton: UIButton! {didSet { orderTypeIconButton.transform = CGAffineTransform(scaleX: 1.3, y: 1.3) }}
    @IBOutlet weak var priceTextfield: TextField! {
        didSet {
            priceTextfield.keyboardType = .decimalPad
            priceTextfield.delegate = self
        }
    }
    @IBOutlet weak var marketPriceOfPriceLabel: Label! {
        didSet {
            marketPriceOfPriceLabel.addBorder(withWitdh: 0.65, color: kThemeColorBorderGray)
            marketPriceOfPriceLabel.isHidden = true
        }
    }
    @IBOutlet weak var legalPriceLabelTopOffset: NSLayoutConstraint! // Def 10.0
    @IBOutlet weak var legalPriceLabel: Label! {didSet { legalPriceLabel.textColor = .white }}
    @IBOutlet weak var quantityTextfieldHeight: NSLayoutConstraint! // Def 43.0
    @IBOutlet weak var quantityTextfield: TextField! {
        didSet {
            quantityTextfield.keyboardType = .decimalPad
            quantityTextfield.setPlaceholder(with: "请输入")
            quantityTextfield.delegate = self
        }
    }
    lazy var quantitySlider: TradeQuantitySlider = {
        let s = Bundle.main.loadNibNamed("TradeQuantitySlider", owner: nil, options: nil)?.first as! TradeQuantitySlider
        return s
    }()
    @IBOutlet weak var percent25Button: Button! {
        didSet {
            percent25Button.backgroundColor = .clear
            percent25Button.addBorder(withWitdh: 1.0, color: kThemeColorTextNormal)
        }
    }
    @IBOutlet weak var percent50Button: Button! {
        didSet {
            percent50Button.backgroundColor = .clear
            percent50Button.addBorder(withWitdh: 1.0, color: kThemeColorTextNormal)
        }
    }
    @IBOutlet weak var percent75Button: Button! {
        didSet {
            percent75Button.backgroundColor = .clear
            percent75Button.addBorder(withWitdh: 1.0, color: kThemeColorTextNormal)
        }
    }
    @IBOutlet weak var percent100Button: Button! {
        didSet {
            percent100Button.backgroundColor = .clear
            percent100Button.addBorder(withWitdh: 1.0, color: kThemeColorTextNormal)
        }
    }
    @IBOutlet weak var dealAmountBgView: UIView! {
        didSet {
            dealAmountBgView.backgroundColor = kThemeColorButtonUnable
        }
    }
    @IBOutlet weak var dealAmountTextfieldHeight: NSLayoutConstraint! // Def 43.0
    @IBOutlet weak var dealAmountTextfield: UITextField! {
        didSet {
            dealAmountTextfield.isEnabled = false
            dealAmountTextfield.textAlignment = .center
            dealAmountTextfield.textColor = kThemeColorTextUnabled
        }
    }
    @IBOutlet weak var dealQuantityTitleLabel: UILabel!
    @IBOutlet weak var dealCurrencyLabel: UILabel!
    @IBOutlet weak var availableQuantityValueLabel: Label!
    @IBOutlet weak var availableQuantityCurrencyLabel: Label!
    @IBOutlet weak var submitButton: Button! {
        didSet {
            submitButton.backgroundColor = kThemeColorGreen
            submitButton.titleLabel?.font = .systemFont(ofSize: 16.0, weight: .medium)
        }
    }
    
    let ordersCurrentTableViewHeaderHeight: CGFloat = 35.0
    let ordersCurrentHeaderTitle = Bundle.main.loadNibNamed("TradeOrderCurrentHeader", owner: nil, options: nil)?.first as! TradeOrderCurrentHeader
    let ordersCurrentHeaderPrice = Bundle.main.loadNibNamed("TradePriceCurrentHeader", owner: nil, options: nil)?.first as! TradePriceCurrentHeader
    @IBOutlet weak var ordersCurrentTableView: UITableView! {
        didSet {
            ordersCurrentTableView.backgroundColor = .clear
            ordersCurrentTableView.tableFooterView = UIView()
            ordersCurrentTableView.separatorStyle = .none
            ordersCurrentTableView.isScrollEnabled = false
            ordersCurrentTableView.delegate = self
            ordersCurrentTableView.dataSource = self
            ordersCurrentTableView.register(UINib(nibName: "TradeOrderCurrentCell", bundle: Bundle(identifier: "TradeOrderCurrentCell")), forCellReuseIdentifier: "cell-delegate")
        }
    }
    @IBOutlet weak var depthButton: Button! {
        didSet {
            depthButton.backgroundColor = .clear
            depthButton.titleLabel?.font = .systemFont(size: 11.0)
            depthButton.addBorder(withWitdh: 0.65, color: kThemeColorBorderGray)
        }
    }
    @IBOutlet weak var ordersDelegateTypeButton: Button! {
        didSet {
            ordersDelegateTypeButton.setTitle("\(LOCSTR(withKey: "默认")) ▼", for: .normal)
            ordersDelegateTypeButton.backgroundColor = .clear
            ordersDelegateTypeButton.titleLabel?.font = .systemFont(size: 11.0)
            ordersDelegateTypeButton.addBorder(withWitdh: 0.65, color: kThemeColorBorderGray)
        }
    }
    
    @IBOutlet weak var bottomSepView: UIView! {didSet { bottomSepView.backgroundColor = kThemeColorSeparator }}
    
    let userOrdersEmptyHeightMin: CGFloat = 130.0
    public static var userOrdersCellHeight: CGFloat = 98.0 // Dynamic Update.
    let userOrdersDatasource = TradeOrderBookDataSouce()
    @IBOutlet weak var userOrdersTableView: UITableView! {
        didSet {
            userOrdersTableView.isScrollEnabled = false
            userOrdersTableView.backgroundColor = .clear
            userOrdersTableView.tableFooterView = UIView()
            userOrdersTableView.separatorColor = kThemeColorSeparator
            userOrdersTableView.separatorInset = UIEdgeInsets(top: 0, left: 15.0, bottom: 0, right: 0)
            userOrdersTableView.delegate = userOrdersDatasource
            userOrdersTableView.dataSource = userOrdersDatasource
            userOrdersTableView.emptyDataSetSource = userOrdersDatasource
            userOrdersTableView.register(UINib(nibName: "OrderBookCell", bundle: Bundle(identifier: "OrderBookCell")), forCellReuseIdentifier: "cell-orderbook")
        }
    }
    
    let viewModel = TradeViewModel()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.uiSetup()
        self.signalSetup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.viewModel.loadAssets()
        self.startReceivingPushData()
        self.viewModel.loadUserOrders()
        if self.viewModel.symbol.isEmpty {
            self.staticDataSetup(withSymbol: nil)
        }
    }
    
    // MARK: - Custom Accessors
    
    // MARK: - IBActions
    @IBAction func backPressed(_ sender: Any) {
        self.pop()
    }
    
    @IBAction func symbolPressed(_ sender: Any) {
        MarketSymbolSelector.show(on: self, completion: { [weak self] (symbol) in
            if let symbol = symbol.symbol {
                guard symbol != self?.viewModel.symbol else { return }
                self?.viewModel.symbol = symbol
                self?.quantityTextfield.text = nil
                self?.viewModel.digitalQuantity = "0"
            }
        }) {}
    }
    
    @IBAction func marketIndexPressed(_ sender: Any) {
        let item = SymbolsItem()
        item.isShow = self.viewModel.symbolItem?.isShow
        item.symbol = self.viewModel.symbolItem?.symbol
        item.highestPrice = self.viewModel.symbolItem?.highestPrice
        item.maxPrice = self.viewModel.symbolItem?.maxPrice
        item.highestUsdPrice = self.viewModel.symbolItem?.highestUsdPrice
        item.lowestPrice = self.viewModel.symbolItem?.lowestPrice
        item.minPrice = self.viewModel.symbolItem?.minPrice
        item.lowestUsdPrice = self.viewModel.symbolItem?.lowestUsdPrice
        item.price = self.viewModel.symbolItem?.price
        item.lastPrice = self.viewModel.symbolItem?.lastPrice
        item.usdPrice = self.viewModel.symbolItem?.usdPrice
        item.lastUsdPrice = self.viewModel.symbolItem?.lastUsdPrice
        item.quantity = self.viewModel.symbolItem?.quantity
        item.wavePrice = self.viewModel.symbolItem?.wavePrice
        item.wavePercent = self.viewModel.symbolItem?.wavePercent
        item.direction = self.viewModel.symbolItem?.direction
        self.push(to: KLineController(with: item), animated: true)
    }
    
    @IBAction func buyModePressed(_ sender: Any) {
        self.viewModel.mode = TradeViewModeEnum.buy.rawValue
    }
    
    @IBAction func sellModePressde(_ sender: Any) {
        self.viewModel.mode = TradeViewModeEnum.sell.rawValue
    }
    
    @IBAction func orderTypePressed(_ sender: Any) {
        self.updateOrderTypeEvent()
    }
    
    // Buttons has been Deprecated.
    @IBAction func percent25Presseed(_ sender: Any) {
        self.fillQuantity(withPercent: 0.25)
    }
    
    @IBAction func percent50Pressed(_ sender: Any) {
        self.fillQuantity(withPercent: 0.5)
    }
    
    @IBAction func percent75Pressed(_ sender: Any) {
        self.fillQuantity(withPercent: 0.75)
    }
    
    @IBAction func percent100Pressed(_ sender: Any) {
        self.fillQuantity(withPercent: 1.0)
    }
    
    @IBAction func depthPressed(_ sender: Any) {
        self.view.endEditing(true)
        guard let config = self.viewModel.depthMenuConfigOfCurrentSymbol else {
            InfoToast(withLocalizedTitle: "信息加载中")
            self.viewModel.loadDepthConfig()
            return
        }
        var actions = [FSActionSheetItem]()
        for item in config.menuForDisplayObjs {
            actions.append(FSActionSheetTitleItemMake(.normal, item))
        }
        let sheet = FSActionSheet(title: "", cancelTitle: LOCSTR(withKey: "取消"), items: actions)
        sheet?.show(selectedCompletion: { [weak self] (index) in
            guard index < config.apiObjs.count else { return }
            self?.viewModel.depthForMenuDisplay = "\(config.menuForDisplayObjs[index])"
            self?.viewModel.depth = config.apiObjs[index]
        })
    }
    
    @IBAction func ordersCurrentTypePressed(_ sender: Any) {
        self.view.endEditing(true)
        let actions = [
            FSActionSheetTitleItemMake(.normal, LOCSTR(withKey: "默认")),
            FSActionSheetTitleItemMake(.normal, LOCSTR(withKey: "卖单")),
            FSActionSheetTitleItemMake(.normal, LOCSTR(withKey: "买单"))
            ] as [FSActionSheetItem]
        let sheet = FSActionSheet(title: "", cancelTitle: LOCSTR(withKey: "取消"), items: actions)
        sheet?.show(selectedCompletion: { [weak self] (index) in
            switch index {
            case 0: self?.viewModel.ordersDelegateMode = TradeViewOrderCurrentModeEnum.normal.rawValue
            case 1: self?.viewModel.ordersDelegateMode = TradeViewOrderCurrentModeEnum.sell.rawValue
            case 2: self?.viewModel.ordersDelegateMode = TradeViewOrderCurrentModeEnum.buy.rawValue
            default:break
            }
            guard index < actions.count else { return }
            self?.ordersDelegateTypeButton.setTitle("\(actions[index].title ?? "") ▼", for: .normal)
        })
    }
    
    @IBAction func submitPressed(_ sender: Any) {
        self.view.endEditing(true)
        guard AELFIdentity.hasIdentity() else {
            InfoToast(withLocalizedTitle: "未查询到账户，请导入或创建")
            return
        }
        
        self.startLoadingHUD(withMsg: Consts.kMsgInProcess)
        MarketManager.shared().tradeSymbolConfig(of: self.viewModel.symbol) { [weak self] (data) in
            self?.stopLoadingHUD()
            guard let data = data, data.tradeStatus == 1 else {
                InfoToast(withLocalizedTitle: "交易当前不被支持")
                return
            }
            self?.submit()
        }
    }
    
    // MARK: - Public
    
    // MARK: - Private
    private func uiSetup() -> Void {
        self.title = LOCSTR(withKey: "交易")
        self.backButton.isHidden = !self.viewModel.isNotTopLevel
        self.hideCustomBackButton()
        self.contentViewHeightOffset.constant += kScreenSize.height
        
        self.priceTextfield.font = kThemeFontDINBold(14.0)
        self.quantityTextfield.font = kThemeFontDINBold(14.0)
        self.percent25Button.titleLabel?.font = kThemeFontDINSmall
        self.percent50Button.titleLabel?.font = self.percent25Button.titleLabel?.font
        self.percent75Button.titleLabel?.font = self.percent25Button.titleLabel?.font
        self.percent100Button.titleLabel?.font = self.percent25Button.titleLabel?.font
        self.availableQuantityValueLabel.font = kThemeFontDINSmall
        self.dealAmountTextfield.font = kThemeFontDINBold(14.0)
        
        self.contentView.addSubview(self.quantitySlider)
        self.quantitySlider.snp.makeConstraints { (make) in
            make.top.left.bottom.equalTo(self.percent25Button)
            make.right.equalTo(self.percent100Button)
        }
        
        // Static Text.
        self.staticDataSetup(withSymbol: nil)
    }
    
    private func signalSetup() -> Void {
        Profile.shared().loginSignal.observeValues { [weak self] (_) in
            let bestPrice = self?.viewModel.bestPrice2BuyOrSell ?? ""
            self?.priceTextfield.text = bestPrice
            self?.viewModel.digitalPrice = bestPrice
        }
        
        self.viewModel.reactive.producer(forKeyPath: "mode").startWithValues { [weak self] (mode) in
            guard let mode = mode as? String, let theMode = TradeViewModeEnum(rawValue: mode) else { return }
            self?.updateMode(with: theMode)
            self?.updateCurrencyOfAvailableCurrency()
        }
        
        self.viewModel.reactive.producer(forKeyPath: "ordersDelegateMode").startWithValues { [weak self] (mode) in
            self?.ordersCurrentTableView.reloadData()
        }
        
        self.viewModel.handleLatestPriceFromRESTAPICallback = { [weak self] (price, priceUSD, direction) in
            self?.gotLatestPrice(with: price, latestDealPriceUSD: priceUSD, direction: direction)
        }
        
        self.viewModel.reactive.producer(forKeyPath: "depth").startWithValues { [weak self] (_) in
            self?.updateDepthMenu()
        }
        
        self.viewModel.reactive.producer(forKeyPath: "orderType").startWithValues { [weak self] (mode) in
            self?.orderTypeButton.setTitle(LOCSTR(withKey: self?.viewModel.orderType ?? "限价单"), for: .normal)
            let isNotMarketOrder = self?.viewModel.orderType != TradeOrderTypeEnum.market.rawValue
            self?.marketPriceOfPriceLabel.isHidden = isNotMarketOrder
            self?.priceTextfield.isHidden = !isNotMarketOrder
            self?.dealAmountTextfield.isHidden = !isNotMarketOrder
            self?.clearQuantity()
            if !isNotMarketOrder {
                self?.legalPriceLabel.text = "--"
            } else {
                self?.updateLegalAmount()
            }
            if self?.viewModel.orderType == TradeOrderTypeEnum.market.rawValue {
                self?.dealQuantityTitleLabel.isHidden = true
                self?.dealCurrencyLabel.isHidden = true
                self?.legalPriceLabel.text = nil
                self?.legalPriceLabelTopOffset.constant = 0.00001
                self?.legalPriceLabel.isHidden = true
                self?.dealAmountTextfieldHeight.constant = 0.00001
            } else {
                self?.dealQuantityTitleLabel.isHidden = false
                self?.dealCurrencyLabel.isHidden = false
                self?.legalPriceLabel.isHidden = false
                self?.updateLegalAmount()
                self?.dealAmountTextfieldHeight.constant = 43.0
                self?.legalPriceLabelTopOffset.constant = 10.0
            }
        }
        
        self.viewModel.reactive.producer(forKeyPath: "symbol").startWithValues { [weak self] (value) in
            guard let value = value as? String, value.count > 0 else { return }
            
            MarketManager.shared().allExchangeSymbol({ (symbols) in
                for case let s in symbols where s.symbol == value {
                    self?.viewModel.symbolItem = s
                    break
                }
            })
            
            self?.symbolTitleButton.setTitle(value, for: .normal)
            self?.viewModel.loadBestPrice()
            self?.viewModel.loadDecimalLenConfig()
            self?.startReceivingPushData()
            self?.updateDealCurrencyIfNeeded()
            self?.reloadUserOrders()
            if let modeStr = self?.viewModel.mode, let theMode = TradeViewModeEnum(rawValue: modeStr) {
                self?.updateBuySellButton(with: theMode)
            }
        }
        
        self.priceTextfield.reactive.continuousTextValues.observeValues { [weak self] (value) in
            self?.priceForTextfieldUpdated(with: value)
        }
        
        self.viewModel.reactive.producer(forKeyPath: "bestPrice2BuyOrSell").startWithValues { [weak self] (value) in
            guard let value = value as? String else { return }
            self?.priceTextfield.text = value
            self?.viewModel.digitalPrice = value
        }
        
        self.viewModel.reactive.producer(forKeyPath: "digitalPrice").startWithValues { [weak self] (value) in
            guard let value = value as? String else { return }
            self?.calculateLegalAmount(with: value)
            self?.dealAmountForTextfieldUpdated()
        }
        
        self.viewModel.reactive.producer(forKeyPath: "legalAmount").startWithValues { [weak self] (value) in
            self?.updateLegalAmount()
        }
        
        self.quantityTextfield.reactive.continuousTextValues.observeValues { [weak self] (value) in
            self?.viewModel.digitalQuantity = value ?? "0"
        }
        
        self.viewModel.reactive.producer(forKeyPath: "digitalQuantity").startWithValues { [weak self] (value) in
            self?.dealAmountForTextfieldUpdated()
        }
        
        self.viewModel.reactive.producer(forKeyPath: "currency").startWithValues { [weak self] (value) in
            guard let value = value as? String else { return }
            self?.updateCurrencyOfAvailableCurrency()
            self?.ordersCurrentHeaderTitle.updateCurrency(withCurreny: value, baseCurreny: self?.viewModel.baseCurrency ?? "")
        }
        
        self.viewModel.reactive.producer(forKeyPath: "baseCurrency").startWithValues { [weak self] (value) in
            guard let value = value as? String else { return }
            self?.priceTextfield.setPlaceholder(with: "\(LOCSTR(withKey: "价格"))(\(value))")
            self?.updateCurrencyOfAvailableCurrency()
            self?.ordersCurrentHeaderTitle.updateCurrency(withCurreny: self?.viewModel.currency ?? "", baseCurreny: value)
        }
        
        self.viewModel.reactive.producer(forKeyPath: "availableAsset").startWithValues { [weak self] (value) in
            if let value = value as? String {
                self?.availableQuantityValueLabel.text = value.digitalString()
            } else {
                self?.availableQuantityValueLabel.text = "--"
            }
            self?.updateCurrencyOfAvailableCurrency()
        }
        
        self.viewModel.reactive.producer(forKeyPath: "userOrdersType").startWithValues { [weak self] (value) in
            TradeVC.userOrdersCellHeight = (self?.viewModel.userOrdersType == UserOrderTypeEnum.current.rawValue ? 98.0:150.0)
            self?.userOrdersDatasource.userOrdersType = UserOrderTypeEnum(rawValue: self?.viewModel.userOrdersType ?? 1)!
            self?.userOrdersTableView.reloadData()
            self?.reloadUserOrders()
        }
        
        self.viewModel.orderBookLoadedSignal.observeValues { [weak self] (_) in
            self?.updateDynamicDataWithGotNewSymbol()
        }
        
        AELFIdentity.shared().identityRemovedSignal.observeValues { [weak self] (_) in
            self?.viewModel.resetUserOrders()
        }
        
        // User Orders
        let refreshHeader = MJRefreshNormalHeader { [weak self] in
            self?.userOrdersTableView.mj_footer.resetNoMoreData()
            self?.viewModel.userOrdersPage = Config.startIndexOfPage
            self?.viewModel.loadUserOrders()
            self?.viewModel.loadBestPrice()
        }
        self.scrollView.bounces = true
        self.scrollView.mj_header = refreshHeader
        
        let refreshFooter = MJRefreshAutoNormalFooter { [weak self] in
            self?.viewModel.userOrdersPage += 1
            self?.viewModel.loadUserOrders()
        }
        refreshFooter?.setTitle(Consts.kMsgLoading, for: .refreshing)
        refreshFooter?.setTitle(Consts.kMsgNoMore, for: .noMoreData)
        refreshFooter?.setTitle(Consts.kMsgLoadMoreManually, for: .idle)
        refreshFooter?.stateLabel.textColor = kThemeColorTextUnabled
        self.userOrdersTableView.mj_footer = refreshFooter
        
        self.viewModel.userOrdersLoadedSignal.observeValues { [weak self] (_) in
            self?.scrollView.mj_header.endRefreshing()
            self?.userOrdersTableView.mj_footer.endRefreshing()
            self?.updateUserOrders()
        }
        self.viewModel.userOrdersNoMoreSignal.observeValues { [weak self] (_) in
            self?.userOrdersTableView.mj_footer.endRefreshingWithNoMoreData()
            (self?.userOrdersTableView.mj_footer as! MJRefreshAutoNormalFooter).stateLabel.textColor = (self?.viewModel.userOrdersData.count ?? 0 > 0 ? kThemeColorTextUnabled:.clear)
        }
        
        // Actions.
        self.priceTextfield.priceButtonLeft.reactive.controlEvents(.touchUpInside).observeValues { [weak self] (_) in
            self?.priceOfTextfieldReduce()
        }
        self.priceTextfield.priceButtonRight.reactive.controlEvents(.touchUpInside).observeValues { [weak self] (_) in
            self?.priceOfTextfieldIncrease()
        }
        
        self.quantityTextfield.reactive.controlEvents(.editingDidBegin).observeValues { (textfield) in
            if NSDecimalNumber(string: textfield.text).compare(0.0) == .orderedSame {
                textfield.text = nil
            }
        }
        self.quantityTextfield.reactive.controlEvents(.editingDidEnd).observeValues { (textfield) in
            if NSDecimalNumber(string: textfield.text).compare(0.0) == .orderedSame || textfield.text?.isEmpty == true {
                textfield.text = "0.0"
            }
        }
        self.quantitySlider.valueChangedCallback = { [weak self] (percent) in
            self?.fillQuantity(withPercent: percent)
        }
        
        self.userOrdersDatasource.headerButtonPressedSignal.observeValues { [weak self] (buttonType) in
            self?.userOrdersDatasource.userOrdersData.removeAll()
            switch buttonType {
            case .current:
                self?.viewModel.userOrdersType = UserOrderTypeEnum.current.rawValue
                self?.userOrdersDatasource.userOrdersType = .current
                self?.userOrdersTableView.reloadData()
            case .history:
                self?.viewModel.userOrdersType = UserOrderTypeEnum.history.rawValue
                self?.userOrdersDatasource.userOrdersType = .history
                self?.userOrdersTableView.reloadData()
            case .all:
                self?.push(to: OrderBookVC(), animated: true)
            }
        }
        self.userOrdersDatasource.itemPressedSignal.observeValues { [weak self] (data) in
            let controller = UIStoryboard(name: "Trade", bundle: nil).instantiateViewController(withIdentifier: "orderDetail") as! OrderDetailVC
            controller.data = data
            self?.push(to: controller, animated: true)
        }
        self.userOrdersDatasource.cancelButtonPressedSignal.observeValues { [weak self] (data) in
            self?.cancel(withData: data)
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
