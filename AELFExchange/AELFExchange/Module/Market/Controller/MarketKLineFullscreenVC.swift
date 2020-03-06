//
//  MarketKLineFullscreenVC.swift
//  AELFExchange
//
//  Created by tng on 2019/2/12.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import Foundation
import UIKit

class MarketKLineFullscreenVC: BaseViewController {
    
    @IBOutlet weak var klineContainerView: UIView! {
        didSet {
            klineContainerView.backgroundColor = .clear
        }
    }
    lazy var kline: CHKLineChartView = {
        let k = CHKLineChartView(frame: .zero)
        k.style = self.klineStyle()
        k.delegate = self
        return k
    }()
    
    @IBOutlet weak var symbolLabel: Label!
    @IBOutlet weak var priceLabel: Label!
    @IBOutlet weak var legalPriceLabel: Label!
    @IBOutlet weak var rateValueLabel: Label!
    @IBOutlet weak var ratePercentLabel: Label!
    @IBOutlet weak var dateLabel: Label!
    @IBOutlet weak var closeButton: UIButton!
    
    @IBOutlet weak var indexStackView: UIStackView!
    @IBOutlet weak var emaButton: Button!
    @IBOutlet weak var smaButton: Button!
    @IBOutlet weak var bollButton: Button!
    @IBOutlet weak var volButton: Button!
    @IBOutlet weak var macdButton: Button!
    @IBOutlet weak var kdjButton: Button!
    @IBOutlet weak var rsiButton: Button!
    
    @IBOutlet weak var timeStackView: UIStackView!
    @IBOutlet weak var timelineButton: Button!
    @IBOutlet weak var dayButton: Button!
    @IBOutlet weak var weekButton: Button!
    @IBOutlet weak var hourButton: Button! {
        didSet {
            hourButton.setTitle(LOCSTR(withKey: "1\(LOCSTR(withKey: "小时").replacingOccurrences(of: "s", with: ""))"), for: .normal)
        }
    }
    @IBOutlet weak var minuteButton: Button! {
        didSet {
            minuteButton.setTitle(LOCSTR(withKey: "15\(LOCSTR(withKey: "分"))"), for: .normal)
        }
    }
    
    private var timer: Timer!
    
    var viewModel = MarketKLineFullscreenViewModel()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.uiSetup()
        self.signalSetup()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if timer != nil {
            timer.fireDate = Date.distantFuture
            timer.invalidate()
        }
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return [.landscapeRight, .landscapeLeft]
    }
    
    // MARK: - Custom Accessors
    
    // MARK: - IBActions
    @IBAction func closePressed(_ sender: Any) {
        self.dismiss(animated: true) {}
    }
    
    @IBAction func emaPressed(_ sender: Any) {
        self.indexButtonsPressed(withTag: 1)
    }
    
    @IBAction func smaPressed(_ sender: Any) {
        self.indexButtonsPressed(withTag: 2)
    }
    
    @IBAction func bollPressed(_ sender: Any) {
        self.indexButtonsPressed(withTag: 3)
    }
    
    @IBAction func volPressed(_ sender: Any) {
        self.indexButtonsPressed(withTag: 4)
    }
    
    @IBAction func macdPressed(_ sender: Any) {
        self.indexButtonsPressed(withTag: 5)
    }
    
    @IBAction func kdjPressed(_ sender: Any) {
        self.indexButtonsPressed(withTag: 6)
    }
    
    @IBAction func rsiPressed(_ sender: Any) {
        self.indexButtonsPressed(withTag: 7)
    }
    
    @IBAction func timelinePressed(_ sender: Any) {
        self.timeButtonsPressed(withTag: 11)
    }
    
    @IBAction func dayPressed(_ sender: Any) {
        self.timeButtonsPressed(withTag: 12)
    }
    
    @IBAction func weekPressed(_ sender: Any) {
        self.timeButtonsPressed(withTag: 13)
    }
    
    @IBAction func hourPressed(_ sender: Any) {
        self.timeButtonsPressed(withTag: 14)
    }
    
    @IBAction func minutePressed(_ sender: Any) {
        self.timeButtonsPressed(withTag: 15)
    }
    
    // MARK: - Public
    
    // MARK: - Private
    private func uiSetup() -> Void {
        guard self.viewModel.symbol.count > 0 else {
            InfoToast(withLocalizedTitle: "信息获取失败")
            self.pop()
            return
        }
        
        self.priceLabel.font = kThemeFontDINSmall
        self.legalPriceLabel.font = kThemeFontDINSmall
        self.rateValueLabel.font = kThemeFontDINSmall
        self.ratePercentLabel.font = kThemeFontDINSmall
        
        self.symbolLabel.text = self.viewModel.symbol
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.buttonsThemeInit()
        self.klineContainerView.addSubview(self.kline)
        self.kline.snp.makeConstraints { (make) in
            make.edges.equalTo(self.klineContainerView).inset(UIEdgeInsets(top: 20.0, left: 0, bottom: 0, right: 0))
        }
        
        // Default Index init.
        self.kline.setSerie(hidden: true, inSection: 0)
        self.kline.setSerie(hidden: false, by: CHSeriesKey.ema, inSection: 0)
        self.kline.setSerie(hidden: false, by: CHSeriesKey.candle, inSection: 0)
        
        // Push data.
        self.startReceivingLatestPriceData()
    }
    
    private func signalSetup() -> Void {
        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateTime), userInfo: nil, repeats: true)
        self.timer.fireDate = Date()
        
        self.viewModel.klineDataLoadedSignal.observeValues { [weak self] (_) in
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
            self?.startLoadingHUD(on: self?.klineContainerView, center: true, clearBg: true)
            self?.viewModel.loadKlineHistory {
                self?.stopLoadingHUD(on: self?.klineContainerView)
            }
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
