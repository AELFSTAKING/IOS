//
//  HomeVC.swift
//  AELFExchange
//
//  Created by tng on 2019/4/9.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import Foundation
import UIKit
import PromiseKit

class HomeVC: BaseViewController {
    
    @IBOutlet weak var navigationViewHeight: NSLayoutConstraint!
    @IBOutlet weak var navigationView: UIView! { didSet { navigationView.backgroundColor = kThemeColorBackground } }
    @IBOutlet weak var profileButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    private let bannerAndNoticeView = Bundle.main.loadNibNamed("HomeHeaderView", owner: nil, options: nil)?.first as! HomeHeaderView
    
    let viewModel = HomeViewModel()
    private var isDraggingTableView = false
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        self.isTopLevel = true
        super.viewDidLoad()
        self.uiSetup()
        self.signalSetup()
        
        // 展示静态数据.
        self.bannerAndNoticeView.noticeScrollableLabel.rollText = ["Staking Planet正式主网上线！"]
        self.bannerAndNoticeView.bannerUrls = ["home-banner-1","home-banner-2"]
        self.bannerAndNoticeView.bannerView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.viewModel.loadData()
        self.startReceivingPushData()
    }
    
    // MARK: - Custom Accessors
    
    // MARK: - IBActions
    @IBAction func profilePressed(_ sender: Any) {
        // self.push(to: MainStoryBoard.instantiateViewController(withIdentifier: "profile"), animated: true)
    }
    
    private func bannerPressed(_ index: Int) {
        guard index < self.viewModel.bannerItems.count,
            let banner = self.viewModel.bannerItems[index] as? BannerData,
            let link = banner.link,
            link.count > 0 else {
                return
        }
        let controller = JockeyWebController()
        controller.url = link
        controller.parseTitleOnWeb = true
        self.push(to: controller, animated: true)
    }
    
    private func noticePressed() {
        guard self.bannerAndNoticeView.noticeScrollableLabel.currentIndex < self.viewModel.noticeItems.count else {
            return
        }
        if  let item = self.viewModel.noticeItems[Int(self.bannerAndNoticeView.noticeScrollableLabel.currentIndex)] as? NoticeData,
            let bizid = item.bizId {
            self.startLoadingHUD(withMsg: Consts.kMsgLoading)
            let params = ["bizId":bizid]
            Network.post(withUrl: URLs.shared().genUrl(with: .noticeDetail), params: params, to: NoticeDetailResponse.self) { [weak self] (succeed, response) in
                self?.stopLoadingHUD()
                guard succeed == true, response.succeed == true else {
                    InfoToast(withLocalizedTitle: response.msg)
                    return
                }
                if let controller = self?.NoticeDetail(withTitle: response.data?.title, content: response.data?.content) {
                    self?.push(to: controller, animated: true)
                }
            }
        }
    }
    
    @objc private func noticeMorePressed() {
        self.push(to: NoticeCenterController(), animated: true)
    }
    
//    private func trendingSymbolPressed(_ data: SymbolsItem?) {
//        guard let data = data else { return }
//        self.push(to: KLineController(with: data), animated: true)
//    }
    
    private func ranklistTypePressed(_ type: HomeSymbolRankListCellType) {
        self.viewModel.symbolRankListOrderType = type
        self.viewModel.gotMarketSymbols(self.viewModel.marketItemsOriginal)
    }
    
    private func ranklistItemPressed(_ data: SymbolsItem) {
        self.push(to: KLineController(with: data), animated: true)
    }
    
