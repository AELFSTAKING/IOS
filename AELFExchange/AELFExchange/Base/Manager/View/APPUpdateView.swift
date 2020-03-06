//
//  APPUpdateView.swift
//  AELFExchange
//
//  Created by tng on 2019/1/16.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import Foundation
import UIKit

class APPUpdateView: UIView {

    @IBOutlet weak var contentViewTrailing: NSLayoutConstraint!
    @IBOutlet weak var contentViewLeading: NSLayoutConstraint!
    @IBOutlet weak var coverView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var closeButton: UIButton! {
        didSet {
            closeButton.imageView?.contentMode = .scaleAspectFit
        }
    }
    @IBOutlet weak var bg: UIImageView!
    @IBOutlet weak var confirmButton: Button!
    @IBOutlet weak var textview: UITextView! {
        didSet {
            textview.isEditable = false
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.alpha = 0
        if IsScreen40 || IsScreen35 {
            contentViewTrailing.constant = 25.0
            contentViewLeading.constant = 25.0
        }
        self.bg.image = UIImage(named: LanguageManager.shared().currentLanguage() == .ZH_HANS ? "icon-update-bg":"icon-update-bg-en")
    }
    
    func show() -> Void {
        UIView.animate(withDuration: 0.2) {
            self.alpha = 1.0
        }
    }
    
    func hide() -> Void {
        UIView.animate(withDuration: 0.2, animations: {
            self.alpha = 0
        }) { (_) in
            self.removeFromSuperview()
        }
    }
    
    func contentSetup(withDesc desc: String) {
        guard let data = desc.data(using: .unicode), desc.contains("<"), desc.contains(">") else {
            self.textview.text = desc
            return
        }
        do {
            let attr = try NSMutableAttributedString(data: data, options: [
                NSAttributedString.DocumentReadingOptionKey.documentType : NSAttributedString.DocumentType.html
                ], documentAttributes: nil)
            self.textview.attributedText = attr
        } catch {
            self.textview.text = desc
        }
        
    }
    
    @IBAction func confirmPressed(_ sender: Any) {
        
    }
    
}
