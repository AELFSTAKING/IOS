//
//  MarketKLineVC.swift
//  AELFExchange
//
//  Created by tng on 2019/1/21.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import Foundation
import UIKit
import ReactiveSwift

class MarketKLineVC: BaseViewController {
    
    let orderCellHeight: CGFloat = 40.0
    
    @IBOutlet weak var navBgView: View! {didSet { navBgView.backgroundColor = kThemeColorNavigationBar }}
    @IBOutlet weak var navigationView: UIView! {didSet { navigationView.backgroundColor = .clear }}
    @IBOutlet weak var symbolButtonCenterY: NSLayoutConstraint! // Def 0.0
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var collectButton: UIButton!
    @IBOutlet weak var symbolButton: UIButton!
    @IBOutlet weak var symbolArrowButton: UIButton!
    @IBOutlet weak var roundLabel: UILabel!
    @IBOutlet weak var roundTimeRemainingLabel: UILabel!
    
    @IBOutlet weak var contentViewHeightOffset: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var priceLabel: Label!
    @IBOutlet weak var priceLegalLabel: Label!
    @IBOutlet weak var upRateLabel: Label!
    @IBOutlet weak var lowestPricceLabel: Label!
    @IBOutlet weak var dealVolumeTitleLabel: Label!
    @IBOutlet weak var dealVolumeLabel: Label!
    @IBOutlet weak var highestPriceLabel: Label!
    
    @IBOutlet weak var klineMenuStackView: UIStackView!
    @IBOutlet weak var klineFullscreenButton: Button!
    @IBOutlet weak var bottomSepView: UIView!
    
    @IBOutlet weak var klineContainView: UIView! {didSet { klineContainView.backgroundColor = .clear }}
    lazy var kline: CHKLineChartView = {
        let k = CHKLineChartView(frame: .zero)
        k.style = self.klineStyle()
        k.delegate = self
        return k
    }()
    lazy var depthChartContainerView: UIView = {
        let v = UIView()
        v.backgroundColor = kThemeColorBackground
        return v
    }()
    lazy var depthChart: CHDepthChartView = {
        let view = CHDepthChartView(frame: CGRect(x: 0, y: 0, width: 100, height: 180))
        view.delegate = self
        view.style = .defaultDepthStyle
        view.yAxis.referenceStyle = .none
        return view
    }()
    lazy var depthPercentLabel: Label = {
        let l = Label()
        l.General = "1"
        l.FontSize = "10"
        l.text = "--%"
        return l
    }()
    
    @IBOutlet weak var depthButton: Button!
    @IBOutlet weak var dealLatestButton: Button!
    @IBOutlet weak var introductionButton: Button!
    var isIntroductionMode = false
    let introductionView = Bundle.main.loadNibNamed("MarketIntroductionView", owner: "MarketIntroductionView", options: nil)?.first as! MarketIntroductionView
    
    let headerDelegate = Bundle.main.loadNibNamed("MarketOrderHeaderDelegate", owner: nil, options: nil)?.first as! MarketOrderHeaderDelegate
    let headerLatestDeal = Bundle.main.loadNibNamed("MarketOrderHeaderLatestDeal", owner: nil, options: nil)?.first as! MarketOrderHeaderLatestDeal
    @IBOutlet weak var orderTableViewTopOffset: NSLayoutConstraint! // Def 0.0
    @IBOutlet weak var orderTableView: UITableView! {
        didSet {
            orderTableView.separatorStyle = .none
            orderTableView.tableFooterView = UIView()
            orderTableView.backgroundColor = .clear
            orderTableView.isScrollEnabled = false
            orderTableView.delegate = self
            orderTableView.dataSource = self
            orderTableView.register(UINib(nibName: "MarketDealListCell", bundle: Bundle(identifier: "MarketDealListCell")), forCellReuseIdentifier: "cell-dealist")
            orderTableView.register(UINib(nibName: "MarketDelegateOrderCell", bundle: Bundle(identifier: "MarketDelegateOrderCell")), forCellReuseIdentifier: "cell-delegate")
        }
    }
    @IBOutlet weak var buyButton: Button! {
        didSet {
            buyButton.setTitleColor(.white, for: .normal)
            buyButton.backgroundColor = kThemeColorGreen
        }
    }
    @IBOutlet weak var sellButton: Button! {
        didSet {
            sellButton.setTitleColor(.white, for: .normal)
            sellButton.backgroundColor = kThemeColorRed
        }
    }
    
