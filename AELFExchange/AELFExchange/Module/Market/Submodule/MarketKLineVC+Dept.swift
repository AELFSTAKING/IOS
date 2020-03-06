//
//  MarketKLineVC+Dept.swift
//  AELFExchange
//
//  Created by tng on 2019/1/22.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import Foundation
import UIKit

extension MarketKLineVC {
    
    func depthLevelOfDelegateOrdersPressed() -> Void {
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
            self?.viewModel.depthForMenuDisplay = config.menuForDisplayObjs[index]
            self?.viewModel.depth = config.apiObjs[index]
        })
    }
    
    func depthViewSetup() -> Void {
        self.contentView.addSubview(self.depthChartContainerView)
        self.depthChartContainerView.snp.makeConstraints { (make) in
            make.top.equalTo(self.bottomSepView.snp.bottom).offset(15.0)
            make.left.right.equalTo(self.orderTableView)
            make.height.equalTo(200.0)
        }
        
        let pointLeft = UIView()
        pointLeft.backgroundColor = kThemeColorGreen
        pointLeft.addCorner(withRadius: 3.0)
        self.depthChartContainerView.addSubview(pointLeft)
        pointLeft.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.depthChartContainerView).offset(-35.0)
            make.top.equalTo(self.depthChartContainerView).offset(5.0)
            make.size.equalTo(CGSize(width: 10.0, height: 10.0))
        }
        
        let labelLeft = Label()
        labelLeft.General = "1"
        labelLeft.FontSize = "10"
        labelLeft.text = LOCSTR(withKey: "买")
        self.depthChartContainerView.addSubview(labelLeft)
        labelLeft.snp.makeConstraints { (make) in
            make.centerY.equalTo(pointLeft)
            make.left.equalTo(pointLeft.snp.right).offset(3.0)
        }
        
        let pointRight = UIView()
        pointRight.backgroundColor = kThemeColorRed
        pointRight.addCorner(withRadius: 3.0)
        self.depthChartContainerView.addSubview(pointRight)
        pointRight.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.depthChartContainerView).offset(20.0)
            make.centerY.equalTo(pointLeft)
            make.size.equalTo(pointLeft)
        }
        
        let labelRight = Label()
        labelRight.General = "1"
        labelRight.FontSize = "10"
        labelRight.text = LOCSTR(withKey: "卖")
        self.depthChartContainerView.addSubview(labelRight)
        labelRight.snp.makeConstraints { (make) in
            make.centerY.equalTo(pointRight)
            make.left.equalTo(pointRight.snp.right).offset(3.0)
        }
        
        self.depthChartContainerView.addSubview(self.depthPercentLabel)
        self.depthPercentLabel.snp.makeConstraints { (make) in
            make.top.equalTo(pointLeft.snp.bottom).offset(15.0)
            make.centerX.equalToSuperview()
        }
        
        self.depthChartContainerView.addSubview(self.depthChart)
        self.depthChart.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(self.klineContainView.frame.height*0.8)
        }
        self.depthChartContainerView.isHidden = true
    }
    
    func showDepth() -> Void {
        self.depthChartContainerView.isHidden = false
        self.orderTableViewTopOffset.constant = self.depthChartContainerView.frame.height+50.0
        self.startReceivingDepthData()
    }
    
    func hideDepth() -> Void {
        self.depthChartContainerView.isHidden = true
        self.orderTableViewTopOffset.constant = 0.0
    }
    
}

extension CHKLineChartStyle {
    
    static var defaultDepthStyle: CHKLineChartStyle = {
        
        let style = CHKLineChartStyle()
        //字体大小
        style.labelFont = UIFont.systemFont(ofSize: 10)
        //分区框线颜色
        style.lineColor = UIColor(white: 0.7, alpha: 1)
        //背景颜色
        style.backgroundColor = .clear
        //文字颜色
        style.textColor = UIColor(white: 0.5, alpha: 1)
        //整个图表的内边距
        style.padding = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        //Y轴是否内嵌式
        style.isInnerYAxis = false
        //Y轴显示在右边
        style.showYAxisLabel = .none
        //买单居右
        style.bidChartOnDirection = .left
        //边界宽度
        style.borderWidth = (0, 0, 0, 0)
        //是否允许手势点击
        style.enableTap = false
        //买方深度图层的颜色 UIColor(hex:0xAD6569) UIColor(hex:0x469777)
        style.bidColor = (kThemeColorGreen, kThemeColorDepthChartGreen, 1, kThemeColorDepthChartGreenGradientEnd)
        //买方深度图层的颜色
        style.askColor = (kThemeColorRed, kThemeColorDepthChartRed, 1, kThemeColorDepthChartRedGradientEnd)
        return style
        
    }()
}

extension MarketKLineVC: CHKDepthChartDelegate {
    
    /// 图表的总条数
    /// 总数 = 买方 + 卖方
    /// - Parameter chart:
    /// - Returns:
    func numberOfPointsInDepthChart(chart: CHDepthChartView) -> Int {
        return self.viewModel.depthDatas.count
    }
    
    /// 每个点显示的数值项
    ///
    /// - Parameters:
    ///   - chart:
    ///   - index:
    /// - Returns:
    func depthChart(chart: CHDepthChartView, valueForPointAtIndex index: Int) -> CHKDepthChartItem {
        let list = self.viewModel.depthDatas
        if index < list.count {
            return list[index]
        }
        if let item = list.last {
            return item
        }
        return CHKDepthChartItem()
    }
    
    /// y轴以基底值建立
    ///
    /// - Parameter depthChart:
    /// - Returns:
    func baseValueForYAxisInDepthChart(in depthChart: CHDepthChartView) -> Double {
        return 0
    }
    
    /// y轴以基底值建立后，每次段的增量
    ///
    /// - Parameter depthChart:
    /// - Returns:
    func incrementValueForYAxisInDepthChart(in depthChart: CHDepthChartView) -> Double {
        return self.viewModel.depthMaxAmount/4.0
    }
    
    /// 纵坐标值显示间距
    func widthForYAxisLabelInDepthChart(in depthChart: CHDepthChartView) -> CGFloat {
        return 30
    }
    
    /// 纵坐标值
    func depthChart(chart: CHDepthChartView, labelOnYAxisForValue value: CGFloat) -> String {
        if value >= 1000{
            let newValue = value / 1000
            return newValue.ch_toString(maxF: 0) + "K"
        } else {
            return value.ch_toString(maxF: 1)
        }
    }
    
    /// 价格的小数位
    func depthChartOfDecimal(chart: CHDepthChartView) -> Int {
        return self.viewModel.currencyDecimalLenMax
    }
    
    /// 量的小数位
    func depthChartOfVolDecimal(chart: CHDepthChartView) -> Int {
        return 6 // 暂时没有用到.
    }
    
}
