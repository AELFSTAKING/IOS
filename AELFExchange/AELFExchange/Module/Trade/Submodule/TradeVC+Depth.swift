//
//  TradeVC+Depth.swift
//  AELFExchange
//
//  Created by tng on 2019/1/25.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import Foundation
import UIKit

extension TradeVC {
    
//    @objc func depthViewSetup() -> Void {
//        // 已隐藏深度图（当前订单bottom依赖从depthContainer.bottom改为confirmButton.bottom）
//        self.depthContainerView.addSubview(self.depthChart)
//        self.depthChart.snp.makeConstraints { (make) in
//            make.left.right.bottom.equalToSuperview()
//            make.height.equalTo(self.depthContainerView.frame.height*0.8)
//        }
//        self.depthContainerView.bringSubviewToFront(self.depthPercentLabel)
//    }
    
    func updateDepthMenu() -> Void {
        self.depthButton.setTitle("\(self.viewModel.depthForMenuDisplay) ▼", for: .normal)
        self.startReceivingPushData()
    }
    
}

//extension CHKLineChartStyle {
//
//    static var defaultDepthStyle: CHKLineChartStyle = {
//
//        let style = CHKLineChartStyle()
//        //字体大小
//        style.labelFont = UIFont.systemFont(ofSize: 10)
//        //分区框线颜色
//        style.lineColor = UIColor(white: 0.7, alpha: 1)
//        //背景颜色
//        style.backgroundColor = .clear
//        //文字颜色
//        style.textColor = UIColor(white: 0.5, alpha: 1)
//        //整个图表的内边距
//        style.padding = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//        //Y轴是否内嵌式
//        style.isInnerYAxis = false
//        //Y轴显示在右边
//        style.showYAxisLabel = .none
//        //买单居右
//        style.bidChartOnDirection = .left
//        //边界宽度
//        style.borderWidth = (0, 0, 0, 0)
//        //是否允许手势点击
//        style.enableTap = false
//        //买方深度图层的颜色 UIColor(hex:0xAD6569) UIColor(hex:0x469777)
//        style.bidColor = (kThemeColorGreen, kThemeColorDepthChartGreen, 1, kThemeColorDepthChartGreenGradientEnd)
//        //买方深度图层的颜色
//        style.askColor = (kThemeColorRed, kThemeColorDepthChartRed, 1, kThemeColorDepthChartRedGradientEnd)
//        return style
//
//    }()
//}
//
//extension TradeVC: CHKDepthChartDelegate {
//
//    /// 图表的总条数
//    /// 总数 = 买方 + 卖方
//    /// - Parameter chart:
//    /// - Returns:
//    func numberOfPointsInDepthChart(chart: CHDepthChartView) -> Int {
//        return self.viewModel.depthDatas.count
//    }
//
//    /// 每个点显示的数值项
//    ///
//    /// - Parameters:
//    ///   - chart:
//    ///   - index:
//    /// - Returns:
//    func depthChart(chart: CHDepthChartView, valueForPointAtIndex index: Int) -> CHKDepthChartItem {
//        let list = self.viewModel.depthDatas
//        if index < list.count {
//            return list[index]
//        }
//        if let item = list.last {
//            return item
//        }
//        return CHKDepthChartItem()
//    }
//
//    /// y轴以基底值建立
//    ///
//    /// - Parameter depthChart:
//    /// - Returns:
//    func baseValueForYAxisInDepthChart(in depthChart: CHDepthChartView) -> Double {
//        return 0
//    }
//
//    /// y轴以基底值建立后，每次段的增量
//    ///
//    /// - Parameter depthChart:
//    /// - Returns:
//    func incrementValueForYAxisInDepthChart(in depthChart: CHDepthChartView) -> Double {
//        return self.viewModel.depthMaxAmount/4.0
//    }
//
//    /// 纵坐标值显示间距
//    func widthForYAxisLabelInDepthChart(in depthChart: CHDepthChartView) -> CGFloat {
//        return 30
//    }
//
//    /// 纵坐标值
//    func depthChart(chart: CHDepthChartView, labelOnYAxisForValue value: CGFloat) -> String {
//        if value >= 1000{
//            let newValue = value / 1000
//            return newValue.ch_toString(maxF: 0) + "K"
//        } else {
//            return value.ch_toString(maxF: 1)
//        }
//    }
//
//    /// 价格的小数位
//    func depthChartOfDecimal(chart: CHDepthChartView) -> Int {
//        return self.viewModel.currencyDecimalLenMax
//    }
//
//    /// 量的小数位
//    func depthChartOfVolDecimal(chart: CHDepthChartView) -> Int {
//        return 6 // 暂时没有用到.
//    }
//
//}