//    @objc private func applicationButtonPressed(_ button: UIButton) {
//        guard Profile.shared().logined == true else {
//            self.present(LoginController(), animated: true) {}
//            return
//        }
//        if button.tag == 1 {
//            // 捕鱼.
//            ShowRiskOfGamePage {  [weak self] in
//                let controller = GameContentVC()
//                controller.showNavigationBar = false
//                controller.showMenuButton = true
//                controller.url = URLs.shared().fishingUrl()
//                self?.push(to: controller, animated: true)
//            }
//        } else if button.tag == 2 {
//            // 斗地主.
//            ShowRiskOfGamePage {  [weak self] in
//                let controller = GameContentVC()
//                controller.showNavigationBar = false
//                controller.showMenuButton = true
//                controller.url = URLs.shared().landlordUrl()
//                self?.push(to: controller, animated: true)
//            }
//        } else if button.tag == 3 {
//            // C2C.
//            let controller = JockeyWebController_Browser()
//            controller.title = "C2C"
//            controller.url = URLs.shared().c2cUrl()
//            self.push(to: controller, animated: true)
//        } else if button.tag == 4 {
//            // 理财. // 暂时改为UP+.
//            let controller = JockeyWebController_Browser()
//            controller.parseTitleOnWeb = false
//            //controller.url = URLs.shared().financialUrl()
//            controller.parseTitleOnWeb = true
//            controller.url = URLs.shared().upActivityUrl()
//            self.push(to: controller, animated: true)
//        }
//    }
//
//    private func financialItemPressed(_ data: FinancialListData) {
//        guard let url = data.productUrl else {
//            InfoToast(withLocalizedTitle: "信息有误，请重试！")
//            return
//        }
//        guard Profile.shared().logined == true else {
//            self.present(LoginController(), animated: true) {}
//            return
//        }
//        let controller = JockeyWebController_Browser()
//        controller.url = url
//        controller.title = data.productName
//        self.push(to: controller, animated: true)
//    }
    
    // MARK: - Public
    
    // MARK: - Private
    private func uiSetup() -> Void {
        navigationViewHeight.constant += CGFloat(kContentOffsetInfinityScreen)
        self.view.backgroundColor = kThemeColorBackground
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.estimatedRowHeight = 0.0
        tableView.estimatedSectionHeaderHeight = 0.0
        tableView.estimatedSectionFooterHeight = 0.0
//        tableView.register(UINib(nibName: "HomeTrendingSymbolCell", bundle: Bundle(identifier: "HomeTrendingSymbolCell")), forCellReuseIdentifier: "cell-0")
//        tableView.register(UINib(nibName: "HomeSymbolRankListCell", bundle: Bundle(identifier: "HomeSymbolRankListCell")), forCellReuseIdentifier: "cell-1")
//        tableView.register(UINib(nibName: "HomeQuickMenuCell", bundle: Bundle(identifier: "HomeQuickMenuCell")), forCellReuseIdentifier: "cell-2")
//        tableView.register(UINib(nibName: "HomeFinancialCell", bundle: Bundle(identifier: "HomeFinancialCell")), forCellReuseIdentifier: "cell-3")
        tableView.register(UINib(nibName: "HomeSymbolRankListCell", bundle: Bundle(identifier: "HomeSymbolRankListCell")), forCellReuseIdentifier: "cell-0")
        bannerAndNoticeView.delegate = self
        
    }
    
    private func signalSetup() -> Void {
        LanguageManager.shared().languageDidChangedSignal.observeValues { [weak self] (_) in
            self?.tableView.reloadData()
        }
        
        self.viewModel.bannerUpdatedSignal.observeValues { [weak self] (_) in
            guard let data = self?.viewModel.bannerUrls else { return }
            self?.bannerAndNoticeView.bannerUrls = data
            self?.bannerAndNoticeView.bannerView.reloadData()
        }
        
        self.viewModel.reactive.producer(forKeyPath: "trendingSymbolItems").take(during: self.reactive.lifetime).startWithValues { [weak self] (_) in
            self?.reloadData()
        }
        
        //self.startLoadingHUD(withMsg: nil, on: self.riseGridCollectionLoadingContainerView, center: true, clearBg: true)
        //self.viewModel.trendingSymbolUpdatedSignal.observeValues { [weak self] (_) in
            //self?.stopLoadingHUD(on: self?.riseGridCollectionLoadingContainerView)
        //}
        
        self.viewModel.reactive.producer(forKeyPath: "bannerItems").take(during: self.reactive.lifetime).startWithValues { [weak self] (data) in
            guard let data = self?.viewModel.bannerUrls else { return }
            self?.bannerAndNoticeView.bannerUrls = data
            self?.bannerAndNoticeView.bannerView.reloadData()
        }
        
        self.viewModel.reactive.producer(forKeyPath: "noticeItems").take(during: self.reactive.lifetime).startWithValues { [weak self] (_) in
            if let titles = self?.viewModel.noticeTitles {
                self?.bannerAndNoticeView.noticeScrollableLabel.rollText = titles
            }
        }
        
        self.viewModel.reactive.producer(forKeyPath: "marketItems")
            .merge(with: self.viewModel.reactive.producer(forKeyPath: "financialItems"))
            .take(during: self.reactive.lifetime)
            .startWithValues({ [weak self] (_) in
                self?.reloadData()
            })
        
        // UI Events.
        self.bannerAndNoticeView.bannerPressedCallback = { index in
            self.bannerPressed(index)
        }
        
        self.bannerAndNoticeView.noticePressedCallback = {
            self.noticePressed()
        }
        
        self.bannerAndNoticeView.moreButton.addTarget(self, action: #selector(self.noticeMorePressed), for: .touchUpInside)
    }
    
    private func reloadData() {
        guard self.isDraggingTableView == false else { return }
        self.tableView.reloadData()
    }
    
    // MARK: - Signal
    
    // MARK: - Protocol conformance
    
    // MARK: - UITextFieldDelegate
    
    // MARK: - NSCopying
    
    // MARK: - NSObject
    
}

