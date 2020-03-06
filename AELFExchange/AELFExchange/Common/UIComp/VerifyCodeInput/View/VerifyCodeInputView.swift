//
//  VerifyCodeInputView.swift
//  AELFExchange
//
//  Created by tng on 2019/1/12.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import Foundation
import UIKit

class VerifyCodeInputView: UIView {
    
    var inputFinished: ((String) -> Void)?
    
    private let numbers = ["0","1","2","3","4","5","6","7","8","9"]
    private let count = 6
    
    lazy var textfield: UITextField = {
        let t = UITextField()
        t.backgroundColor = .clear
        t.tintColor = .clear
        t.textColor = .clear
        t.keyboardType = .numberPad
        t.delegate = self
        return t
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    private func commonInit() -> Void {
        self.addSubview(self.textfield)
        self.textfield.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
        
        let width = (kScreenSize.width-CGFloat(kContentSpacing)*(CGFloat(self.count)+1.0))/CGFloat(self.count)
        for i in 0 ..< self.count {
            let label = UILabel(frame: CGRect(
                x: CGFloat(kContentSpacing)+(width+CGFloat(kContentSpacing))*CGFloat(i),
                y: 0,
                width: width,
                height: self.frame.size.height
            ))
            label.textColor = .white
            label.textAlignment = .center
            label.font = kThemeFontLarge
            label.backgroundColor = .clear
            label.tag = i+1
            self.addSubview(label)
            
            let sep = UIView(frame: CGRect(x: label.frame.minX, y: label.frame.maxY, width: label.frame.width, height: 2.0))
            sep.backgroundColor = kThemeColorTextNormal
            sep.addCorner(withRadius: 1.0)
            sep.tag = i+100+1
            self.addSubview(sep)
        }
    }
    
    func clear() -> Void {
        self.textfield.text = nil
        for case let item in self.subviews where item.isKind(of: UILabel.self) {
            (item as! UILabel).text = nil
        }
    }
    
    func updateUnderLine(to index: Int) -> Void {
        for i in 1...self.count {
            if let view = self.viewWithTag(i+100) {
                if i <= index {
                    view.backgroundColor = kThemeColorSelected
                } else {
                    view.backgroundColor = kThemeColorTextNormal
                }
            }
        }
    }
    
}

extension VerifyCodeInputView: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.text?.count ?? 0 >= self.count && string != "" {
            textField.resignFirstResponder()
            return false
        }
        
        let valid = self.numbers.contains(string) || string == ""
        if  valid == true,
            let index = textField.text?.count,
            let label = self.viewWithTag(index+1) as? UILabel {
            // Add.
            label.text = string
            self.updateUnderLine(to: index+1)
            
            if index == self.count-1 && string != "" {
                // Input finished.
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.2) {
                    textField.resignFirstResponder()
                }
                if let callback = self.inputFinished {
                    callback("\(textField.text ?? "")\(string)")
                }
            }
        }
        if  string == "",
            let index = textField.text?.count {
            self.updateUnderLine(to: index-1)
            
            // Del.
            if let lastLabel = self.viewWithTag(index) as? UILabel {
                lastLabel.text = nil
            }
        }
        return valid
    }
    
}
