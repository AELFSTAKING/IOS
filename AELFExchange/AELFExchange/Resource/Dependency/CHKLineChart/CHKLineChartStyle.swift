//
//  CHKLineChartStyle.swift
//  CHKLineChart
//
//  Created by 麦志泉 on 16/9/19.
//  Copyright © 2016年 Chance. All rights reserved.
//

import Foundation
import UIKit

/// 最大最小值显示风格
///
/// - none: 不显示
/// - arrow: 箭头风格
/// - circle: 空心圆风格
/// - tag: 标签风格
public enum CHUltimateValueStyle {
    
    case none
    case arrow(UIColor)
    case circle(UIColor, Bool)
    case tag(UIColor)
}

/// 允许手势平移向上
///
/// - up: 向上
/// - down: 向下
/// - left: 向左
/// - right: 向右

public enum CHUIPanDirectionType {
    case up
    case down
    case left
    case right
}

// MARK: - 深度图表样式配置类
open class CHKLineChartStyle {
    
    /// 分区样式配置
    open var sections: [CHSection] = [CHSection]()
    
    /// 要处理的算法
    open var algorithms: [CHChartAlgorithmProtocol] = [CHChartAlgorithmProtocol]()
    
    /// 背景颜色
    open var backgroundColor: UIColor = UIColor.white
    
    /// 显示边线上左下右
    open var borderWidth: (top: CGFloat, left: CGFloat, bottom: CGFloat, right: CGFloat) = (0.5, 0.5, 0.5, 0.5)
    
    /**
     边距
     
     - returns:
     */
    open var padding: UIEdgeInsets!
    
    //字体大小
    open var labelFont: UIFont!
    
    //线条颜色
    open var lineColor: UIColor = UIColor.clear
    
    //文字颜色
    open var textColor: UIColor = UIColor.clear
    
    //选中点的显示的框背景颜色
    open var selectedBGColor: UIColor = UIColor.clear
    
    //选中点的显示的文字颜色
    open var selectedTextColor: UIColor = UIColor.clear
    
    //显示y的位置，默认右边
    open var showYAxisLabel = CHYAxisShowPosition.right
    
    /// 是否把y坐标内嵌到图表仲
    open var isInnerYAxis: Bool = false
    
    //是否可缩放
    open var enablePinch: Bool = true
    //是否可滑动
    open var enablePan: Bool = true
    //是否可点选
    open var enableTap: Bool = true
    
    /// 允许平移方向集合
    open var enblePanDirections = [CHUIPanDirectionType.up,CHUIPanDirectionType.down,CHUIPanDirectionType.left,CHUIPanDirectionType.right]
    
    /// 是否显示选中的内容
    open var showSelection: Bool = true
    
    /// 把X坐标内容显示到哪个索引分区上，默认为-1，表示最后一个，如果用户设置溢出的数值，也以最后一个
    open var showXAxisOnSection: Int = -1
    
    /// 是否显示X轴标签
    open var showXAxisLabel: Bool = true
    
    /// 是否显示所有内容
    open var isShowAll: Bool = false
    
    /// 买方深度图层颜色
    open var bidColor: (stroke: UIColor, fill: UIColor, lineWidth: CGFloat, gradientColorEnd: UIColor) = (.white, .white, 1, .white)
    
    /// 卖方深度图层颜色
    open var askColor: (stroke: UIColor, fill: UIColor, lineWidth: CGFloat, gradientColorEnd: UIColor) = (.white, .white, 1, .white)
    
    /// 买单居右
    open var bidChartOnDirection:CHKDepthChartOnDirection = .right
    
    public init() {
        
    }
}

class CHStyleParam: NSObject, Codable {
    
    var theme: String = ""   // 风格名，Dark，Light
    
    var showYAxisLabel = "Right"
    
    var candleColors = "Green/Red"
    
    var backgroundColor: UInt = 0x232732
    
    var textColor: UInt = 0xcccccc
    
    var selectedTextColor: UInt = 0xcccccc
    
    var lineColor: UInt = 0x333333
    
    var upColor: UInt = 0x00bd9a
    
    var downColor: UInt = 0xff6960
    
    var lineColors: [UInt] = [
        0xDDDDDD,
        0xF9EE30,
        0xF600FF,
        ]
    
    var isInnerYAxis: Bool = false
    
