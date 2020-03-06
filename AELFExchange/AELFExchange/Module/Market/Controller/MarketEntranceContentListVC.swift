//
//  MarketEntranceContentListVC.swift
//  AELFExchange
//
//  Created by tng on 2019/7/16.
//  Copyright © 2019 cex.io. All rights reserved.
//

import Foundation
import DZNEmptyDataSet

class MarketEntranceContentListVC: BaseViewController {
    
    var didSelectedSymbolCallback: ((SymbolsItem) -> ())?
    var didPressedGoColelctCallback: (() -> ())?
    let viewModel = MarketEntranceContentListViewModel()
    var isSelector = false
    
    private let headerHeight: CGFloat = 40.0
    private var isDraggingTableView = false
    
    lazy var tableView: UITableView = {
        let t = UITableView(frame: .zero, style: .plain)
        t.tableFooterView = UIView()
        t.separatorInset = .zero
        t.separatorColor = kThemeColorSeparator
        t.bounces = false
        t.delegate = self
        t.dataSource = self
        t.emptyDataSetSource = self
        t.emptyDataSetDelegate = self
        return t
    }()
    private let marketListHeader = Bundle.main.loadNibNamed("MarketListHeaderView", owner: nil, options: nil)?.first as! MarketListHeaderView
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.uiSetup()
        self.signalSetup()
        self.viewModel.load()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.startReceivingPushData()
    }
    
    // MARK: - Custom Accessors
    
    // MARK: - IBActions
    
    // MARK: - Public
    
    // MARK: - Private
    private func uiSetup() -> Void {
        self.view.addSubview(self.tableView)
        self.tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        self.tableView.register(UINib(nibName: "MarketHomeCell", bundle: Bundle(identifier: "MarketHomeCell")), forCellReuseIdentifier: "cell")
    }
    
    private func signalSetup() -> Void {
        self.viewModel.loadedSignal.observeValues { [weak self] (_) in
            self?.tableView.reloadData()
        }
    }
    
    private func collectPressed(withButton button: UIButton, symbol: String) {
        guard self.isSelector, !symbol.isEmpty else { return }
        button.isSelected.toggle()
        let colleceted = DB.shared().isSymbolCollected(for: symbol)
        DB.shared().symbolCollect(forCollect: !colleceted, symbol: symbol)
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

extension MarketEntranceContentListVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.data.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70.0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return headerHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        self.marketListHeader.label3.text = LOCSTR(withKey: self.isSelector ? "收藏":"24H涨跌")
        self.marketListHeader.titleSetup(forSelectorMode: self.isSelector)
        return self.marketListHeader
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        cell?.selectionStyle = .none
        if let cell = cell as? MarketHomeCell {
            if  indexPath.row < self.viewModel.data.count,
                let dataObj = self.viewModel.data[indexPath.row] as? SymbolsItem {
                cell.pressedCollectCallback = { [weak self] (symbol, button) in
                    self?.collectPressed(withButton: button, symbol: symbol)
                }
                cell.sync(with: dataObj, indexPath: indexPath, mode: (self.isSelector ? .selector:.fullDisplay))
            }
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard indexPath.row < self.viewModel.data.count, let dataObj = self.viewModel.data[indexPath.row] as? SymbolsItem else {
            return
        }
        if let callback = self.didSelectedSymbolCallback {
            let item = SymbolsItem()
            item.isShow = dataObj.isShow
            item.symbol = dataObj.symbol
            item.highestPrice = dataObj.highestPrice
            item.highestUsdPrice = dataObj.highestUsdPrice
            item.lowestPrice = dataObj.lowestPrice
            item.lowestUsdPrice = dataObj.lowestUsdPrice
            item.lastPrice = dataObj.lastPrice
            item.lastUsdPrice = dataObj.lastUsdPrice
            item.quantity = dataObj.quantity
            item.wavePrice = dataObj.wavePrice
            item.wavePercent = dataObj.wavePercent
            callback(item)
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.isDraggingTableView = true
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.isDraggingTableView = false
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.isDraggingTableView = false
    }
    
}

extension MarketEntranceContentListVC: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    
    func verticalOffset(forEmptyDataSet scrollView: UIScrollView!) -> CGFloat {
        return -35.0
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "icon-empty-noitem")!
    }
    
    func buttonTitle(forEmptyDataSet scrollView: UIScrollView!, for state: UIControl.State) -> NSAttributedString! {
        if !self.viewModel.doNotShowAddButton {
            return NSAttributedString(string: "＋添加自选", attributes: [
                NSAttributedString.Key.foregroundColor : kThemeColorTextNormal,
                NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14.0, weight: .medium)
                ])
        } else {
            return NSAttributedString(string: "暂无记录~", attributes: [
                NSAttributedString.Key.foregroundColor : kThemeColorTextUnabled,
                NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14.0, weight: .medium)
                ])
        }
    }
    
    func emptyDataSet(_ scrollView: UIScrollView!, didTap button: UIButton!) {
        if self.viewModel.doNotShowAddButton == false, let callback = self.didPressedGoColelctCallback {
            callback()
        }
    }
    
//    func customView(forEmptyDataSet scrollView: UIScrollView!) -> UIView! {
//        let view = UIView()
//        view.isUserInteractionEnabled = false
//        let image = UIImageView(image: UIImage(named: "icon-empty-noitem"))
//        image.contentMode = .scaleAspectFit
//        view.addSubview(image)
//        image.snp.makeConstraints { (make) in
//            make.center.equalToSuperview()
//            make.size.equalTo(CGSize(width: 130.0, height: 108.0))
//        }
//
//        let button = UIButton(type: .custom)
//        button.titleLabel?.font = UIFont.systemFont(ofSize: 14.0, weight: .medium)
//        button.setTitleColor(kThemeColorTextNormal, for: .normal)
//        button.setTitle(LOCSTR(withKey: "添加自选"), for: .normal)
//        button.imageView?.contentMode = .scaleAspectFit
//        button.setImage(UIImage(named: "icon-mk-add"), for: .normal)
//        button.backgroundColor = kThemeColorSeparator
//        button.addCorner(withRadius: 2.0)
//        button.tag = 1
//        view.addSubview(button)
//        button.snp.makeConstraints { (make) in
//            make.top.equalTo(image.snp.bottom).offset(30.0)
//            make.centerX.equalToSuperview()
//            make.size.equalTo(CGSize(width: 130.0, height: 40.0))
//        }
//        return view
//    }
    
}
