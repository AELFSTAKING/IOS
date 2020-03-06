//
//  HomeHeaderView.swift
//  AELFExchange
//
//  Created by tng on 2019/4/9.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import Foundation
import UIKit
import FSPagerView
import Kingfisher

protocol HomeHeaderViewDelegate: NSObject {
    func pagerViewWillBeginDragging()
    func pagerViewDidEndDecelerating()
}

class HomeHeaderView: UIView {
    
    weak var delegate: HomeHeaderViewDelegate?
    
    var bannerUrls = [String]()
    var bannerPressedCallback: ((Int) -> ())?
    var noticePressedCallback: (() -> ())?
    
    let bannerCellID = "banner-cell"
    @IBOutlet weak var bannerView: FSPagerView! {
        didSet {
            bannerView.backgroundColor = .clear
            bannerView.transformer = FSPagerViewTransformer(type: .zoomOut)
            bannerView.register(FSPagerViewCell.self, forCellWithReuseIdentifier: bannerCellID)
            bannerView.delegate = self
            bannerView.dataSource = self
        }
    }
    @IBOutlet weak var noticeScrollableLabel: ScrollableLabel! {
        didSet {
            noticeScrollableLabel.font = kThemeFontNormal
            noticeScrollableLabel.textColor = kThemeColorTextNormal
            noticeScrollableLabel.clipsToBounds = true
            noticeScrollableLabel.isUserInteractionEnabled = true
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.noticePressed))
            noticeScrollableLabel.addGestureRecognizer(tap)
        }
    }
    @IBOutlet weak var noticeView: UIView!
    @IBOutlet weak var moreButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.noticeView.clipsToBounds = true
        self.moreButton.setTitleColor(ColorRGBA(r: 125.0, g: 127.0, b: 145.0, a: 1.0), for: .normal)
        
        LanguageManager.shared().languageDidChangedSignal.observeValues { [weak self] (_) in
            self?.moreButton.setTitle(LOCSTR(withKey: "更多"), for: .normal)
        }
    }
    
    @objc func noticePressed() {
        if let callback = self.noticePressedCallback {
            callback()
        }
    }
    
}

extension HomeHeaderView: FSPagerViewDelegate, FSPagerViewDataSource {
    
    func numberOfItems(in pagerView: FSPagerView) -> Int {
        return self.bannerUrls.count
    }
    
    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: bannerCellID, at: index)
        cell.imageView?.contentMode = .scaleToFill
        cell.addCorner(withRadius: 10.0)
//        if let url = URL(string: self.bannerUrls[index]) {
//            cell.imageView?.kf.setImage(with: ImageResource(downloadURL: url))
//        }
        cell.imageView?.image = UIImage(named: self.bannerUrls[index])
        return cell
    }
    
    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        guard index < self.bannerUrls.count, let callback = self.bannerPressedCallback else {
            return
        }
        callback(index)
    }
    
    func pagerViewWillBeginDragging(_ pagerView: FSPagerView) {
        self.delegate?.pagerViewWillBeginDragging()
    }
    
    func pagerViewDidEndDecelerating(_ pagerView: FSPagerView) {
        self.delegate?.pagerViewDidEndDecelerating()
    }
    
}
