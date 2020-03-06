//
//  OrderBookHeaderView.swift
//  AELFExchange
//
//  Created by tng on 2019/7/17.
//  Copyright © 2019 cex.io. All rights reserved.
//

import Foundation
import UIKit
import Result
import ReactiveSwift

enum OrderBookHeaderViewButtonType {
    case current
    case history
    case all
}

class OrderBookHeaderView: UIView {
    
    let (buttonPressedSignal, buttonPressedObserver) = Signal<OrderBookHeaderViewButtonType, NoError>.pipe()
    
    @IBOutlet weak var currentButton: Button!
    @IBOutlet weak var historyButton: Button!
    @IBOutlet weak var allButton: Button!
    @IBOutlet weak var sepView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.sepView.backgroundColor = kThemeColorSeparator
        self.allButton.reactive.controlEvents(.touchUpInside).observeValues { (_) in
            self.buttonPressedObserver.send(value: .all)
        }
    }
    
    @IBAction func currentPressed(_ sender: Any) {
        self.updateStatus(toCurrent: true)
        self.buttonPressedObserver.send(value: .current)
    }
    
    @IBAction func historyPressed(_ sender: Any) {
        self.updateStatus(toCurrent: false)
        self.buttonPressedObserver.send(value: .history)
    }
    
    func updateStatus(toCurrent: Bool) {
        if toCurrent {
            self.currentButton.titleLabel?.font = UIFont.systemFont(ofSize: 16.0, weight: .semibold)
            self.currentButton.setTitleColor(kThemeColorTextNormal, for: .normal)
            self.historyButton.titleLabel?.font = UIFont.systemFont(ofSize: 13.0, weight: .medium)
            self.historyButton.setTitleColor(kThemeColorTextUnabled, for: .normal)
        } else {
            self.historyButton.titleLabel?.font = UIFont.systemFont(ofSize: 16.0, weight: .semibold)
            self.historyButton.setTitleColor(kThemeColorTextNormal, for: .normal)
            self.currentButton.titleLabel?.font = UIFont.systemFont(ofSize: 13.0, weight: .medium)
            self.currentButton.setTitleColor(kThemeColorTextUnabled, for: .normal)
        }
    }
    
}
