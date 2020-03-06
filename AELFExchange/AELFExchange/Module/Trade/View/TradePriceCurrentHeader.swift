//
//  TradePriceCurrentHeader.swift
//  AELFExchange
//
//  Created by tng on 2019/1/23.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import Foundation
import UIKit

class TradePriceCurrentHeader: UIView {
    
    @IBOutlet weak var priceLabel: Label!
    @IBOutlet weak var signalIcon: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .clear
        self.priceLabel.font = kThemeFontDINBold(13.0)
    }
    
    func updateSignal(toOn isOn: Bool) -> Void {
        DispatchQueue.main.async {
            self.signalIcon.tintColor = isOn ? kThemeColorGreen : ColorRGB(r: 86.0, g: 87.0, b: 99.0)
        }
    }
    
}