    static var defaultParam: CHStyleParam {
        let style = CHStyleParam()
        style.theme = "Dark"   // 风格名，Dark，Light
        style.candleColors = "Green/Red"
        style.showYAxisLabel = "right"
        style.isInnerYAxis = false
        style.backgroundColor = 0x232732
        style.textColor = 0xcccccc
        style.selectedTextColor = 0xcccccc
        style.lineColor = 0x333333
        style.upColor = 0x00bd9a
        style.downColor = 0xff6960
        style.lineColors = [
            0xDDDDDD,
            0xF9EE30,
            0xF600FF,
        ]
        style.isInnerYAxis = false
        return style
    }
    
    static var shared: CHStyleParam = {
        let instance = CHStyleParam.loadUserData()
        return instance
    }()
    
    /// 读取用户风格配置
    ///
    /// - Returns:
    static func loadUserData() -> CHStyleParam {
        
        guard let json = UserDefaults.standard.value(forKey: "StyleParam") as? String else {
            return CHStyleParam.defaultParam
        }
        
        guard let jsonData = json.data(using: String.Encoding.utf8) else {
            return CHStyleParam.defaultParam
        }
        
        let jsonDecoder = JSONDecoder()
        do {
            let sp = try jsonDecoder.decode(CHStyleParam.self, from: jsonData)
            return sp
        } catch _ {
            return CHStyleParam.defaultParam
        }
    }
    
    /// 重置为默认
    static func resetDefault() {
        CHStyleParam.shared = CHStyleParam.defaultParam
        _ = CHStyleParam.shared.saveUserData()
    }
    
    /// 保存用户设置指标数据
    ///
    /// - Parameter data:
    /// - Returns:
    func saveUserData() -> Bool {
        
        let jsonEncoder = JSONEncoder()
        do {
            let jsonData = try jsonEncoder.encode(self)
            let jsonString = String(data: jsonData, encoding: .utf8)
            UserDefaults.standard.set(jsonString, forKey: "StyleParam")
            UserDefaults.standard.synchronize()
            return true
        } catch _ {
            return false
        }
    }
}


// MARK: - 扩展样式
public extension CHKLineChartStyle {
    
