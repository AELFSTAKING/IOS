//
//  HomeQuickMenuView.swift
//  AELFExchange
//
//  Created by tng on 2019/1/8.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import UIKit

class HomeQuickMenuView: UIView {
    
    @IBOutlet weak var titleButton: UIButton!
    @IBOutlet weak var view1: UIView!
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var view2: UIView!
    @IBOutlet weak var button2: UIButton!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var view3: UIView!
    @IBOutlet weak var button3: UIButton!
    @IBOutlet weak var label3: UILabel!
    @IBOutlet weak var view4: UIView!
    @IBOutlet weak var button4: UIButton!
    @IBOutlet weak var label4: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = kThemeColorBackground
        
        LanguageManager.shared().languageDidChangedSignal.observeValues { [weak self] (_) in
            self?.titleButton.setTitle(LOCSTR(withKey: "热门应用"), for: .normal)
            self?.label1.text = LOCSTR(withKey: "飞鱼捕手")
            self?.label2.text = LOCSTR(withKey: "斗地主")
        }
    }
    
    @IBAction func button1Pressed(_ sender: Any) {
    }
    
    @IBAction func button2Pressed(_ sender: Any) {
    }
    
    @IBAction func button3Pressed(_ sender: Any) {
    }
    
    @IBAction func button4Pressed(_ sender: Any) {
    }
    
}
