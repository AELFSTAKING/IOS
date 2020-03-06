//
//  HomeTrendingSymbolCell.swift
//  AELFExchange
//
//  Created by tng on 2019/4/9.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import UIKit
import CHIPageControl

protocol HomeTrendingSymbolCellDelegate: NSObject {
    func collectionViewWillBeginDragging()
    func collectionViewDidEndDecelerating()
}

class HomeTrendingSymbolCell: UITableViewCell {
    
    weak var delegate: HomeTrendingSymbolCellDelegate?
    
    private var segmentCount = 0
    var trendingSymbolItems = [SymbolsTrendingItem]() {
        didSet {
            guard let s = pageControl else { return }
            guard trendingSymbolItems.count > 0 else {
                s.isHidden = true
                return
            }
            s.isHidden = false
            let itemCount: Float = 3.0
            let doubleValue = Float(trendingSymbolItems.count)/itemCount
            let intValue = Int(doubleValue)
            let count = doubleValue.truncatingRemainder(dividingBy: 1.0) > 0 ? intValue+1 : intValue
            self.segmentCount = count
            s.numberOfPages = count
        }
    }
    var itemPressedCallback: ((SymbolsItem?) -> ())?
    
    let riseGridCountSinglePage = 3
    @IBOutlet weak var riseGridCollectionView: UICollectionView!
    @IBOutlet weak var riseGridCollectionLoadingContainerView: UIView!
    @IBOutlet weak var sepView: UIView!
    @IBOutlet weak var pageControl: CHIPageControlJaloro! {
        didSet {
            pageControl.tintColor = ColorRGB(r: 39.0, g: 41.0, b: 73.0)
            pageControl.currentPageTintColor = ColorRGB(r: 125.0, g: 127.0, b: 145.0)
            pageControl.backgroundColor = .clear
            pageControl.hidesForSinglePage = false
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        self.bringSubviewToFront(pageControl)
        self.sepView.backgroundColor = kThemeColorSeparatorBlack
        riseGridCollectionView.isPagingEnabled = true
        riseGridCollectionView.backgroundColor = .clear
        riseGridCollectionView.clipsToBounds = false
        riseGridCollectionView.delegate = self
        riseGridCollectionView.dataSource = self
        riseGridCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}

extension HomeTrendingSymbolCell: UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.trendingSymbolItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(
            width: collectionView.frame.size.width/3.0,
            height: collectionView.frame.size.height-20.0
        )
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        let view = Bundle.main.loadNibNamed("RiseGridItemView", owner: nil, options: nil)?.first as! RiseGridItemView
        cell.addSubview(view)
        if indexPath.row < self.trendingSymbolItems.count {
            let data = self.trendingSymbolItems[indexPath.row]
            view.sync(withData: data)
        }
        view.snp.makeConstraints { (make) in
            make.edges.equalTo(cell)
        } //TODO: 临时处理办法
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.row < self.trendingSymbolItems.count, let callback = self.itemPressedCallback else {
            InfoToast(withLocalizedTitle: "信息获取失败")
            return
        }
        let item = self.trendingSymbolItems[indexPath.row]
        let data = SymbolsItem()
        data.symbol = item.symbol
        data.price = item.price
        data.quantity = item.quantity
        data.usdPrice = item.usdPrice
        data.wavePrice = item.wavePrice
        data.wavePercent = item.wavePercent
        data.direction = item.direction
        callback(data)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.delegate?.collectionViewWillBeginDragging()
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        self.updatePageControl(scrollView)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.delegate?.collectionViewDidEndDecelerating()
        self.updatePageControl(scrollView)
    }
    
    private func updatePageControl(_ scrollView: UIScrollView) {
        let width = scrollView.frame.width
        let doubleValue = Double(((CGFloat(self.segmentCount)*width)-scrollView.contentOffset.x)/width)
        let intValue = self.segmentCount-Int(doubleValue)
        self.pageControl.set(
            progress: intValue,
            animated: true
        )
    }
    
}