    //实现一个自定义的明亮风格样式，开发者可以自由扩展配置样式
    public static var customLight: CHKLineChartStyle {
        
        /*** 明亮风格 ***/
        
        let style = CHKLineChartStyle()
        //字体大小
        style.labelFont = UIFont.systemFont(ofSize: 10)
        //分区框线颜色
        style.lineColor = UIColor.clear
        //选中价格显示的背景颜色
        style.selectedBGColor = UIColor(white: 0.4, alpha: 1)
        //文字颜色
        style.textColor = UIColor(white: 0.5, alpha: 1)
        //背景颜色
        style.backgroundColor = UIColor.white
        //选中点的显示的文字颜色
        style.selectedTextColor = UIColor(white: 0.8, alpha: 1)
        //整个图表的内边距
        style.padding = UIEdgeInsets(top: 0, left: 2, bottom: 0, right: 2)
        //Y轴是否内嵌式
        style.isInnerYAxis = true
        //显示X轴坐标内容在哪个分区仲
        style.showXAxisOnSection = 0
        //Y轴显示在右边
        style.showYAxisLabel = .right
        
        
        //配置图表处理算法
        style.algorithms = [
            CHChartAlgorithm.timeline,
            CHChartAlgorithm.ma(5),
            CHChartAlgorithm.ma(10),
            CHChartAlgorithm.ma(30),
            CHChartAlgorithm.ema(5),
            CHChartAlgorithm.ema(10),
            CHChartAlgorithm.ema(12),       //计算MACD，必须先计算到同周期的EMA
            CHChartAlgorithm.ema(26),       //计算MACD，必须先计算到同周期的EMA
            CHChartAlgorithm.ema(30),
            CHChartAlgorithm.macd(12, 26, 9),
            CHChartAlgorithm.kdj(9, 3, 3),
            CHChartAlgorithm.rsi(6),
            CHChartAlgorithm.rsi(12),
            CHChartAlgorithm.rsi(24)
        ]
        
        //分区点线样式
        //表示上涨的颜色
        let upcolor = (UIColor.ch_hex(0x5BA267), true)
        //表示下跌的颜色
        let downcolor = (UIColor.ch_hex(0xB1414C), true)
        let priceSection = CHSection()
        priceSection.backgroundColor = style.backgroundColor
        //分区上显示选中点的数据文字是否在分区外显示
        priceSection.titleShowOutSide = false
        //是否显示选中点的数据文字
        priceSection.showTitle = false
        //分区的类型
        priceSection.valueType = .master
        //分区唯一键值
        priceSection.key = "price"
        //是否隐藏分区
        priceSection.hidden = false
        //分区所占图表的比重，0代表不使用比重，采用固定高度
        priceSection.ratios = 0
        //分区采用固定高度
        priceSection.fixHeight = 176
        //Y轴辅助线的样式，实线
        priceSection.yAxis.referenceStyle = .none
        //分区内边距
        priceSection.padding = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
        
        /// 时分线
        let timelineSeries = CHSeries.getTimelinePrice(
            color: UIColor.ch_hex(0xAE475C),
            section: priceSection,
            showGuide: true,
            ultimateValueStyle: .circle(UIColor.ch_hex(0xAE475C), true),
            lineWidth: 2)
        
        timelineSeries.hidden = true
        
        
        let maColor = [
            UIColor.ch_hex(0x4E9CC1),
            UIColor.ch_hex(0xF7A23B),
            UIColor.ch_hex(0xF600FF),
            ]
        
        /// 蜡烛线
        let priceSeries = CHSeries.getCandlePrice(
            upStyle: upcolor,
            downStyle: downcolor,
            titleColor: UIColor(white: 0.5, alpha: 1),
            section: priceSection,
            showGuide: true,
            ultimateValueStyle: .arrow(UIColor(white: 0.5, alpha: 1)))
        
        //MA线
        let priceMASeries = CHSeries.getPriceMA(
            isEMA: false,
            num: [5,10,30],
            colors:maColor,
            section: priceSection)
        
        priceMASeries.hidden = false
        
        //EMA线
        let priceEMASeries = CHSeries.getPriceMA(
            isEMA: true,
            num: [5,10,30],
            colors: maColor,
            section: priceSection)
        
        priceEMASeries.hidden = true
        priceSection.series = [timelineSeries, priceSeries, priceMASeries, priceEMASeries]
        
        //交易量柱形线
        let volumeSection = CHSection()
        volumeSection.backgroundColor = style.backgroundColor
        //分区的类型
        volumeSection.valueType = .assistant
        //分区唯一键值
        volumeSection.key = "volume"
        volumeSection.hidden = false
        volumeSection.showTitle = false
        volumeSection.ratios = 1
        volumeSection.yAxis.referenceStyle = .none
        volumeSection.yAxis.tickInterval = 2
        volumeSection.padding = UIEdgeInsets(top: 10, left: 0, bottom: 4, right: 0)
        let volumeSeries = CHSeries.getDefaultVolume(upStyle: upcolor, downStyle: downcolor, section: volumeSection)
        let volumeMASeries = CHSeries.getVolumeMA(
            isEMA: false,
            num: [5,10,30],
            colors: maColor, section:
            volumeSection)
        
        let volumeEMASeries = CHSeries.getVolumeMA(
            isEMA: true,
            num: [5,10,30],
            colors: maColor,
            section: volumeSection)
        
        volumeEMASeries.hidden = true
        volumeSection.series = [volumeSeries, volumeMASeries, volumeEMASeries]
        
        let trendSection = CHSection()
        trendSection.backgroundColor = style.backgroundColor
        //分区的类型
        trendSection.valueType = .assistant
        //分区唯一键值
        trendSection.key = "analysis"
        trendSection.hidden = false
        trendSection.showTitle = false
        trendSection.ratios = 1
        trendSection.paging = true
        trendSection.yAxis.referenceStyle = .none
        trendSection.yAxis.tickInterval = 2
        trendSection.padding = UIEdgeInsets(top: 10, left: 0, bottom: 8, right: 0)
        let kdjSeries = CHSeries.getKDJ(UIColor.ch_hex(0xDDDDDD),
                                        dc: UIColor.ch_hex(0xF9EE30),
                                        jc: UIColor.ch_hex(0xF600FF),
                                        section: trendSection)
        
        kdjSeries.title = "KDJ(9,3,3)"
        
        let macdSeries = CHSeries.getMACD(UIColor.ch_hex(0xDDDDDD),
                                          deac: UIColor.ch_hex(0xF9EE30),
                                          barc: UIColor.ch_hex(0xF600FF),
                                          upStyle: upcolor, downStyle: downcolor,
                                          section: trendSection)
        macdSeries.title = "MACD(12,26,9)"
        macdSeries.symmetrical = true
        trendSection.series = [
            macdSeries,
            kdjSeries,
        ]
        
        style.sections = [priceSection, volumeSection, trendSection]
        
        return style
    }
    
