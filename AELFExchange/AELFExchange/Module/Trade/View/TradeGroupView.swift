//
//  TradeGroupView.swift
//  AELFExchange
//
//  Created by tng on 2019/6/19.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import UIKit
import ReactiveSwift
import Result

class TradeGroupView: UIView {
    
    let (valueChangedSignal, valueChangedObserver) = Signal<Int, NoError>.pipe()
    let (shouldLoginSignal, shouldLoginObserver) = Signal<Bool, NoError>.pipe()
    var currentIndex = 1
    private var currentData = [String]()
    
    private let itemFont = UIFont.boldSystemFont(size: 16.0)
    private let itemSpacing: CGFloat = 5.0
    private let itemHeight: CGFloat = 30.0
    
    lazy var scrollView: UIScrollView = {
        let s = UIScrollView()
        s.backgroundColor = .clear
        s.showsHorizontalScrollIndicator = false
        return s
    }()

    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        self.backgroundColor = kThemeColorNavigationBarBlue
        
        self.addSubview(self.scrollView)
        self.scrollView.snp.makeConstraints { (make) in
            make.edges.equalTo(UIEdgeInsets(top: 0, left: 10.0, bottom: 0, right: 10.0))
        }
    }
    
    func sync(withData data: [String]) {
        guard data.count > 0, !data.elementsEqual(self.currentData) else { return }
        currentData.removeAll()
        currentData.append(contentsOf: data)
        for case let view in self.scrollView.subviews where view.isKind(of: UIButton.self) {
            view.removeFromSuperview()
        }
        
        var lastMaxX: CGFloat = 0.0
        for index in 0..<data.count {
            let title = data[index]
            let width = title.size(ofcomponentWidth: Float(kScreenSize.width), font: self.itemFont, extraAttribute: nil).width+30.0
            
            let button = UIButton(type: .system)
            button.backgroundColor = .clear
            button.addCorner(withRadius: Float(self.itemHeight/2.0))
            button.addBorder(withWitdh: 0.65, color: kThemeColorSeparator)
            button.setTitleColor(kThemeColorTextNormal, for: .normal)
            button.titleLabel?.font = self.itemFont
            button.setTitle(title, for: .normal)
            button.tag = index+1
            button.addTarget(self, action: #selector(self.itemPressed(_:)), for: .touchUpInside)
            self.scrollView.addSubview(button)
            button.snp.makeConstraints { (make) in
                make.centerY.equalToSuperview()
                make.height.equalTo(self.itemHeight)
                make.width.equalTo(width)
                make.left.equalToSuperview().offset(lastMaxX)
            }
            
            if index == currentIndex {
                button.setTitleColor(.white, for: .normal)
                button.backgroundColor = UIColor(hexStr: "0091FF")
            }
            lastMaxX += width+self.itemSpacing
        }
        self.scrollView.contentSize = CGSize(width: lastMaxX+10.0, height: self.scrollView.contentSize.height)
    }
    
    @objc private func itemPressed(_ button: UIButton) {
        self.indexChanged(to: button.tag-1)
    }
    
    func indexChanged(to index: Int) {
        //if index == 0 && !Profile.shared().logined {
        if index == 0 {
            self.shouldLoginObserver.send(value: true)
            return
        }
        
        guard index != self.currentIndex, let button = self.scrollView.viewWithTag(index+1) as? UIButton else {
            return
        }
        
        self.currentIndex = index
        self.valueChangedObserver.send(value: index)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(hexStr: "0091FF")
        
        for case let view in self.scrollView.subviews where view.isKind(of: UIButton.self) {
            let b = (view as! UIButton)
            guard b.tag != index+1 else { continue }
            b.setTitleColor(kThemeColorTextNormal, for: .normal)
            b.backgroundColor = .clear
        }
    }

}