    let viewModel = MarketKLineViewModel()
    private var currentContentOffset: CGFloat = 0.0
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.uiSetup()
        self.signalSetup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        if !self.isFirstTimeToShow {
            self.startReceivingDelegateOrdersData()
            self.startReceivingLatestPriceData()
            self.startReceivingKLineData()
            self.startReceivingDepthData()
        }
    }
    
    // MARK: - Custom Accessors
    
    // MARK: - IBActions
    @IBAction func backPressed(_ sender: Any) {
        self.pop()
    }
    
    @IBAction func collectPressde(_ sender: Any) {
        guard let data = self.viewModel.data,
            let symbol = data.symbol else {
                return
        }
        
        self.collectButton.isSelected.toggle()
        let colleceted = DB.shared().isSymbolCollected(for: symbol)
        DB.shared().symbolCollect(forCollect: !colleceted, symbol: symbol)
    }
    
    @IBAction func symbolPressed(_ sender: Any) {
        self.symbolArrowPressed(self.symbolArrowButton!)
    }
    
    @IBAction func symbolArrowPressed(_ sender: Any) {
        MarketSymbolSelector.show(on: self, completion: { [weak self] (symbol) in
            if let symbol = symbol.symbol {
                guard symbol != self?.viewModel.symbol else { return }
                self?.viewModel.data?.symbol = symbol
                self?.viewModel.symbol = symbol
                self?.resetToDefault()
                self?.viewModel.loadMarketBaseInfoAndDisplayIfNeeded()
                self?.startReceivingLatestPriceData()
                if self?.viewModel.orderType == MarketDetailOrderTypeEnum.depthAndDelegateOrder.rawValue {
                    self?.delegateOrderPressed(UIButton())
                } else {
                    self?.dealLatestPressed(UIButton())
                }
            }
        }) { [weak self] in
            // Collect Status Changed.
            self?.updateCollectStatus(self?.viewModel.symbol)
        }
    }
    
    @IBAction func time1Pressed(_ sender: Any) {
        self.viewModel.klineRange = "60000"
        self.hoursChained(to: 1)
    }
    @IBAction func time15Pressed(_ sender: Any) {
        self.viewModel.klineRange = "900000"
        self.hoursChained(to: 2)
    }
    @IBAction func time30Pressed(_ sender: Any) {
        self.viewModel.klineRange = "1800000"
        self.hoursChained(to: 3)
    }
    @IBAction func time1hPressed(_ sender: Any) {
        self.viewModel.klineRange = "3600000"
        self.hoursChained(to: 4)
    }
    @IBAction func time4hPressed(_ sender: Any) {
        self.viewModel.klineRange = "14400000"
        self.hoursChained(to: 5)
    }
    @IBAction func time1dPressed(_ sender: Any) {
        self.viewModel.klineRange = "86400000"
        self.hoursChained(to: 6)
    }
    @IBAction func time1wPressed(_ sender: Any) {
        self.viewModel.klineRange = "604800000"
        self.hoursChained(to: 7)
    }
    
    @IBAction func klineFullscreenPressed(_ sender: Any) {
        guard self.viewModel.symbol.count > 0, self.viewModel.klineData.count > 0 else {
            InfoToast(withLocalizedTitle: "数据加载中...")
            return
        }
        let controller = UIStoryboard(name: "Market", bundle: nil).instantiateViewController(withIdentifier: "marketKLineFullscreen") as! MarketKLineFullscreenVC
        controller.viewModel.symbol = self.viewModel.symbol
        self.present(controller, animated: true) {}
    }
    
    @IBAction func delegateOrderPressed(_ sender: Any) {
        self.viewModel.orderType = MarketDetailOrderTypeEnum.depthAndDelegateOrder.rawValue
    }
    
    @IBAction func dealLatestPressed(_ sender: Any) {
        self.viewModel.orderType = MarketDetailOrderTypeEnum.latestDeal.rawValue
    }
    
    @IBAction func introductionPressed(_ sender: Any) {
        self.dealLatestButton.titleLabel?.font = UIFont.systemFont(ofSize: 14.0, weight: .bold)
        self.depthButton.titleLabel?.font = UIFont.systemFont(ofSize: 14.0, weight: .bold)
        self.introductionButton.titleLabel?.font = UIFont.systemFont(ofSize: 16.0, weight: .bold)
        self.introductionButton.setTitleColor(kThemeColorTextNormal, for: .normal)
        self.depthButton.setTitleColor(.darkGray, for: .normal)
        self.dealLatestButton.setTitleColor(.darkGray, for: .normal)
        self.isIntroductionMode = true
        self.introductionView.isHidden = false
        self.hideDepth()
        self.updateIntroduction()
    }
    
    @IBAction func buyPressed(_ sender: Any) {
        self.showTrade(with: .buy)
    }
    
    @IBAction func sellPressed(_ sender: Any) {
        self.showTrade(with: .sell)
    }
    
    private func showTrade(with action: NotificationObjTradeAction) -> Void {
        guard let symbol = self.viewModel.data?.symbol else {
            InfoToast(withLocalizedTitle: "信息获取失败")
            return
        }
        self.ShowTradePage(withSymbol: symbol, mode: action == .buy ? .buy : .sell)
    }
    
    // MARK: - Public
    
    // MARK: - Private
    private func uiSetup() -> Void {
        guard let data = self.viewModel.data,
            self.viewModel.symbol.count > 0 else {
                InfoToast(withLocalizedTitle: "信息获取失败")
                self.pop()
                return
        }
        
        self.priceLabel.font = kThemeFontDINLarge
        self.priceLegalLabel.font = kThemeFontDINNormal
        self.upRateLabel.font = kThemeFontDINSmall
        self.lowestPricceLabel.font = kThemeFontDINSmall
        self.dealVolumeLabel.font = kThemeFontDINSmall
        self.highestPriceLabel.font = kThemeFontDINSmall
        self.dealLatestButton.titleLabel?.font = UIFont.systemFont(ofSize: 16.0, weight: .bold)
        self.depthButton.titleLabel?.font = UIFont.systemFont(ofSize: 14.0, weight: .bold)
        self.introductionButton.titleLabel?.font = UIFont.systemFont(ofSize: 14.0, weight: .bold)
        
        // KLine.
        self.klineContainView.addSubview(self.kline)
        self.kline.snp.makeConstraints { (make) in
            make.edges.equalTo(self.klineContainView).inset(UIEdgeInsets(top: 20.0, left: 0, bottom: -10.0, right: 0))
        }
        self.depthViewSetup()
        self.startLoadingHUD(on: self.klineContainView, center: true, bgAlpha: 0.05)
        
        // Introduction.
        self.introductionView.isHidden = true
        self.contentView.addSubview(self.introductionView)
        self.introductionView.snp.makeConstraints { (make) in
            make.edges.equalTo(orderTableView)
        }
        
        // Default Index init.
        self.kline.setSerie(hidden: true, inSection: 0)
        self.kline.setSerie(hidden: false, by: CHSeriesKey.ma, inSection: 0)
        self.kline.setSerie(hidden: false, by: CHSeriesKey.candle, inSection: 0)
        
        // Static Texts.
        data.price = "--"
        data.usdPrice = "--"
        data.wavePrice = "--"
        data.wavePercent = "--"
        data.quantity = "--"
        data.lowestPrice = "--"
        data.minPrice = "--"
        data.highestPrice = "--"
        data.maxPrice = "--"
        self.staticDataBind(with: data, symbol: self.viewModel.symbol)
        self.viewModel.loadMarketBaseInfoAndDisplayIfNeeded()
        
        // Push data.
        self.startReceivingLatestPriceData()
    }
    
    private func signalSetup() -> Void {
        self.viewModel.reactive.producer(forKeyPath: "symbol").startWithValues { [weak self] (value) in
            guard let value = value as? String, value.count > 0 else { return }
            self?.symbolButton.setTitle(value, for: .normal)
            self?.loadKline()
            self?.viewModel.loadDepthData()
            self?.viewModel.loadDecimalLenConfig()
        }
        
        self.viewModel.marketBaseInfoLoadedSignal.observeValues { [weak self] (symbols) in
            self?.updateMarketBaseInfoIfNeeded(withSymbols: symbols)
        }
        
        self.viewModel.klineDataLoadedSignal.observeValues { [weak self] (_) in
            self?.stopLoadingHUD(on: self?.klineContainView)
            self?.kline.reloadData(toPosition: .end, resetData: true)
            self?.startReceivingKLineData()
        }
        
        self.viewModel.klineDataAppendedSignal.observeValues { [weak self] (_) in
            DispatchQueue.main.async {
                if self?.viewModel.isKlineRightEdge == true {
                    self?.kline.reloadData(toPosition: .end, resetData: false)
                } else {
                    self?.kline.reloadData(resetData: false)
                }
            }
        }
        
        self.viewModel.reactive.producer(forKeyPath: "klineRange").startWithValues { [weak self] (_) in
            guard self?.isFirstTimeToShow == false else { return }
            self?.loadKline()
        }
        
        self.viewModel.reactive.producer(forKeyPath: "depthPercent").startWithValues { [weak self] (value) in
            guard let value = value as? String else { return }
            self?.depthPercentLabel.text = value
        }
        
        self.viewModel.depthLoadedSignal.observeValues { [weak self] (_) in
            self?.depthChart.reloadData()
        }
        
        self.viewModel.reactive.producer(forKeyPath: "orderType").startWithValues { [weak self] (type) in
            guard let type = type as? Int, let theType = MarketDetailOrderTypeEnum(rawValue: type) else { return }
            self?.isIntroductionMode = false
            self?.introductionView.isHidden = true
            self?.introductionButton.setTitleColor(.darkGray, for: .normal)
            if theType == .depthAndDelegateOrder {
                self?.showDepth()
                self?.depthButton.setTitleColor(kThemeColorTextNormal, for: .normal)
                self?.dealLatestButton.setTitleColor(.darkGray, for: .normal)
                self?.dealLatestButton.titleLabel?.font = UIFont.systemFont(ofSize: 14.0, weight: .bold)
                self?.depthButton.titleLabel?.font = UIFont.systemFont(ofSize: 16.0, weight: .bold)
                self?.introductionButton.titleLabel?.font = UIFont.systemFont(ofSize: 14.0, weight: .bold)
            } else {
                self?.hideDepth()
                self?.depthButton.setTitleColor(.darkGray, for: .normal)
                self?.dealLatestButton.setTitleColor(kThemeColorTextNormal, for: .normal)
                self?.dealLatestButton.titleLabel?.font = UIFont.systemFont(ofSize: 16.0, weight: .bold)
                self?.depthButton.titleLabel?.font = UIFont.systemFont(ofSize: 14.0, weight: .bold)
                self?.introductionButton.titleLabel?.font = UIFont.systemFont(ofSize: 14.0, weight: .bold)
            }
            self?.viewModel.loadOrders()
            self?.viewModel.loadDepthConfig()
        }
        
        self.viewModel.ordersLoadedSignal.observeValues { [weak self] (_) in
            self?.orderTableView.reloadData()
            var offset: CGFloat = 0.0
            if self?.viewModel.orderType == MarketDetailOrderTypeEnum.depthAndDelegateOrder.rawValue {
                if  let buy = self?.viewModel.delegateOrdersData?.bidList,
                    let sell = self?.viewModel.delegateOrdersData?.askList {
                    offset = CGFloat(max(buy.count, sell.count))*(self?.orderCellHeight)!+(self?.depthChartContainerView.frame.height ?? 0)
                }
            } else {
                if let data = self?.viewModel.latestDealOrdersData {
                    offset = CGFloat(data.count)*(self?.orderCellHeight)!
                }
            }
            
            let targetOffset = offset-CGFloat(kTabBarHeight)
            if self?.currentContentOffset != targetOffset {
                self?.currentContentOffset = targetOffset
                self?.contentViewHeightOffset.constant = targetOffset
            }
        }
        
        self.viewModel.ordersLoadedFromRESTAPISignalForSubscriber.observeValues { [weak self] (_) in
            if self?.viewModel.orderType == MarketDetailOrderTypeEnum.depthAndDelegateOrder.rawValue {
                self?.startReceivingDelegateOrdersData()
            } else {
                self?.startReceivingLatestDealOrdersData()
            }
        }
        
        self.headerDelegate.depthButton.reactive.controlEvents(.touchUpInside).observeValues { [weak self] (_) in
            self?.depthLevelOfDelegateOrdersPressed()
        }
        
        self.viewModel.reactive.producer(forKeyPath: "depth").startWithValues { [weak self] (_) in
            if let title = self?.viewModel.depthForMenuDisplay {
                self?.headerDelegate.depthButton.setTitle(title.replacingOccurrences(of: "位小数", with: ""), for: .normal)
            }
            self?.viewModel.loadOrders()
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