    //实现一个暗黑风格的样式，开发者可以自由扩展配置样式
    public static var customDark: CHKLineChartStyle {
        
        /*** 暗黑风格 ***/
        
        let style = CHKLineChartStyle()
        //字体大小
        style.labelFont = UIFont.systemFont(ofSize: 10)
        //分区框线颜色
        style.lineColor = UIColor.clear
        //选中价格显示的背景颜色
        style.selectedBGColor = UIColor(white: 0.4, alpha: 1)
        //文字颜色
        style.textColor = UIColor(white: 0.8, alpha: 1)
        //背景颜色
        style.backgroundColor = UIColor.ch_hex(0x1D1C1C)
        //选中点的显示的文字颜色
        style.selectedTextColor = UIColor(white: 0.8, alpha: 1)
        //整个图表的内边距
        style.padding = UIEdgeInsets(top: 0, left: 2, bottom: 0, right: 2)
        //Y轴是否内嵌式
        style.isInnerYAxis = true
        //显示X轴坐标内容在哪个分区仲
        style.showXAxisOnSection = 0
        //Y轴显示在右边
        style.showYAxisLabel = .right
        
        
        //配置图表处理算法
        style.algorithms = [
            CHChartAlgorithm.timeline,
            CHChartAlgorithm.ma(5),
            CHChartAlgorithm.ma(10),
            CHChartAlgorithm.ma(30),
            CHChartAlgorithm.ema(5),
            CHChartAlgorithm.ema(10),
            CHChartAlgorithm.ema(12),       //计算MACD，必须先计算到同周期的EMA
            CHChartAlgorithm.ema(26),       //计算MACD，必须先计算到同周期的EMA
            CHChartAlgorithm.ema(30),
            CHChartAlgorithm.macd(12, 26, 9),
            CHChartAlgorithm.kdj(9, 3, 3),
        ]
        
        //分区点线样式
        //表示上涨的颜色
        let upcolor = (UIColor.ch_hex(0x5BA267), true)
        //表示下跌的颜色
        let downcolor = (UIColor.ch_hex(0xB1414C), true)
        let priceSection = CHSection()
        priceSection.backgroundColor = style.backgroundColor
        //分区上显示选中点的数据文字是否在分区外显示
        priceSection.titleShowOutSide = false
        //是否显示选中点的数据文字
        priceSection.showTitle = false
        //分区的类型
        priceSection.valueType = .master
        //分区唯一键值
        priceSection.key = "price"
        //是否隐藏分区
        priceSection.hidden = false
        //分区所占图表的比重，0代表不使用比重，采用固定高度
        priceSection.ratios = 0
        //Y轴辅助线的样式，实线
        priceSection.yAxis.referenceStyle = .none
        
        priceSection.yAxis.tickInterval = 3
        //分区采用固定高度
        priceSection.fixHeight = 176
        //分区内边距
        priceSection.padding = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
        
        /// 时分线
        let timelineSeries = CHSeries.getTimelinePrice(
            color: UIColor.ch_hex(0xAE475C),
            section: priceSection,
            showGuide: true,
            ultimateValueStyle: .circle(UIColor.ch_hex(0xAE475C), true),
            lineWidth: 2)
        
        timelineSeries.hidden = true
        
        
        let maColor = [
            UIColor.ch_hex(0xDDDDDD),
            UIColor.ch_hex(0xF9EE30),
            UIColor.ch_hex(0xF600FF),
            ]
        
        /// 蜡烛线
        let priceSeries = CHSeries.getCandlePrice(
            upStyle: upcolor,
            downStyle: downcolor,
            titleColor: UIColor(white: 0.5, alpha: 1),
            section: priceSection,
            showGuide: true,
            ultimateValueStyle: .tag(UIColor.white))
        
        //MA线
        let priceMASeries = CHSeries.getPriceMA(
            isEMA: false,
            num: [5,10,30],
            colors:maColor,
            section: priceSection)
        
        priceMASeries.hidden = false
        
        //EMA线
        let priceEMASeries = CHSeries.getPriceMA(
            isEMA: true,
            num: [5,10,30],
            colors: maColor,
            section: priceSection)
        
        priceEMASeries.hidden = true
        priceSection.series = [timelineSeries, priceSeries, priceMASeries, priceEMASeries]
        
        //交易量柱形线
        let volumeSection = CHSection()
        volumeSection.backgroundColor = style.backgroundColor
        //分区的类型
        volumeSection.valueType = .assistant
        //分区唯一键值
        volumeSection.key = "volume"
        volumeSection.hidden = false
        volumeSection.showTitle = false
        volumeSection.ratios = 1
        volumeSection.yAxis.referenceStyle = .none
        volumeSection.yAxis.tickInterval = 1
        volumeSection.padding = UIEdgeInsets(top: 10, left: 0, bottom: 4, right: 0)
        let volumeSeries = CHSeries.getDefaultVolume(upStyle: upcolor, downStyle: downcolor, section: volumeSection)
        let volumeMASeries = CHSeries.getVolumeMA(
            isEMA: false,
            num: [5,10,30],
            colors: maColor,
            section: volumeSection)
        
        let volumeEMASeries = CHSeries.getVolumeMA(
            isEMA: true,
            num: [5,10,30],
            colors: maColor,
            section: volumeSection)
        
        volumeEMASeries.hidden = true
        volumeSection.series = [volumeSeries, volumeMASeries, volumeEMASeries]
        
        let trendSection = CHSection()
        trendSection.backgroundColor = style.backgroundColor
        //分区的类型
        trendSection.valueType = .assistant
        //分区唯一键值
        trendSection.key = "analysis"
        trendSection.hidden = false
        trendSection.showTitle = false
        trendSection.ratios = 1
        trendSection.paging = true
        trendSection.yAxis.referenceStyle = .none
        trendSection.yAxis.tickInterval = 2
        trendSection.padding = UIEdgeInsets(top: 10, left: 0, bottom: 8, right: 0)
        let kdjSeries = CHSeries.getKDJ(UIColor.ch_hex(0xDDDDDD),
                                        dc: UIColor.ch_hex(0xF9EE30),
                                        jc: UIColor.ch_hex(0xF600FF),
                                        section: trendSection)
        
        kdjSeries.title = "KDJ(9,3,3)"
        
        let macdSeries = CHSeries.getMACD(UIColor.ch_hex(0xDDDDDD),
                                          deac: UIColor.ch_hex(0xF9EE30),
                                          barc: UIColor.ch_hex(0xF600FF),
                                          upStyle: (UIColor.ch_hex(0x5BA267), false), downStyle: downcolor,
                                          section: trendSection)
        macdSeries.title = "MACD(12,26,9)"
        macdSeries.symmetrical = true
        trendSection.series = [
            macdSeries,
            kdjSeries,
        ]
        
        style.sections = [priceSection, volumeSection, trendSection]
        
        
        return style
    }
    
    
    
