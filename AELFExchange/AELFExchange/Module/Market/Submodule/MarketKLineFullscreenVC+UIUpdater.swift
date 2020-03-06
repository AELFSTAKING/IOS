//
//  MarketKLineFullscreenVC+UIUpdater.swift
//  AELFExchange
//
//  Created by tng on 2019/2/13.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import Foundation
import UIKit

extension MarketKLineFullscreenVC {
    
    @objc func updateTime() -> Void {
        self.dateLabel.text = timestamps().timestamp2date()
    }
    
    func indexButtonsPressed(withTag tag: Int) -> Void {
        for i in 1 ..< 8 {
            (self.indexStackView.viewWithTag(i) as! UIButton).isSelected = tag == i
        }
        
        if tag >= 1 && tag <= 3 {
            self.kline.setSerie(hidden: true, inSection: 0)
        } else {
            self.kline.setSerie(hidden: true, inSection: 1)
        }
        
        switch tag {
        case 1:
            self.kline.setSerie(hidden: false, by: CHSeriesKey.ema, inSection: 0)
        case 2:
            self.kline.setSerie(hidden: false, by: CHSeriesKey.ma, inSection: 0)
        case 3:
            self.kline.setSerie(hidden: false, by: CHSeriesKey.boll, inSection: 0)
        case 4:
            self.kline.setSerie(hidden: false, by: CHSeriesKey.volume, inSection: 1)
        case 5:
            self.kline.setSerie(hidden: false, by: CHSeriesKey.macd, inSection: 1)
        case 6:
            self.kline.setSerie(hidden: false, by: CHSeriesKey.kdj, inSection: 1)
        case 7:
            self.kline.setSerie(hidden: false, by: CHSeriesKey.rsi, inSection: 1)
        default:break
        }
        
        if self.viewModel.isTimelineMode == true {
            self.kline.setSerie(hidden: false, by: CHSeriesKey.timeline, inSection: 0)
            self.kline.setSerie(hidden: true, by: CHSeriesKey.candle, inSection: 0)
        } else {
            self.kline.setSerie(hidden: true, by: CHSeriesKey.timeline, inSection: 0)
            self.kline.setSerie(hidden: false, by: CHSeriesKey.candle, inSection: 0)
        }
        self.kline.reloadData(resetData: false)
    }
    
    func timeButtonsPressed(withTag tag: Int) -> Void {
        if tag == 11 {
            self.viewModel.isTimelineMode = true
            self.kline.setSerie(hidden: true, by: CHSeriesKey.candle, inSection: 0)
            self.kline.setSerie(hidden: false, by: CHSeriesKey.timeline, inSection: 0)
        } else {
            self.viewModel.isTimelineMode = false
            self.kline.setSerie(hidden: false, by: CHSeriesKey.candle, inSection: 0)
            self.kline.setSerie(hidden: true, by: CHSeriesKey.timeline, inSection: 0)
        }
        
        switch tag {
        case 11:
            self.viewModel.klineRange = "60000"
        case 12:
            self.viewModel.klineRange = "86400000"
        case 13:
            self.viewModel.klineRange = "604800000"
        case 14:
            // Hours.
            //
            let button = self.timeStackView.viewWithTag(tag) as! UIButton
            if !button.isSelected {
                self.viewModel.klineRange = "3600000"
            } else {
                let titles = [
                    "1\(LOCSTR(withKey: "小时").replacingOccurrences(of: "s", with: ""))",
                    "2\(LOCSTR(withKey: "小时"))",
                    "4\(LOCSTR(withKey: "小时"))",
                    "6\(LOCSTR(withKey: "小时"))",
                    "12\(LOCSTR(withKey: "小时"))"
                ]
                FTConfiguration.shared.menuWidth = 75.0
                FTConfiguration.shared.menuRowHeight = 30.0
                FTPopOverMenu.showForSender(sender:  button, with: titles, done: { [weak self] (index) in
                    button.setTitle(titles[index], for: .normal)
                    switch index {
                    case 0:
                        self?.viewModel.klineRange = "3600000"
                    case 1:
                        self?.viewModel.klineRange = "7200000"
                    case 2:
                        self?.viewModel.klineRange = "14400000"
                    case 3:
                        self?.viewModel.klineRange = "21600000"
                    case 4:
                        self?.viewModel.klineRange = "43200000"
                    default:break
                    }
                }) { FTPopOverMenu.dismiss() }
            }
        case 15:
            // Weeks.
            //
            let button = self.timeStackView.viewWithTag(tag) as! UIButton
            if !button.isSelected {
                self.viewModel.klineRange = "900000"
            } else {
                let titles = [
                    "5\(LOCSTR(withKey: "分"))",
                    "15\(LOCSTR(withKey: "分"))",
                    "30\(LOCSTR(withKey: "分"))"
                ]
                FTConfiguration.shared.menuWidth = 85.0
                FTConfiguration.shared.menuRowHeight = 30.0
                FTPopOverMenu.showForSender(sender:  button, with: titles, done: { [weak self] (index) in
                    button.setTitle(titles[index], for: .normal)
                    switch index {
                    case 0:
                        self?.viewModel.klineRange = "300000"
                    case 1:
                        self?.viewModel.klineRange = "900000"
                    case 2:
                        self?.viewModel.klineRange = "1800000"
                    default:break
                    }
                }) { FTPopOverMenu.dismiss() }
            }
        default:break
        }
        
        for i in 11 ..< 16 {
            (self.timeStackView.viewWithTag(i) as! UIButton).isSelected = tag == i
        }
    }
    
}

extension MarketKLineFullscreenVC {
    
    func buttonsThemeInit() -> Void {
        self.emaButton.setTitleColor(kThemeColorSelected, for: .selected)
        self.smaButton.setTitleColor(kThemeColorSelected, for: .selected)
        self.bollButton.setTitleColor(kThemeColorSelected, for: .selected)
        self.volButton.setTitleColor(kThemeColorSelected, for: .selected)
        self.macdButton.setTitleColor(kThemeColorSelected, for: .selected)
        self.kdjButton.setTitleColor(kThemeColorSelected, for: .selected)
        self.rsiButton.setTitleColor(kThemeColorSelected, for: .selected)
        self.timelineButton.setTitleColor(kThemeColorSelected, for: .selected)
        self.dayButton.setTitleColor(kThemeColorSelected, for: .selected)
        self.weekButton.setTitleColor(kThemeColorSelected, for: .selected)
        self.hourButton.setTitleColor(kThemeColorSelected, for: .selected)
        self.minuteButton.setTitleColor(kThemeColorSelected, for: .selected)
    }
    
}
