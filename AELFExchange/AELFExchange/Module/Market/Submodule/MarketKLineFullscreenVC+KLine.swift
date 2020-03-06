//
//  MarketKLineFullscreenVC+KLine.swift
//  AELFExchange
//
//  Created by tng on 2019/2/13.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import Foundation
import UIKit

extension MarketKLineFullscreenVC: CHKLineChartDelegate {
    
    func klineStyle() -> CHKLineChartStyle {
        
        let seriesParams = SeriesParamList.shared.loadUserData()
        let styleParam = CHStyleParam.shared
        styleParam.showYAxisLabel = "Left"
        
        let style = CHKLineChartStyle()
        style.labelFont = UIFont.systemFont(ofSize: 10)
        style.lineColor = UIColor(hex: styleParam.lineColor)
        style.textColor = UIColor(hex: styleParam.textColor)
        style.selectedBGColor = UIColor(white: 0.2, alpha: 1)
        style.selectedTextColor = UIColor(hex: styleParam.selectedTextColor)
        style.backgroundColor = kThemeColorBackground
        style.isInnerYAxis = styleParam.isInnerYAxis
        style.padding = .zero
        
        if styleParam.showYAxisLabel == "Left" {
            style.showYAxisLabel = .left
        } else if styleParam.showYAxisLabel == "Right" {
            style.showYAxisLabel = .right
        } else {
            style.showYAxisLabel = .none
        }
        
        style.algorithms.append(CHChartAlgorithm.timeline)
        
        /************** 配置分区样式 **************/
        
        /// 主图.
        let upcolor = (kThemeColorGreen, true)
        let downcolor = (kThemeColorRed, true)
        let priceSection = CHSection()
        priceSection.backgroundColor = style.backgroundColor
        priceSection.titleShowOutSide = true
        priceSection.valueType = .master
        priceSection.key = "master"
        priceSection.hidden = false
        priceSection.ratios = 3
        priceSection.yAxis.tickInterval = 2
        priceSection.padding = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
        
        
        /// 副图1.
        let assistSection1 = CHSection()
        assistSection1.backgroundColor = style.backgroundColor
        assistSection1.valueType = .assistant
        assistSection1.key = "assist1"
        assistSection1.hidden = false
        assistSection1.ratios = 2 // 暂时增加此副图显示比例,因为:非全屏模式不展示第二个副图.
        assistSection1.paging = true
        assistSection1.yAxis.tickInterval = 1
        assistSection1.padding = UIEdgeInsets(top: 16, left: 0, bottom: 8, right: 0)
        
        /// 副图2.
        let assistSection2 = CHSection()
        assistSection2.backgroundColor = style.backgroundColor
        assistSection2.valueType = .assistant
        assistSection2.key = "assist2"
        assistSection2.hidden = true // 全屏模式不展示第二个副图.
        assistSection2.ratios = 1
        assistSection2.paging = true
        assistSection2.yAxis.tickInterval = 1
        assistSection2.padding = UIEdgeInsets(top: 16, left: 0, bottom: 8, right: 0)
        
        /************** 添加主图固定的线段 **************/
        
        /// 时分线.
        let timelineSeries = CHSeries.getTimelinePrice(
            color: UIColor.ch_hex(0xAE475C),
            section: priceSection,
            showGuide: true,
            ultimateValueStyle: .circle(UIColor.ch_hex(0xAE475C), true),
            lineWidth: 2.0
        )
        
        timelineSeries.hidden = true
        
        /// 蜡烛线.
        let priceSeries = CHSeries.getCandlePrice(
            upStyle: upcolor,
            downStyle: downcolor,
            titleColor: UIColor(white: 0.8, alpha: 1),
            section: priceSection,
            showGuide: true,
            ultimateValueStyle: .arrow(UIColor(white: 0.8, alpha: 1)))
        
        priceSeries.showTitle = true
        priceSeries.chartModels.first?.ultimateValueStyle = .arrow(UIColor(white: 0.8, alpha: 1))
        
        priceSection.series.append(timelineSeries)
        priceSection.series.append(priceSeries)
        
        /************** 读取用户配置中线段 **************/
        /*
         MA、EMA、BOLL、SAR、SAM、KDJ、MACD、RSI
         */
        for series in seriesParams {
            if series.hidden {
                continue
            }
            
            // 添加指标算法.
            style.algorithms.append(contentsOf: series.getAlgorithms())
            
            // 添加指标线段.
            series.appendIn(masterSection: priceSection, assistSections: assistSection1, assistSection2)
        }
        
        style.sections.append(priceSection)
        if assistSection1.series.count > 0 {
            style.sections.append(assistSection1)
        }
        
        if assistSection2.series.count > 0 {
            style.sections.append(assistSection2)
        }
        
        return style
    }
    
    func numberOfPointsInKLineChart(chart: CHKLineChartView) -> Int {
        return self.viewModel.klineData.count
    }
    
    func kLineChart(chart: CHKLineChartView, valueForPointAtIndex index: Int) -> CHChartItem {
        guard index < self.viewModel.klineData.count, let data = self.viewModel.klineData[index] as? CHChartItem else {
            return CHChartItem()
        }
        return data
    }
    
    func kLineChart(chart: CHKLineChartView, labelOnYAxisForValue value: CGFloat, atIndex index: Int, section: CHSection) -> String {
        var strValue = ""
        if section.valueType == .assistant {
            if value/1000 > 1 {
                strValue = (value/1000).ch_toString(maxF: 0) + "K"
            } else {
                strValue = value.ch_toString(maxF: 0)
            }
        } else {
            strValue = value.ch_toString(maxF: section.decimal)
        }
        return strValue
    }
    
    func kLineChart(chart: CHKLineChartView, labelOnXAxisForIndex index: Int) -> String {
        guard index < self.viewModel.klineData.count, let data = self.viewModel.klineData[index] as? CHChartItem else {
            return "-"
        }
        return Date.ch_getTimeByStamp(data.time, format: "HH:mm")
    }
    
    func kLineChart(chart: CHKLineChartView, decimalAt section: Int) -> Int {
        return 4 // TODO: 暂时固定小数位数.
    }
    
    func kLineChart(chart: CHKLineChartView, positionDidChanged toPosition: CHChartViewEdgePosition) {
        self.viewModel.isKlineRightEdge = toPosition == .right
    }
    
}