//extension HomeVC: UIScrollViewDelegate, HomeHeaderViewDelegate, HomeTrendingSymbolCellDelegate
extension HomeVC: UIScrollViewDelegate, HomeHeaderViewDelegate {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.isDraggingTableView = true
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.isDraggingTableView = false
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.isDraggingTableView = false
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // For fixing the Scrolling Flicker bug.
//        let marketCount = min(5, self.viewModel.marketItems.count)
//        let offset = 100.0 + CGFloat(marketCount-3)*68.0
//        if scrollView.contentOffset.y+scrollView.frame.height > scrollView.contentSize.height-offset {
//            scrollView.setContentOffset(
//                CGPoint(x: scrollView.contentOffset.x,
//                        y: scrollView.contentSize.height-offset-scrollView.frame.height),
//                animated: false
//            )
//        }
    }
    
    func pagerViewWillBeginDragging() {
        self.isDraggingTableView = true
    }
    
    func pagerViewDidEndDecelerating() {
        self.isDraggingTableView = false
    }
    
//    func collectionViewWillBeginDragging() {
//        self.isDraggingTableView = true
//    }
//
//    func collectionViewDidEndDecelerating() {
//        self.isDraggingTableView = false
//    }
    
}

extension HomeVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let marketCount = min(5, self.viewModel.marketItems.count) < 3 ? 3:min(5, self.viewModel.marketItems.count)
//        switch indexPath.row {
//        case 0: return 110.0
//        case 1: return 115.0 + CGFloat(marketCount)*68.0
//        case 2: return 160.0
//        case 3: return 65.0 + CGFloat(min(3, self.viewModel.financialItems.count)+(marketCount-2))*68.0 // '+1' for fixing the Scrolling Flicker bug.
//        default: return 0.00001
//        }
        return 115.0 + CGFloat(marketCount)*68.0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let bannerHeight = CGFloat(kScreenSize.width/(345.0/160.0))
        return bannerHeight + self.bannerAndNoticeView.noticeView.frame.height
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return bannerAndNoticeView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell-\(indexPath.row)")
        cell?.selectionStyle = .none
//        switch indexPath.row {
//        case 0:
//            // Trending Symbols.
//            if  let cell = cell as? HomeTrendingSymbolCell,
//                let data = self.viewModel.trendingSymbolItems as? [SymbolsTrendingItem] {
//                cell.delegate = self
//                cell.trendingSymbolItems = data
//                cell.riseGridCollectionView.reloadData()
//                cell.itemPressedCallback = { [weak self] item in
//                    self?.trendingSymbolPressed(item)
//                }
//            }
//        case 1:
            // Rank List.
            if  let cell = cell as? HomeSymbolRankListCell,
                let data = self.viewModel.marketItems as? [SymbolsItem] {
                cell.marketItems = data
                cell.tableView.reloadData()
                cell.menuPressedCallback = { [weak self] (type) in
                    self?.ranklistTypePressed(type)
                }
                cell.itemPressedCallback = { [weak self] (item) in
                    self?.ranklistItemPressed(item)
                }
            }
//        case 2:
//            // Trending Applications.
//            if let cell = cell as? HomeQuickMenuCell {
//                cell.view.button1.addTarget(self, action: #selector(applicationButtonPressed(_:)), for: .touchUpInside)
//                cell.view.button2.addTarget(self, action: #selector(applicationButtonPressed(_:)), for: .touchUpInside)
//                cell.view.button3.addTarget(self, action: #selector(applicationButtonPressed(_:)), for: .touchUpInside)
//                cell.view.button4.addTarget(self, action: #selector(applicationButtonPressed(_:)), for: .touchUpInside)
//            }
//        case 3:
//            // Financial List.
//            if  let cell = cell as? HomeFinancialCell,
//                let data = self.viewModel.financialItems as? [FinancialListData] {
//                cell.financialItems = data
//                cell.tableView.reloadData()
//                cell.itemPressedCallback = { [weak self] data in
//                    self?.financialItemPressed(data)
//                }
//            }
//        default:break
//        }
        return cell!
    }
    
}
