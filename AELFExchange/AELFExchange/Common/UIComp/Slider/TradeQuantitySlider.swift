//
//  TradeQuantitySlider.swift
//  AELFExchange
//
//  Created by tng on 2019/5/21.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import Foundation
import UIKit

class TradeQuantitySlider: UIView {
    
    var valueChangedCallback: ((Float) -> ())?
    
    private var isModeBuy = true
    private var currentColor = kThemeColorGreen
    
    @IBOutlet weak var view1: UIView!
    @IBOutlet weak var point1L: UIButton!
    @IBOutlet weak var point1R: UIButton!
    @IBOutlet weak var sliderBg1: UIProgressView!
    
    @IBOutlet weak var view2: UIView!
    @IBOutlet weak var point2: UIButton!
    @IBOutlet weak var sliderBg2: UIProgressView!
    
    @IBOutlet weak var view3: UIView!
    @IBOutlet weak var point3: UIButton!
    @IBOutlet weak var sliderBg3: UIProgressView!
    
    @IBOutlet weak var view4: UIView!
    @IBOutlet weak var point4: UIButton!
    @IBOutlet weak var sliderBg4: UIProgressView!
    
    lazy var percentLabel0: UILabel = {
        let l = UILabel()
        l.textColor = kThemeColorTextUnabled
        l.font = UIFont.systemFont(ofSize: 11.0)
        l.text = "0%"
        return l
    }()
    lazy var percentLabel25: UILabel = {
        let l = UILabel()
        l.textColor = kThemeColorTextUnabled
        l.font = UIFont.systemFont(ofSize: 11.0)
        l.text = "25%"
        return l
    }()
    lazy var percentLabel50: UILabel = {
        let l = UILabel()
        l.textColor = kThemeColorTextUnabled
        l.font = UIFont.systemFont(ofSize: 11.0)
        l.text = "50%"
        return l
    }()
    lazy var percentLabel75: UILabel = {
        let l = UILabel()
        l.textColor = kThemeColorTextUnabled
        l.font = UIFont.systemFont(ofSize: 11.0)
        l.text = "75%"
        return l
    }()
    lazy var percentLabel100: UILabel = {
        let l = UILabel()
        l.textColor = kThemeColorTextUnabled
        l.font = UIFont.systemFont(ofSize: 11.0)
        l.text = "100%"
        return l
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = kThemeColorBackground
        self.view1.backgroundColor = .clear
        self.view2.backgroundColor = .clear
        self.view3.backgroundColor = .clear
        self.view4.backgroundColor = .clear
        self.view1.clipsToBounds = false
        self.view2.clipsToBounds = false
        self.view3.clipsToBounds = false
        self.view4.clipsToBounds = false
        self.point1R.setImage(UIImage(named: "icon-trade-sliderpt-gray"), for: .normal)
        self.point1R.setImage(UIImage(named: "icon-trade-sliderpt-gray"), for: .selected)
        self.point2.setImage(UIImage(named: "icon-trade-sliderpt-gray"), for: .normal)
        self.point2.setImage(UIImage(named: "icon-trade-sliderpt-gray"), for: .selected)
        self.point3.setImage(UIImage(named: "icon-trade-sliderpt-gray"), for: .normal)
        self.point3.setImage(UIImage(named: "icon-trade-sliderpt-gray"), for: .selected)
        self.point4.setImage(UIImage(named: "icon-trade-sliderpt-gray"), for: .normal)
        self.point4.setImage(UIImage(named: "icon-trade-sliderpt-gray"), for: .selected)
        self.sliderBg1.trackTintColor = kThemeColorBorderGray
        self.sliderBg2.trackTintColor = kThemeColorBorderGray
        self.sliderBg3.trackTintColor = kThemeColorBorderGray
        self.sliderBg4.trackTintColor = kThemeColorBorderGray
        self.addSubview(percentLabel0)
        self.addSubview(percentLabel25)
        self.addSubview(percentLabel50)
        self.addSubview(percentLabel75)
        self.addSubview(percentLabel100)
        percentLabel0.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview().offset(-15.0)
            make.left.equalTo(self.point1L)
        }
        percentLabel25.snp.makeConstraints { (make) in
            make.centerY.equalTo(self.percentLabel0)
            make.centerX.equalTo(self.point1R)
        }
        percentLabel50.snp.makeConstraints { (make) in
            make.centerY.equalTo(self.percentLabel0)
            make.centerX.equalTo(self.point2)
        }
        percentLabel75.snp.makeConstraints { (make) in
            make.centerY.equalTo(self.percentLabel0)
            make.centerX.equalTo(self.point3)
        }
        percentLabel100.snp.makeConstraints { (make) in
            make.centerY.equalTo(self.percentLabel0)
            make.right.equalTo(self.point4)
        }
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(self.handlePanGesture(gesture:)))
        self.addGestureRecognizer(pan)
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTapGesture(gesture:)))
        self.addGestureRecognizer(tap)
    }
    
    func setupForModeBuy() {
        self.isModeBuy = true
        self.currentColor = kThemeColorGreen
        self.sliderBg1.progressTintColor = self.currentColor
        self.sliderBg2.progressTintColor = self.sliderBg1.backgroundColor
        self.sliderBg3.progressTintColor = self.sliderBg1.backgroundColor
        self.sliderBg4.progressTintColor = self.sliderBg1.backgroundColor
        self.sliderBg1.progressTintColor = self.sliderBg1.progressTintColor
        self.sliderBg2.progressTintColor = self.sliderBg1.progressTintColor
        self.sliderBg3.progressTintColor = self.sliderBg1.progressTintColor
        self.sliderBg4.progressTintColor = self.sliderBg1.progressTintColor
        self.point1L.isSelected = false
        self.point1R.isSelected = false
        self.point2.isSelected = false
        self.point3.isSelected = false
        self.point4.isSelected = false
        /*
        self.point1R.setImage(UIImage(named: "icon-trade-sliderpt-gray"), for: .normal)
        self.point1R.setImage(UIImage(named: "icon-trade-sliderpt-gray"), for: .selected)
        self.point2.setImage(UIImage(named: "icon-trade-sliderpt-gray"), for: .normal)
        self.point2.setImage(UIImage(named: "icon-trade-sliderpt-gray"), for: .selected)
        self.point3.setImage(UIImage(named: "icon-trade-sliderpt-gray"), for: .normal)
        self.point3.setImage(UIImage(named: "icon-trade-sliderpt-gray"), for: .selected)
        self.point4.setImage(UIImage(named: "icon-trade-sliderpt-gray"), for: .normal)
        self.point4.setImage(UIImage(named: "icon-trade-sliderpt-gray"), for: .selected)
        self.sliderBg1.progress = 0.0
        self.sliderBg2.progress = 0.0
        self.sliderBg3.progress = 0.0
        self.sliderBg4.progress = 0.0*/
        self.sliderValueChanged(with: 0, delay: 0.3)
    }
    
    func setupForModeSell() {
        self.isModeBuy = false
        self.currentColor = kThemeColorRed
        self.sliderBg1.progressTintColor = self.currentColor
        self.sliderBg2.progressTintColor = self.sliderBg1.backgroundColor
        self.sliderBg3.progressTintColor = self.sliderBg1.backgroundColor
        self.sliderBg4.progressTintColor = self.sliderBg1.backgroundColor
        self.sliderBg1.progressTintColor = self.sliderBg1.progressTintColor
        self.sliderBg2.progressTintColor = self.sliderBg1.progressTintColor
        self.sliderBg3.progressTintColor = self.sliderBg1.progressTintColor
        self.sliderBg4.progressTintColor = self.sliderBg1.progressTintColor
        self.point1L.isSelected = true
        self.point1R.isSelected = true
        self.point2.isSelected = true
        self.point3.isSelected = true
        self.point4.isSelected = true
        /*
        self.point1R.setImage(UIImage(named: "icon-trade-sliderpt-gray"), for: .normal)
        self.point1R.setImage(UIImage(named: "icon-trade-sliderpt-gray"), for: .selected)
        self.point2.setImage(UIImage(named: "icon-trade-sliderpt-gray"), for: .normal)
        self.point2.setImage(UIImage(named: "icon-trade-sliderpt-gray"), for: .selected)
        self.point3.setImage(UIImage(named: "icon-trade-sliderpt-gray"), for: .normal)
        self.point3.setImage(UIImage(named: "icon-trade-sliderpt-gray"), for: .selected)
        self.point4.setImage(UIImage(named: "icon-trade-sliderpt-gray"), for: .normal)
        self.point4.setImage(UIImage(named: "icon-trade-sliderpt-gray"), for: .selected)
        self.sliderBg1.progress = 0.0
        self.sliderBg2.progress = 0.0
        self.sliderBg3.progress = 0.0
        self.sliderBg4.progress = 0.0*/
        self.sliderValueChanged(with: 0, delay: 0.3)
    }
    
    func sliderValueChanged(with value: Float, withoutCallback: Bool = false, delay: TimeInterval = 0.0) {
        if delay > 0 {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+delay) {
                self.changeSliderValue(with: value, withoutCallback: withoutCallback)
            }
        } else {
            self.changeSliderValue(with: value, withoutCallback: withoutCallback)
        }
        
        self.percentLabel0.textColor = kThemeColorTextUnabled
        self.percentLabel25.textColor = kThemeColorTextUnabled
        self.percentLabel50.textColor = kThemeColorTextUnabled
        self.percentLabel75.textColor = kThemeColorTextUnabled
        self.percentLabel100.textColor = kThemeColorTextUnabled
        if value <= 0 {
            self.percentLabel0.textColor = self.currentColor
        } else if value >= 0.245 && value <= 0.255 {
            self.percentLabel25.textColor = self.currentColor
        } else if value >= 0.495 && value <= 0.505 {
            self.percentLabel50.textColor = self.currentColor
        } else if value >= 0.745 && value <= 0.755 {
            self.percentLabel75.textColor = self.currentColor
        } else if value >= 0.995 {
            self.percentLabel100.textColor = self.currentColor
        }
    }
    
    private func changeSliderValue(with value: Float, withoutCallback: Bool) {
        if value >= 0 && value <= 0.25 {
            self.sliderBg1.progress = value/0.25
            self.sliderBg2.progress = 0.0
            self.sliderBg3.progress = 0.0
            self.sliderBg4.progress = 0.0
            self.point1R.setImage(UIImage(named: "icon-trade-sliderpt-gray"), for: .normal)
            self.point1R.setImage(UIImage(named: "icon-trade-sliderpt-gray"), for: .selected)
            self.point2.setImage(UIImage(named: "icon-trade-sliderpt-gray"), for: .normal)
            self.point2.setImage(UIImage(named: "icon-trade-sliderpt-gray"), for: .selected)
            self.point3.setImage(UIImage(named: "icon-trade-sliderpt-gray"), for: .normal)
            self.point3.setImage(UIImage(named: "icon-trade-sliderpt-gray"), for: .selected)
            self.point4.setImage(UIImage(named: "icon-trade-sliderpt-gray"), for: .normal)
            self.point4.setImage(UIImage(named: "icon-trade-sliderpt-gray"), for: .selected)
        } else if value >= 0.25 && value <= 0.5 {
            self.sliderBg2.progress = (value-0.25)/0.25 < 0.1 ? 0:(value-0.25)/0.25
            self.sliderBg1.progress = 1.0
            self.sliderBg3.progress = 0.0
            self.sliderBg4.progress = 0.0
            self.point1R.setImage(UIImage(named: "icon-trade-sliderpt-green"), for: .normal)
            self.point1R.setImage(UIImage(named: "icon-trade-sliderpt-red"), for: .selected)
            self.point2.setImage(UIImage(named: "icon-trade-sliderpt-gray"), for: .normal)
            self.point2.setImage(UIImage(named: "icon-trade-sliderpt-gray"), for: .selected)
            self.point3.setImage(UIImage(named: "icon-trade-sliderpt-gray"), for: .normal)
            self.point3.setImage(UIImage(named: "icon-trade-sliderpt-gray"), for: .selected)
            self.point4.setImage(UIImage(named: "icon-trade-sliderpt-gray"), for: .normal)
            self.point4.setImage(UIImage(named: "icon-trade-sliderpt-gray"), for: .selected)
        } else if value >= 0.5 && value <= 0.75 {
            self.sliderBg3.progress = (value-0.5)/0.25 < 0.1 ? 0:(value-0.5)/0.25
            self.sliderBg1.progress = 1.0
            self.sliderBg2.progress = 1.0
            self.sliderBg4.progress = 0.0
            self.point1R.setImage(UIImage(named: "icon-trade-sliderpt-green"), for: .normal)
            self.point1R.setImage(UIImage(named: "icon-trade-sliderpt-red"), for: .selected)
            self.point2.setImage(UIImage(named: "icon-trade-sliderpt-green"), for: .normal)
            self.point2.setImage(UIImage(named: "icon-trade-sliderpt-red"), for: .selected)
            self.point3.setImage(UIImage(named: "icon-trade-sliderpt-gray"), for: .normal)
            self.point3.setImage(UIImage(named: "icon-trade-sliderpt-gray"), for: .selected)
            self.point4.setImage(UIImage(named: "icon-trade-sliderpt-gray"), for: .normal)
            self.point4.setImage(UIImage(named: "icon-trade-sliderpt-gray"), for: .selected)
        } else if value >= 0.75 && value <= 1.0 {
            self.sliderBg4.progress = (value-0.75)/0.25 < 0.1 ? 0:(value-0.75)/0.25
            self.sliderBg1.progress = 1.0
            self.sliderBg2.progress = 1.0
            self.sliderBg3.progress = 1.0
            self.point1R.setImage(UIImage(named: "icon-trade-sliderpt-green"), for: .normal)
            self.point1R.setImage(UIImage(named: "icon-trade-sliderpt-red"), for: .selected)
            self.point2.setImage(UIImage(named: "icon-trade-sliderpt-green"), for: .normal)
            self.point2.setImage(UIImage(named: "icon-trade-sliderpt-red"), for: .selected)
            self.point3.setImage(UIImage(named: "icon-trade-sliderpt-green"), for: .normal)
            self.point3.setImage(UIImage(named: "icon-trade-sliderpt-red"), for: .selected)
            if value >= 0.98 {
                self.point4.setImage(UIImage(named: "icon-trade-sliderpt-green"), for: .normal)
                self.point4.setImage(UIImage(named: "icon-trade-sliderpt-red"), for: .selected)
            } else {
                self.point4.setImage(UIImage(named: "icon-trade-sliderpt-gray"), for: .normal)
                self.point4.setImage(UIImage(named: "icon-trade-sliderpt-gray"), for: .selected)
            }
        }
        
        if let callback = self.valueChangedCallback, withoutCallback == false {
            callback(value)
        }
    }
    
    // MARK: - Events.
    @objc private func handlePanGesture(gesture: UIPanGestureRecognizer) {
        let point = gesture.location(in: self)
        var progress = point.x/self.frame.width
        switch gesture.state {
        case .changed:
            if progress > 1.0 { progress = 1.0 }
            if progress < 0 { progress = 0 }
            self.sliderValueChanged(with: Float(progress))
        case .cancelled, .ended, .failed:
            if progress < 0.25 {
                self.sliderValueChanged(with: 0)
            } else if progress > 0.75 {
                self.sliderValueChanged(with: 1.0)
            }
        default:break
        }
    }
    
    private let pointGestureSize: CGFloat = 30.0
    @objc private func handleTapGesture(gesture: UITapGestureRecognizer) {
        let point = gesture.location(in: self)
        let rec0 = CGRect(
            x: self.point1L.center.x-pointGestureSize/2.0,
            y: self.point1L.center.y-pointGestureSize/2.0,
            width: pointGestureSize,
            height: pointGestureSize
        )
        let rec1 = CGRect(
            x: self.point1R.center.x-pointGestureSize/2.0,
            y: self.point1R.center.y-pointGestureSize/2.0,
            width: pointGestureSize,
            height: pointGestureSize
        )
        let rec2 = CGRect(
            x: self.point2.center.x-pointGestureSize/2.0+self.view1.frame.width,
            y: self.point2.center.y-pointGestureSize/2.0,
            width: pointGestureSize,
            height: pointGestureSize
        )
        let rec3 = CGRect(
            x: self.point3.center.x-pointGestureSize/2.0+self.view1.frame.width*2.0,
            y: self.point3.center.y-pointGestureSize/2.0,
            width: pointGestureSize,
            height: pointGestureSize
        )
        let rec4 = CGRect(
            x: self.point4.center.x-pointGestureSize/2.0+self.view1.frame.width*3.0,
            y: self.point4.center.y-pointGestureSize/2.0,
            width: pointGestureSize,
            height: pointGestureSize
        )
        if rec0.contains(point) {
            self.sliderValueChanged(with: 0)
        } else if rec1.contains(point) {
            self.sliderValueChanged(with: 0.25)
            self.point1R.setImage(UIImage(named: "icon-trade-sliderpt-green"), for: .normal)
            self.point1R.setImage(UIImage(named: "icon-trade-sliderpt-red"), for: .selected)
        } else if rec2.contains(point) {
            self.sliderValueChanged(with: 0.5)
            self.point2.setImage(UIImage(named: "icon-trade-sliderpt-green"), for: .normal)
            self.point2.setImage(UIImage(named: "icon-trade-sliderpt-red"), for: .selected)
        } else if rec3.contains(point) {
            self.sliderValueChanged(with: 0.75)
            self.point3.setImage(UIImage(named: "icon-trade-sliderpt-green"), for: .normal)
            self.point3.setImage(UIImage(named: "icon-trade-sliderpt-red"), for: .selected)
        } else if rec4.contains(point) {
            self.sliderValueChanged(with: 1.0)
        }
    }
    
    @IBAction func point1Pressed(_ sender: Any) {
        self.sliderValueChanged(with: 0)
    }
    
    @IBAction func point2Pressed(_ sender: Any) {
        self.sliderValueChanged(with: 0.25)
    }
    
    @IBAction func point3Pressed(_ sender: Any) {
        self.sliderValueChanged(with: 0.5)
    }
    
    @IBAction func point4Pressed(_ sender: Any) {
        self.sliderValueChanged(with: 0.75)
    }
    
    @IBAction func point5Pressed(_ sender: Any) {
        self.sliderValueChanged(with: 1.0)
    }
    
}
