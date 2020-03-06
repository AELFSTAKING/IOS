//
//  Label.swift
//  AELFExchange
//
//  Created by tng on 2019/1/11.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class Label: UILabel {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    @IBInspectable
    var General: String = "1" {
        didSet {
            if General == "1" {
                self.textColor = kThemeColorTextNormal
                self.setNeedsLayout()
            }
        }
    }
    
    @IBInspectable
    var White: String? {
        didSet {
            if White == "1" {
                self.textColor = .white
                self.font = kThemeFontNormal
                self.setNeedsLayout()
            }
        }
    }
    
    @IBInspectable
    var Gray: String? {
        didSet {
            if Gray == "1" {
                self.textColor = kThemeColorTextUnabled
                self.setNeedsLayout()
            }
        }
    }
    
    @IBInspectable
    var Foreground: String? {
        didSet {
            if Foreground == "1" {
                self.textColor = kThemeColorSelected
                self.font = kThemeFontNormal
                self.setNeedsLayout()
            }
        }
    }
    
    @IBInspectable
    var Large: String? {
        didSet {
            if Large == "1" {
                self.font = kThemeFontLarge
                self.setNeedsLayout()
            }
        }
    }
    
    @IBInspectable
    var FontSize: String? {
        didSet {
            if let size = FontSize, let fSize = Double(size) {
                self.font = UIFont.systemFont(ofSize: CGFloat(fSize))
                self.setNeedsLayout()
            }
        }
    }
    
    private var progress: Float = 0.5
    @IBInspectable
    var Progressable: String? {
        didSet {
            if Progressable == "1" {
                self.alpha = 0.12
            }
        }
    }
    @IBInspectable
    var FromRight: String?
    @IBInspectable
    var GreenProgress: String?
    @IBInspectable
    var RedProgress: String?
    
    func commonInit() -> Void {
        self.textColor = kThemeColorTextNormal
        self.setNeedsLayout()
    }
    
    override func draw(_ rect: CGRect) {
        if  self.Progressable == "1",
            let context = UIGraphicsGetCurrentContext() {
            let color = self.GreenProgress == "1" ? kThemeColorGreenProgress : kThemeColorRedProgress
            let fillLen = self.bounds.width*CGFloat(self.progress)
            context.setFillColor(color.cgColor)
            context.fill(CGRect(
                x: self.FromRight == "1" ? self.bounds.width-fillLen : 0,
                y: 0,
                width: fillLen,
                height: self.bounds.height)
            )
        }
        super.draw(rect)
    }
    
    override func drawText(in rect: CGRect) {
        if self.Progressable == "1" {
            super.drawText(in: CGRect(x: 3.0, y: 0, width: rect.width-6.0, height: rect.height))
        } else {
            super.drawText(in: rect)
        }
    }
    
}

extension Label {
    
    func updateProgress(to progress: Float) -> Void {
        self.progress = progress
        self.setNeedsDisplay()
    }
    
}