    //实现一个暗黑风格的点线简单图表
    public static var simpleLineDark: CHKLineChartStyle {
        
        /*** 暗黑风格 ***/
        
        let style = CHKLineChartStyle()
        //字体大小
        style.labelFont = UIFont.systemFont(ofSize: 10)
        //分区框线颜色
        style.lineColor = UIColor.clear
        //选中价格显示的背景颜色
        style.selectedBGColor = UIColor(white: 0.4, alpha: 1)
        //文字颜色
        style.textColor = UIColor.ch_hex(0x8D7B62, alpha: 0.44)
        //背景颜色
        style.backgroundColor = UIColor.ch_hex(0x383D49)
        //选中点的显示的文字颜色
        style.selectedTextColor = UIColor(white: 0.8, alpha: 1)
        //整个图表的内边距
        style.padding = UIEdgeInsets(top: 0, left: 2, bottom: 0, right: 2)
        //Y轴是否内嵌式
        style.isInnerYAxis = true
        //显示X轴坐标内容在哪个分区仲
        style.showXAxisOnSection = 0
        //Y轴显示在右边
        style.showYAxisLabel = .left
        //是否把所有点都显示
        style.isShowAll = true
        //禁止所有手势操作
        style.enablePan = false
        style.enableTap = false
        style.enablePinch = false
        
        
        //配置图表处理算法
        style.algorithms = [
            CHChartAlgorithm.timeline
        ]
        
        let priceSection = CHSection()
        priceSection.backgroundColor = style.backgroundColor
        //分区上显示选中点的数据文字是否在分区外显示
        priceSection.titleShowOutSide = false
        //是否显示选中点的数据文字
        priceSection.showTitle = false
        //分区的类型
        priceSection.valueType = .master
        //分区唯一键值
        priceSection.key = "price"
        //是否隐藏分区
        priceSection.hidden = false
        //分区所占图表的比重，0代表不使用比重，采用固定高度
        priceSection.ratios = 1
        //Y轴隔间数
        priceSection.yAxis.tickInterval = 2
        //Y轴辅助线的样式，实线
        priceSection.yAxis.referenceStyle = .solid(color: UIColor.ch_hex(0x8D7B62, alpha: 0.44))
        //分区内边距
        priceSection.padding = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
        
        /// 时分线
        let timelineSeries = CHSeries.getTimelinePrice(
            color: UIColor.ch_hex(0xAE475C),
            section: priceSection,
            showGuide: true,
            ultimateValueStyle: .circle(UIColor.ch_hex(0xAE475C), true),
            lineWidth: 2)
        
        priceSection.series = [timelineSeries]
        
        style.sections = [priceSection]
        
        
        return style
    }
    
}
