//
//  RewardRuleVC.swift
//  AELFExchange
//
//  Created by tng on 2019/8/8.
//  Copyright © 2019 cex.io. All rights reserved.
//

import Foundation

class RewardRuleVC: BaseViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.uiSetup()
        self.signalSetup()
    }
    
    // MARK: - Custom Accessors
    
    // MARK: - IBActions
    
    // MARK: - Public
    
    // MARK: - Private
    private func uiSetup() -> Void {
        self.title = LOCSTR(withKey: "规则")
        let img = UIImage(named: "icon-reward-rule")!
        let image = UIImageView(image: img)
        image.frame = CGRect(x: 0, y: 0, width: kScreenSize.width, height: kScreenSize.width*(img.size.height/img.size.width))
        image.contentMode = .scaleAspectFit
        self.scrollView.addSubview(image)
        self.scrollView.contentSize = CGSize(width: kScreenSize.width, height: image.frame.height)
    }
    
    private func signalSetup() -> Void {
        
    }
    
    // MARK: - Signal
    
    // MARK: - Protocol conformance
    
    // MARK: - UITextFieldDelegate
    
    // MARK: - UITableViewDataSource
    
    // MARK: - UITableViewDelegate
    
    // MARK: - NSCopying
    
    // MARK: - NSObject
    
}
